#!/usr/bin/env bash

# gfx902,gfx903

# find ./ -type f -name "*cuda*.so"
# find /home/nikel/projects/ollama/ -type f -name "*.so"

# probably overwrite /sys/module/amdgpu/version with /sys/module/amdgpu/srcversion ?

# all existing
# pacman -Fl|grep /icx

# currently present
# pacman -Ql|grep /icx


# TODO: steal shit from here I guess?
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=ollama-rocm-git

# TODO: also add patcher from here to fix stupid warnings https://github.com/ROCm/rocminfo/issues/69


. ./common.sh

# go clean -cache
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
export OLLAMA_CUSTOM_CPU_DEFS=" -DLLAMA_AVX=on -DLLAMA_AVX2=on -DLLAMA_F16C=on -DLLAMA_FMA=on -DLLAMA_SSSE3=on -DLLAMA_LTO=on -DLLAMA_HIPBLAS=1 -DLLAMA_HIP_UMA=1 -DAMDGPU_TARGETS=gfx90c -DCMAKE_BUILD_TYPE=Release";
export OLLAMA_CUSTOM_CPU_DEFS+=" -DGGML_AVX=on  -DGGML_AVX2=on  -DGGML_F16C=on  -DGGML_FMA=on  -DGGML_SSSE3=on  -DGGML_LTO=on  -DGGML_HIPBLAS=1  -DGGML_HIP_UMA=1";
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





#cgo CFLAGS: -O2 -std=c11 -DGGML_BUILD=1 -DNDEBUG -DLOG_DISABLE_LOGS -DGGML_USE_LLAMAFILE
#cgo CXXFLAGS: -O2 -std=c++11 -DGGML_BUILD=1 -DNDEBUG -DLOG_DISABLE_LOGS -DGGML_USE_LLAMAFILE

#cgo amd64,avx CFLAGS: -mavx
#cgo amd64,avx CXXFLAGS: -mavx
#cgo amd64,avx2 CFLAGS: -mavx2 -mfma
#cgo amd64,avx2 CXXFLAGS: -mavx2 -mfma
#cgo amd64,f16c CFLAGS: -mf16c
#cgo amd64,f16c CXXFLAGS: -mf16c
#cgo amd64,fma CFLAGS: -mfma
#cgo amd64,fma CXXFLAGS: -mfma

#cgo avx CFLAGS: -mavx
#cgo avx CXXFLAGS: -mavx

#cgo avx2 CFLAGS: -mavx2 -mfma -mf16c
#cgo avx2 CXXFLAGS: -mavx2 -mfma -mf16c

#cgo linux CFLAGS: -D_GNU_SOURCE
#cgo linux CXXFLAGS: -D_GNU_SOURCE

#cgo linux,amd64 LDFLAGS: -L${SRCDIR}/build/Linux/amd64
#cgo linux,amd64 LDFLAGS: -L${SRCDIR}/build/Linux/amd64

#cgo linux,rocm LDFLAGS: -L/opt/rocm/lib -lpthread -ldl -lrt -lresolv

#cgo rocm CFLAGS: -DGGML_USE_CUDA -DGGML_USE_HIPBLAS -DGGML_CUDA_DMMV_X=32 -DGGML_CUDA_PEER_MAX_BATCH_SIZE=128 -DGGML_CUDA_MMV_Y=1 -DGGML_BUILD=1
#cgo rocm CXXFLAGS: -DGGML_USE_CUDA -DGGML_USE_HIPBLAS -DGGML_CUDA_DMMV_X=32 -DGGML_CUDA_PEER_MAX_BATCH_SIZE=128 -DGGML_CUDA_MMV_Y=1 -DGGML_BUILD=1
#cgo rocm LDFLAGS: -L${SRCDIR} -lggml_rocm -lhipblas -lamdhip64 -lrocblas







goflags='-buildmode=pie -trimpath -mod=readonly -modcacherw'
ldflags="-linkmode=external -X github.com/ollama/ollama/server.mode=release"

sacs; # my special git alias, can be disabled for you

# git clone git@github.com:ollama/ollama.git $OLLAMA_PATH
cd $OLLAMA_PATH;
git pull;
# git submodule update --init --recursive;
git submodule update --recursive --remote;
git clean -Xfd ./;

sed -i "s/-j8/-j$CMAKE_BUILD_PARALLEL_LEVEL/" llm/generate/gen_common.sh

# To find motherfuckers, that break your flags:
# c; grep -inE20 '(OLLAMA_CUSTOM_ROCM_DEFS|OLLAMA_CUSTOM_CPU_DEFS|COMMON_CPU_DEFS|COMMON_CMAKE_DEFS|CMAKE_DEFS|-DLLAMA_AVX=on|-DLLAMA_AVX2=on|-DLLAMA_F16C=on|-DLLAMA_FMA=on|-DLLAMA_SSSE3=on|-DLLAMA_LTO=on|-DLLAMA_HIPBLAS=1|-DGGML_AVX=on|-DGGML_AVX2=on|-DGGML_F16C=on|-DGGML_FMA=on|-DGGML_SSSE3=on|-DGGML_LTO=on|-DGGML_HIPBLAS=1|-DLLAMA_AVX=off|-DLLAMA_AVX2=off|-DLLAMA_F16C=off|-DLLAMA_FMA=off|-DLLAMA_SSSE3=off|-DLLAMA_LTO=off|-DLLAMA_HIPBLAS=0|-DGGML_AVX=off|-DGGML_AVX2=off|-DGGML_F16C=off|-DGGML_FMA=off|-DGGML_SSSE3=off|-DGGML_LTO=off|-DGGML_HIPBLAS=0)' {llm/generate/gen_linux.sh,docs/development.md,llm/generate/gen_common.sh}

# cd llm/llama.cpp/;
# HIPCXX="$(hipconfig -l)/clang" HIP_PATH="$(hipconfig -R)" cmake -S . -B build -DGGML_HIPBLAS=ON -DGGML_HIP_UMA=ON -DAMDGPU_TARGETS=gfx90c -DCMAKE_BUILD_TYPE=Release \
#   && cmake --build build --config Release -- -j$CMAKE_BUILD_PARALLEL_LEVEL


go env -w "CGO_CFLAGS_ALLOW=-mfma|-mf16c"
go env -w "CGO_CXXFLAGS_ALLOW=-mfma|-mf16c"
# make ggml_hipblas.so
# go build -tags=avx,avx2,rocm .

go generate -tags=oneapi,cpu,avx,avx2,rocm ./...;

rm $OLLAMA_ROCM_RUNNER_LIB_DIR/libggml_rocm.so
ln $OLLAMA_ROCM_RUNNER_LIB_DIR/libggml.so $OLLAMA_ROCM_RUNNER_LIB_DIR/libggml_rocm.so

go build $goflags -ldflags="$ldflags" -tags=oneapi,cpu,avx,avx2,rocm .


# git clone git@github.com:segurac/force-host-alloction-APU.git $OLLAMA_HACK_PATH;
cd $OLLAMA_HACK_PATH;
git pull;
hipcc forcegttalloc.c -o libforcegttalloc.so -shared -fPIC;

# sudo usermod -aG render $USER;

cd ~/projects/amd-amdgpu-rocm-ollama-gfx90c-ati-radeon-vega-ryzen7-5800H-arch-linux
