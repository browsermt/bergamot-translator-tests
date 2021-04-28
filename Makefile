THREADS=16

GIT_MOSES_SCRIPTS=http://github.com/marian-nmt/moses-scripts.git
GIT_SUBWORD_NMT=http://github.com/rsennrich/subword-nmt.git
GIT_CPU_FEATURES=https://github.com/google/cpu_features.git

# Empty value means that all data and models will be downloaded
TARBALLS=

.PHONY: install pip tools models data run
.SECONDARY:


#####################################################################

run: install
	bash ./run_brt.sh

install: tools models data

tools: pip
	mkdir -p $@
	git -C $@/moses-scripts pull || git clone $(GIT_MOSES_SCRIPTS) $@/moses-scripts
	git -C $@/subword-nmt pull   || git clone $(GIT_SUBWORD_NMT) $@/subword-nmt
	git -C $@/cpu-features pull || \
			(git clone $(GIT_CPU_FEATURES) $@/cpu-features \
			&&  mkdir -p $@/cpu-features/build \
			&& cd $@/cpu-features/build \
			&& cmake .. && make -j2)

pip: requirements.txt
	python3 -m pip install --user -r $<

models:
	mkdir -p $@
	cd $@ && bash ./download-models.sh # $(TARBALLS)

data:
	mkdir -p $@
	cd $@ && bash ./download-data.sh # $(TARBALLS)

clean:
	git clean -x -d -f tests
	rm -f data/*.tar.gz models/*.tar.gz

clean-all:
	git clean -x -d -f
