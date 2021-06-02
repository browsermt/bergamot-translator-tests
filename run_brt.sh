#!/bin/bash

# Marian regression test script. Invocation examples:
#  ./run_brt.sh
#  ./run_brt.sh tests/training/basics
#  ./run_brt.sh tests/training/basics/test_valid_script.sh
#  ./run_brt.sh previous.log
#  ./run_brt.sh '#tag'
# where previous.log contains a list of test files in separate lines.

# Environment variables:
#  - MARIAN - path to Marian build directory
#  - CUDA_VISIBLE_DEVICES - CUDA's variable specifying GPU device IDs
#  - NUM_DEVICES - maximum number of GPU devices to be used
#  - TIMEOUT - maximum duration for execution of a single test in the format
#    accepted by the timeout command; set to 0 to disable

SHELL=/bin/bash

export LC_ALL=C.UTF-8

function log {
    echo [$(date "+%m/%d/%Y %T")] $@
}

function logn {
    echo -n [$(date "+%m/%d/%Y %T")] $@
}

log "Running on $(hostname) as process $$"

export BRT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export BRT_TOOLS=$BRT_ROOT/tools
export BRT_MARIAN="$( realpath ${MARIAN:-$BRT_ROOT/../build} )"
export BRT_MODELS=$BRT_ROOT/models
export BRT_TEST_PACKAGE_EN_DE=$BRT_MODELS/deen/ende.student.tiny.for.regression.tests
export BRT_DATA=$BRT_ROOT/data


export LD_LIBRARY_PATH="${BRT_MARIAN}:${LD_LIBRARY_PATH}"

# Check if required tools are present in marian directory
if [ ! -e $BRT_MARIAN/app/bergamot ]; then
    echo "Error: '$BRT_MARIAN/app/bergamot' not found. Do you need to compile the toolkit first?"
    exit 1
fi

#log "Using Marian binary: $BRT_MARIAN/marian"

# Log Marian version
export BRT_MARIAN_VERSION=$($BRT_MARIAN/app/bergamot --version 2>&1)
log "Version: $BRT_MARIAN_VERSION"

# Get CMake settings from the --build-info option
if ! grep -q "build-info" < <( $BRT_MARIAN/app/bergamot --help ); then
    echo "Error: Marian is too old as it does not have the required --build-info option"
    exit 1
fi

$BRT_MARIAN/app/bergamot --build-info all 2> $BRT_ROOT/cmake.log

# Check Marian compilation settings
export BRT_MARIAN_BUILD_TYPE=$(cat $BRT_ROOT/cmake.log        | grep "CMAKE_BUILD_TYPE=" | cut -f2 -d=)
export BRT_MARIAN_COMPILER=$(cat $BRT_ROOT/cmake.log          | grep "CMAKE_CXX_COMPILER=" | cut -f2 -d=)
export BRT_MARIAN_USE_MKL=$(cat $BRT_ROOT/cmake.log           | egrep "USE_MKL=(ON|on|1)")
export BRT_MARIAN_USE_CUDA=$(cat $BRT_ROOT/cmake.log          | egrep "COMPILE_CUDA=(ON|on|1)")
export BRT_MARIAN_USE_CUDNN=$(cat $BRT_ROOT/cmake.log         | egrep "USE_CUDNN=(ON|on|1)")
export BRT_MARIAN_USE_SENTENCEPIECE=$(cat $BRT_ROOT/cmake.log | egrep "USE_SENTENCEPIECE=(ON|on|1)")
export BRT_MARIAN_USE_FBGEMM=$(cat $BRT_ROOT/cmake.log        | egrep "USE_FBGEMM=(ON|on|1)")
export BRT_MARIAN_USE_UNITTESTS=$(cat $BRT_ROOT/cmake.log     | egrep "COMPILE_TESTS=(ON|on|1)")
export BRT_MARIAN_MKL_FOUND=$(cat $BRT_ROOT/cmake.log         | egrep "MKL_ROOT=" | cut -f2 -d=)

