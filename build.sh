#!/usr/bin/env bash

# gfx902,gfx903

# find ./ -type f -name "*cuda*.so"
# find /home/nikel/ollama/ -type f -name "*.so"

# probably overwrite /sys/module/amdgpu/version with /sys/module/amdgpu/srcversion ?

# all existing
# pacman -Fl|grep /icx

# currently present
# pacman -Ql|grep /icx


# TODO: steal shit from here I guess?
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=ollama-rocm-git

# TODO: also add patcher from here to fix stupid warnings https://github.com/ROCm/rocminfo/issues/69


. ./common.sh

# rm -rf ~/.cache/ccache/;
# rm -rf ~/.cache/go-build/;
# export GGML_CCACHE="OFF"

export MAKEFLAGS="--jobs=$(nproc)";
export CMAKE_BUILD_PARALLEL_LEVEL="$(nproc)";

# empty string means will not be skipped
export OLLAMA_SKIP_ONEAPI_GENERATE="";
export OLLAMA_SKIP_CUDA_GENERATE="1";
export OLLAMA_SKIP_STATIC_GENERATE="";
export OLLAMA_SKIP_CPU_GENERATE="";
export OLLAMA_CPU_TARGET="cpu_avx2";
export ARCH='x86_64';
export OLLAMA_CUSTOM_CPU_DEFS=" -DLLAMA_AVX=on -DLLAMA_AVX2=on -DLLAMA_F16C=on -DLLAMA_FMA=on -DLLAMA_SSSE3=on -DLLAMA_LTO=on -DLLAMA_HIPBLAS=1 -DAMDGPU_TARGETS=gfx90c -DCMAKE_BUILD_TYPE=Release";
export OLLAMA_CUSTOM_CPU_DEFS+=" -DGGML_AVX=on  -DGGML_AVX2=on  -DGGML_F16C=on  -DGGML_FMA=on  -DGGML_SSSE3=on  -DGGML_LTO=on  -DGGML_HIPBLAS=1";
export LDFLAGS+=" -L$CUDA_LD_DIR";
# To see what's supported for your cpu:
# lscpu | grep -iE '(AVX|VNNI|AVX2|AVX512|VBMI|VNNI|FMA|NEON|ARM|FMA|F16C|VA|FP16|WASM|SIMD|BLAS|SSE3|SSSE3|VSX)';



# To get codename of your gpu target
# rocminfo
export ROCM_LLVM_BIN_PATH="$ROCM_PATH/lib/llvm/bin"

export CC="$ROCM_LLVM_BIN_PATH/clang";
export CXX="$ROCM_LLVM_BIN_PATH/clang++";
export CMAKE_C_COMPILER="$ROCM_LLVM_BIN_PATH/clang";
export CMAKE_CXX_COMPILER="$ROCM_LLVM_BIN_PATH/clang++";

export PATH="$ROCM_LLVM_BIN_PATH:/usr/lib/ccache/bin:$PATH";

# export CXX="$ROCM_PATH/bin/hipcc";
# export CC="$ROCM_PATH/bin/hipcc";
# export CMAKE_CXX_COMPILER="$ROCM_PATH/bin/hipcc";
# export CMAKE_C_COMPILER="$ROCM_PATH/bin/hipcc";
export CFLAGS+=' -w -fcf-protection=none';
export CXXFLAGS+=' -w -fcf-protection=none';

export CGO_CFLAGS="$CFLAGS" CGO_CPPFLAGS="$CPPFLAGS" CGO_CXXFLAGS="$CXXFLAGS" CGO_LDFLAGS="$LDFLAGS"

goflags='-buildmode=pie -trimpath -mod=readonly -modcacherw'
ldflags="-linkmode=external -X github.com/ollama/ollama/server.mode=release"

sacs; # my special git alias, can be disabled for you

# git clone git@github.com:ollama/ollama.git $OLLAMA_PATH
cd $OLLAMA_PATH;
git pull;
# git submodule update --init --recursive;
git submodule update --recursive --remote;
git clean -Xfd ./;

sed -i "s/-j8/--jobs=$CMAKE_BUILD_PARALLEL_LEVEL/" llm/generate/gen_common.sh

# To find motherfuckers, that break your flags:
# c; grep -inE20 '(OLLAMA_CUSTOM_ROCM_DEFS|OLLAMA_CUSTOM_CPU_DEFS|COMMON_CPU_DEFS|COMMON_CMAKE_DEFS|CMAKE_DEFS|-DLLAMA_AVX=on|-DLLAMA_AVX2=on|-DLLAMA_F16C=on|-DLLAMA_FMA=on|-DLLAMA_SSSE3=on|-DLLAMA_LTO=on|-DLLAMA_HIPBLAS=1|-DGGML_AVX=on|-DGGML_AVX2=on|-DGGML_F16C=on|-DGGML_FMA=on|-DGGML_SSSE3=on|-DGGML_LTO=on|-DGGML_HIPBLAS=1|-DLLAMA_AVX=off|-DLLAMA_AVX2=off|-DLLAMA_F16C=off|-DLLAMA_FMA=off|-DLLAMA_SSSE3=off|-DLLAMA_LTO=off|-DLLAMA_HIPBLAS=0|-DGGML_AVX=off|-DGGML_AVX2=off|-DGGML_F16C=off|-DGGML_FMA=off|-DGGML_SSSE3=off|-DGGML_LTO=off|-DGGML_HIPBLAS=0)' {llm/generate/gen_linux.sh,docs/development.md,llm/generate/gen_common.sh}


go env -w "CGO_CFLAGS_ALLOW=-mfma|-mf16c"
go env -w "CGO_CXXFLAGS_ALLOW=-mfma|-mf16c"

go generate -tags rocm,avx,avx2 ./...;

make ggml_hipblas.so
go build $goflags -ldflags="$ldflags" -tags rocm,avx,avx2 .


# git clone git@github.com:segurac/force-host-alloction-APU.git $OLLAMA_HACK_PATH;
cd $OLLAMA_HACK_PATH;
git pull;
hipcc forcegttalloc.c -o libforcegttalloc.so -shared -fPIC;

# sudo usermod -aG render $USER;
