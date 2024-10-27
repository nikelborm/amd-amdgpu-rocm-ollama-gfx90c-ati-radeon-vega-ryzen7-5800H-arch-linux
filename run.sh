#!/usr/bin/env bash
. ./common.sh

export OLLAMA_HOST="http://0.0.0.0:11434";
export OLLAMA_ORIGINS='*';
export LD_PRELOAD="$OLLAMA_HACK_PATH/libforcegttalloc.so";


export PATH="$OLLAMA_PATH:$PATH";
export HSA_OVERRIDE_GFX_VERSION="9.0.0";

export LIBRARY_PATH="$CUDA_LD_DIR:$OLLAMA_PATH/dist/linux-amd64/lib/ollama/runners/rocm:$LIBRARY_PATH";
export LD_LIBRARY_PATH="$CUDA_LD_DIR:$OLLAMA_PATH/dist/linux-amd64/lib/ollama/runners/rocm:$LD_LIBRARY_PATH";


sudo $OLLAMA_PATH/ollama serve;