log "Build type: $BRT_MARIAN_BUILD_TYPE"
log "Using compiler: $BRT_MARIAN_COMPILER"
log "Using MKL: $BRT_MARIAN_USE_MKL"
log "Using CUDNN: $BRT_MARIAN_USE_CUDNN"
log "Using SentencePiece: $BRT_MARIAN_USE_SENTENCEPIECE"
log "Using FBGEMM: $BRT_MARIAN_USE_FBGEMM"
log "Unit tests: $BRT_MARIAN_USE_UNITTESTS"
export BRT_MARIAN_USE_MKL=on # hardcode

# Additional environment setup
source "env.d/base.sh"

export BRT_EVAL_MODE=${BRT_EVAL_MODE:-exact}
if [[ "$BRT_EVAL_MODE" == "approx" ]]; then
    source "env.d/approx.sh"
else
    source "env.d/exact.sh"
fi

INSTRUCTION=${INSTRUCTION:-auto}

eval "$(python3 $BRT_TOOLS/resolve-instruction.py --path $BRT_TOOLS/cpu-features/build/list_cpu_features --upto $INSTRUCTION)"
printenv | grep -e "INTGEMM_CPUID" -e "BRT_INSTRUCTION" -e "MKL"

# Number of available devices
# cuda_num_devices=$(($(echo $CUDA_VISIBLE_DEVICES | grep -c ',')+1))
# export BRT_NUM_DEVICES=${NUM_DEVICES:-$cuda_num_devices}

# log "Using CUDA visible devices: $CUDA_VISIBLE_DEVICES"
# log "Using number of GPU devices: $BRT_NUM_DEVICES"

export BRT_TIMEOUT=${TIMEOUT:-5m}   # the default time out is 5 minutes, see `man timeout`
cmd_timeout=""
if [ $BRT_TIMEOUT != "0" ]; then
    cmd_timeout="timeout $BRT_TIMEOUT"
fi

log "Using time out: $BRT_TIMEOUT"

# Exit codes
export EXIT_CODE_SUCCESS=0
export EXIT_CODE_SKIP=100
export EXIT_CODE_TIMEOUT=124    # Exit code returned by the timeout command if timed out

function format_time {
    dt=$(echo "$2 - $1" | bc 2>/dev/null)
    dh=$(echo "$dt/3600" | bc 2>/dev/null)
    dt2=$(echo "$dt-3600*$dh" | bc 2>/dev/null)
    dm=$(echo "$dt2/60" | bc 2>/dev/null)
    ds=$(echo "$dt2-60*$dm" | bc 2>/dev/null)
    LANG=C printf "%02d:%02d:%02.3fs" $dh $dm $ds
}


###############################################################################
# Default directory with all regression tests
test_prefixes=tests

