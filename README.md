# amd-amdgpu-rocm-ollama-gfx90c-ati-radeon-vega-ryzen7-5800H-arch-linux

~~WORKING~~ version of Ollama for AMD Ryzen 7 5800H CPU with integrated AMD ATI Radeon Vega (gfx90c) GPU with optimizations for this specific CPU and GPU: ROCM=on IntelOneAPI=on AVX=on AVX2=on F16C=on FMA=on SSSE3=on;

Tested on arch linux

Relevant projects:

1. [ollama/ollama](https://github.com/ollama/ollama)
2. [segurac/force-host-alloction-APU](https://github.com/segurac/force-host-alloction-APU)

## UPD

Fuck this shit. It worked for 30 fucking minutes and then forever died without me ever being able to reproduce the working state. It you have no discrete GPU and only this CPU, just give up and buy a graphics card / rent a server. It's not worth it to attempt to make it work.
