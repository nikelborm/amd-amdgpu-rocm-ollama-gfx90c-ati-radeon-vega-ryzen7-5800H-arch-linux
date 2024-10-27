#!/usr/bin/env bash

source /home/nikel/projects/amd-amdgpu-rocm-ollama-gfx90c-ati-radeon-vega-ryzen7-5800H-arch-linux/common.sh;

export OLLAMA_HOST="http://0.0.0.0:11434";
export OLLAMA_ORIGINS='*';

export PATH="$OLLAMA_PATH:$PATH";
export HSA_OVERRIDE_GFX_VERSION="9.0.0";

alias ollama="env LD_PRELOAD="$OLLAMA_HACK_PATH/libforcegttalloc.so" ollama";
