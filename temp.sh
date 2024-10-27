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

# temp_d=$(mktemp -d)
temp_d="/home/nikel/projects"
cd $temp_d
# artifact_d="~/.local/bin"




rm -rf ~/.cache/ccache/;
rm -rf ~/.cache/go-build/;
export GGML_CCACHE="OFF"

export ONEAPI_ROOT="/opt/intel/oneapi";
export OLLAMA_SKIP_ONEAPI_GENERATE="0";
export OLLAMA_SKIP_CUDA_GENERATE="1";
export OLLAMA_SKIP_STATIC_GENERATE="0";
export OLLAMA_SKIP_CPU_GENERATE="0";
export OLLAMA_CUSTOM_CPU_DEFS="-DLLAMA_AVX=on -DLLAMA_AVX2=on -DLLAMA_F16C=on -DLLAMA_FMA=on -DLLAMA_SSSE3=on -DLLAMA_LTO=on -DLLAMA_HIPBLAS=1 -DAMDGPU_TARGETS=gfx90c -DCMAKE_BUILD_TYPE=Release";
export OLLAMA_CUSTOM_CPU_DEFS=" -DGGML_AVX=on  -DGGML_AVX2=on  -DGGML_F16C=on  -DGGML_FMA=on  -DGGML_SSSE3=on  -DGGML_LTO=on  -DGGML_HIPBLAS=1 $OLLAMA_CUSTOM_CPU_DEFS";
# To see what's supported for your cpu:
# lscpu | grep -iE '(AVX|VNNI|AVX2|AVX512|VBMI|VNNI|FMA|NEON|ARM|FMA|F16C|VA|FP16|WASM|SIMD|BLAS|SSE3|SSSE3|VSX)';



# To get codename of your gpu target
# rocminfo
export AMDGPU_TARGETS="gfx90c";
export AMDGPU_TARGET="gfx90c";
export CUDA_PATH="/opt/cuda";
export ROCM_PATH="/opt/rocm";
export ROCM_LLVM_BIN_PATH="$ROCM_PATH/lib/llvm/bin"

export CC="$ROCM_LLVM_BIN_PATH/clang";
export CXX="$ROCM_LLVM_BIN_PATH/clang++";
export CMAKE_C_COMPILER="$ROCM_LLVM_BIN_PATH/clang";
export CMAKE_CXX_COMPILER="$ROCM_LLVM_BIN_PATH/clang++";

export CLBlast_DIR="/usr/lib/cmake/CLBlast";
# export CXX="$ROCM_PATH/bin/hipcc";
# export CC="$ROCM_PATH/bin/hipcc";
# export CMAKE_CXX_COMPILER="$ROCM_PATH/bin/hipcc";
# export CMAKE_C_COMPILER="$ROCM_PATH/bin/hipcc";
export CFLAGS+=' -w -fcf-protection=none';
export CXXFLAGS+=' -w -fcf-protection=none';
export CUDA_LIB_DIR="$CUDA_PATH/targets/x86_64-linux/lib";
export CUDA_LD_DIR="$CUDA_LIB_DIR/stubs";
export LDFLAGS+=" -L$CUDA_LD_DIR";

export CGO_CFLAGS="$CFLAGS" CGO_CPPFLAGS="$CPPFLAGS" CGO_CXXFLAGS="$CXXFLAGS" CGO_LDFLAGS="$LDFLAGS"

goflags='-buildmode=pie -trimpath -mod=readonly -modcacherw'
ldflags="-linkmode=external -X github.com/ollama/ollama/server.mode=release"

export HIP_PLATFORM="amd";
export PATH="$OLLAMA_PATH:$PATH";

export MAKEFLAGS="--jobs=$(nproc)";
export CMAKE_BUILD_PARALLEL_LEVEL="$(nproc)";
export PATH="$ROCM_LLVM_BIN_PATH:/usr/lib/ccache/bin:$PATH";

export HSA_ENABLE_SDMA="0";
export HCC_AMDGPU_TARGETS="gfx900";
export HCC_AMDGPU_TARGET="gfx900";
export LLAMA_HIP_UMA="1";
export LLAMA_HIPBLAS="1";
export ROC_ENABLE_PRE_VEGA="1";
export HSA_OVERRIDE_GFX_VERSION="9.0.0";


# git clone git@github.com:ollama/ollama.git $OLLAMA_PATH
cd $OLLAMA_PATH;
git pull;
# git submodule update --init --recursive;
git submodule update --recursive --remote;
git clean -Xfd ./;
go generate -tags rocm ./...;
go build .;
# go build -tags rocm;
go build $goflags -ldflags="$ldflags" -tags rocm

sudo usermod -aG render $USER;

export OLLAMA_HACK_PATH="$temp_d/force-host-alloction-APU"
# git clone git@github.com:segurac/force-host-alloction-APU.git $OLLAMA_HACK_PATH;
cd $OLLAMA_HACK_PATH;
git pull;
hipcc forcegttalloc.c -o libforcegttalloc.so -shared -fPIC;


export OLLAMA_HOST="http://0.0.0.0:11434";
export OLLAMA_ORIGINS='*';
export LD_PRELOAD="$OLLAMA_HACK_PATH/libforcegttalloc.so";

export OLLAMA_PATH="$temp_d/ollama"


export LIBRARY_PATH="$CUDA_LD_DIR:$OLLAMA_PATH/dist/linux-amd64/lib/ollama/runners/rocm:$LIBRARY_PATH";
export LD_LIBRARY_PATH="$CUDA_LD_DIR:$OLLAMA_PATH/dist/linux-amd64/lib/ollama/runners/rocm:$LD_LIBRARY_PATH";

ollama_binary=$(which ollama);
sudo $ollama_binary serve;
