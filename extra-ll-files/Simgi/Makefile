CLANG=$(HOME)/llvm/bin/clang
C_FILES := $(shell ls *.c)
LL_FILES := ${C_FILES:.c=.ll}
MUNGE=../../../htrace/c_source_files/munge.py

default: $(LL_FILES)
	$(MUNGE) $(LL_FILES)

%.ll: %.c
	$(CLANG)  -S  -Xclang -triple="x86_64-apple-darwin10.0.0" -emit-llvm -o $@ $<
clean:
	rm -f *.ll
