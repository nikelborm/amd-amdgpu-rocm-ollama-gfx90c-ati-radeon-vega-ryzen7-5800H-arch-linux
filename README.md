# amd-amdgpu-rocm-ollama-gfx90c-ati-radeon-vega-ryzen7-5800H-arch-linux

~~WORKING~~ version of Ollama for AMD Ryzen 7 5800H CPU with integrated AMD ATI Radeon Vega (gfx90c) GPU with optimizations for this specific CPU and GPU: ROCM=on IntelOneAPI=on AVX=on AVX2=on F16C=on FMA=on SSSE3=on;

Tested on Arch Linux

Relevant projects:

1. [ollama/ollama](https://github.com/ollama/ollama)
2. [segurac/force-host-alloction-APU](https://github.com/segurac/force-host-alloction-APU)

## UPD

Fuck this shit. It worked for 30 fucking minutes and then forever died without me ever being able to reproduce the working state. If you have no discrete GPU and only this CPU, give up and buy a graphics card / rent a server. It's not worth it to attempt to make it work.

## TODO

1. check [rjmalagon/ollama-linux-amd-apu](https://github.com/rjmalagon/ollama-linux-amd-apu)
2. check [likelovewant/ollama-for-amd](https://github.com/likelovewant/ollama-for-amd)