if [ $# -ge 1 ]; then
    test_prefixes=
    for arg in "$@"; do
        # A log file with paths to test files
        if [[ "$arg" = *.log ]]; then
            # Extract tests from .log file
            args=$(cat $arg | grep '/test_.*\.sh' | grep -v '/_' | sed 's/^ *- *//' | tr '\n' ' ' | sed 's/ *$//')
            test_prefixes="$test_prefixes $args"
        # A hash tag
        elif [[ "$arg" = '#'* ]]; then
            # Find all tests with the given hash tag
            tag=${arg:1}
            args=$(find tests -name '*test_*.sh' | xargs -I{} grep -H "^ *# *TAGS:.* $tag" {} | cut -f1 -d:)
            test_prefixes="$test_prefixes $args"
        # A test file or directory name
        else
            test_prefixes="$test_prefixes $arg"
        fi
    done
fi

# Extract all subdirectories, which will be traversed to look for regression tests
test_dirs=$(find $test_prefixes -type d | grep -v "/_")

if grep -q "/test_.*\.sh" <<< "$test_prefixes"; then
    test_files=$(printf '%s\n' $test_prefixes | sed 's!*/!!')
    test_dirs=$(printf '%s\n' $test_prefixes | xargs -I{} dirname {} | grep -v "/_" | sort | uniq)
fi


###############################################################################
success=true
count_all=0
count_failed=0
count_passed=0
count_skipped=0
count_timedout=0

declare -a tests_failed
declare -a tests_skipped
declare -a tests_timedout

time_start=$(date +%s.%N)

# Traverse test directories
cd $BRT_ROOT
for test_dir in $test_dirs
do
    log "Checking directory: $test_dir"
    nosetup=false

    # Run setup script if exists
    if [ -e $test_dir/setup.sh ]; then
        log "Running setup script"

        cd $test_dir
        $cmd_timeout $SHELL -v setup.sh &> setup.log
        if [ $? -ne 0 ]; then
            log "Warning: setup script returns a non-success exit code"
            success=false
            nosetup=true
        else
            rm setup.log
        fi
        cd $BRT_ROOT
    fi

    # Run tests
    for test_path in $(ls -A $test_dir/test_*.sh 2>/dev/null)
    do
        test_file=$(basename $test_path)
        test_name="${test_file%.*}"

        # In non-traverse mode skip tests if not requested
        if [[ -n "$test_files" && $test_files != *"$test_file"* ]]; then
            continue
        fi
        test_time_start=$(date +%s.%N)
        ((++count_all))

        # Tests are executed from their directory
        cd $test_dir

        # Skip tests if setup failed
        logn "Running $test_path ... "
        if [ "$nosetup" = true ]; then
            ((++count_skipped))
            tests_skipped+=($test_path)
            echo " skipped"
            cd $BRT_ROOT
            continue;
        fi

        # Run test
        # Note: all output gets written to stderr (very very few cases write to stdout)
        $cmd_timeout $SHELL -x $test_file 2> $test_file.log 1>&2
        exit_code=$?

        # Check exit code
        if [ $exit_code -eq $EXIT_CODE_SUCCESS ]; then
            ((++count_passed))
            echo " OK"
        elif [ $exit_code -eq $EXIT_CODE_SKIP ]; then
            ((++count_skipped))
            tests_skipped+=($test_path)
            echo " skipped"
        elif [ $exit_code -eq $EXIT_CODE_TIMEOUT ]; then
            ((++count_timedout))
            tests_timedout+=($test_path)
            # Add a comment to the test log file that it timed out
            echo "The test timed out after $TIMEOUT" >> $test_file.log
            # A timed out test is a failed test
            ((++count_failed))
            echo " timed out"
            success=false
        else
            ((++count_failed))
            tests_failed+=($test_path)
            echo " failed"
            success=false
        fi

        # Report time
        test_time_end=$(date +%s.%N)
        test_time=$(format_time $test_time_start $test_time_end)
        log "Test took $test_time"

        cd $BRT_ROOT
    done
    cd $BRT_ROOT

    # Run teardown script if exists
    if [ -e $test_dir/teardown.sh ]; then
        log "Running teardown script"

        cd $test_dir
        $cmd_timeout $SHELL teardown.sh &> teardown.log
        if [ $? -ne 0 ]; then
            log "Warning: teardown script returns a non-success exit code"
            success=false
        else
            rm teardown.log
        fi
        cd $BRT_ROOT
    fi
done

time_end=$(date +%s.%N)
time_total=$(format_time $time_start $time_end)

prev_log=previous.log
rm -f $prev_log


###############################################################################
# Print skipped and failed tests
if [ -n "$tests_skipped" ] || [ -n "$tests_failed" ] || [ -n "$tests_timedout" ]; then
    echo "---------------------"
fi
[[ -z "$tests_skipped" ]] || echo "Skipped:" | tee -a $prev_log
for test_name in "${tests_skipped[@]}"; do
    echo "  - $test_name" | tee -a $prev_log
done
[[ -z "$tests_failed" ]] || echo "Failed:" | tee -a $prev_log
for test_name in "${tests_failed[@]}"; do
    echo "  - $test_name" | tee -a $prev_log
done
[[ -z "$tests_timedout" ]] || echo "Timed out:" | tee -a $prev_log
for test_name in "${tests_timedout[@]}"; do
    echo "  - $test_name" | tee -a $prev_log
done
[[ -z "$tests_failed" ]] || echo "Logs:"
for test_name in "${tests_failed[@]}"; do
    echo "  - $(realpath $test_name | sed 's/\.sh/.sh.log/')"
done


###############################################################################
# Print summary
echo "---------------------" | tee -a $prev_log
echo -n "Ran $count_all tests in $time_total, $count_passed passed, $count_skipped skipped, $count_failed failed" | tee -a $prev_log
[ -n "$tests_timedout" ] && (echo -n " (incl. $count_timedout timed out)" | tee -a $prev_log)
echo "" | tee -a $prev_log

# Return exit code
$success && [ $count_all -gt 0 ]
