#!/usr/bin/env bash
# temp_d=$(mktemp -d);
temp_d="/home/nikel/projects";
cd $temp_d;
# artifact_d="~/.local/bin";

export ONEAPI_ROOT="/opt/intel/oneapi";

export AMDGPU_TARGETS="gfx90c";
export AMDGPU_TARGET="gfx90c";
export CUDA_PATH="/opt/cuda";
export ROCM_PATH="/opt/rocm";


export CUDA_LIB_DIR="$CUDA_PATH/targets/x86_64-linux/lib";
export CUDA_LD_DIR="$CUDA_LIB_DIR/stubs";

export CLBlast_DIR="/usr/lib/cmake/CLBlast";

export HIP_PLATFORM="amd";

export HSA_ENABLE_SDMA="0";
export HCC_AMDGPU_TARGETS="gfx90c";
export HCC_AMDGPU_TARGET="gfx90c";
export LLAMA_HIP_UMA="1";
export LLAMA_HIPBLAS="1";
export ROC_ENABLE_PRE_VEGA="1";

export OLLAMA_HACK_PATH="$temp_d/force-host-alloction-APU";
export OLLAMA_PATH="$temp_d/ollama";
