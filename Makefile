THREADS=16

GIT_MOSES_SCRIPTS=http://github.com/marian-nmt/moses-scripts.git
GIT_SUBWORD_NMT=http://github.com/rsennrich/subword-nmt.git

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

pip: requirements.txt
	python3 -m pip install --user -r $<

models:
	mkdir -p $@
	cd $@ && bash ./download-models.sh # $(TARBALLS)
	cd deen/ende.student.tiny11
	gunzip lex.s2t.gz # wasm build doesn't support zipped input
	cd ../..

data:
	mkdir -p $@
	cd $@ && bash ./download-data.sh # $(TARBALLS)

clean:
	git clean -x -d -f tests
	rm -f data/*.tar.gz models/*.tar.gz

clean-all:
	git clean -x -d -f
