#!/usr/bin/env bash
# temp_d=$(mktemp -d);
temp_d="/home/nikel/projects";
# cd $temp_d;
# artifact_d="~/.local/bin";

export ONEAPI_ROOT="/opt/intel/oneapi";

export AMDGPU_TARGET="gfx900";
export AMDGPU_TARGETS="$AMDGPU_TARGET";
export CUDA_PATH="/opt/cuda";
export ROCM_PATH="/opt/rocm";


export CUDA_LIB_DIR="$CUDA_PATH/targets/x86_64-linux/lib";
export CUDA_LD_DIR="$CUDA_LIB_DIR/stubs";

export CLBlast_DIR="/usr/lib/cmake/CLBlast";
export HIP_PLATFORM="amd";
export HSA_ENABLE_SDMA="0";
export HCC_AMDGPU_TARGET="$AMDGPU_TARGET";
export HCC_AMDGPU_TARGETS="$AMDGPU_TARGET";
export LLAMA_HIP_UMA="1";
export LLAMA_HIPBLAS="1";
export ROC_ENABLE_PRE_VEGA="1";

export OLLAMA_HACK_PATH="$temp_d/force-host-alloction-APU";
export OLLAMA_PATH="$temp_d/ollama";

export OLLAMA_LIB_DIR="$OLLAMA_PATH/dist/linux-amd64/lib/ollama"
export OLLAMA_RUNNERS_ROCM_LIB_DIR="$OLLAMA_LIB_DIR/runners/rocm"

export    LIBRARY_PATH="$OLLAMA_PATH/dist/linux-amd64-rocm/lib/ollama:$OLLAMA_RUNNERS_ROCM_LIB_DIR:$OLLAMA_LIB_DIR";
export    LIBRARY_PATH="$CUDA_LD_DIR:$LIBRARY_PATH";
export LD_LIBRARY_PATH="$OLLAMA_PATH/dist/linux-amd64-rocm/lib/ollama:$OLLAMA_RUNNERS_ROCM_LIB_DIR:$OLLAMA_LIB_DIR";
export LD_LIBRARY_PATH="$CUDA_LD_DIR:$LD_LIBRARY_PATH";
