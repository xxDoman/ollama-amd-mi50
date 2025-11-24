================= README (TXT) =================

Ollama + ROCm 7.1 for AMD MI50 (gfx906)

Jedno Docker image do uruchomienia Ollama 0.12.3 z ROCm 7.1 na AMD Instinct MI50 (gfx906).

Host: Ubuntu 22.04 / 24.04 z działającym ROCm
GPU: AMD Instinct MI50 (gfx906)
Cel: inferencja na GPU (ROCm), a nie na CPU

Obraz nie zawiera sterowników kernela – używa kernela i sterowników z hosta przez urządzenia /dev/kfd oraz /dev/dri/renderD*.

ENGLISH
What this image includes
Ubuntu 24.04 (minimal)
AMD ROCm 7.1 userspace (ROCm + HIP, bez kernel modules w kontenerze)
Ollama 0.12.3 with ROCm backend
Configuration tested on AMD Instinct MI50 (gfx906)
Host requirements
You need:

Ubuntu 22.04 or 24.04
ROCm 7.1 properly installed on the host
AMD Instinct MI50 (gfx906)
Your user in the "video" group
Quick checks on the host:

ls -l /dev/kfd
ls -l /dev/dri/renderD*
groups

If ROCm is broken on the host, the container will also fall back to CPU.

Build image locally (optional)
If you want to build the image yourself:

git clone https://github.com/xxDoman/ollama-amd-mi50.git
cd ollama-amd-mi50
docker build -t ollama-amd-rocm71 .

Or pull from Docker Hub:

docker pull xxdoman/ollama-amd-rocm71:latest

Run the container
Basic run (no persistent models):

docker run -d \
--name ollama-amd-rocm71 \
--device=/dev/kfd \
--device=/dev/dri/renderD128 \
--device=/dev/dri/renderD129 \
--group-add video \
-p 11434:11434 \
xxdoman/ollama-amd-rocm71 \
ollama serve

Recommended run with persistent model location on host:

mkdir -p /opt/ollama-models

docker run -d \
--name ollama-amd-rocm71 \
--device=/dev/kfd \
--device=/dev/dri/renderD128 \
--device=/dev/dri/renderD129 \
--group-add video \
-p 11434:11434 \
-v /opt/ollama-models:/root/.ollama \
xxdoman/ollama-amd-rocm71 \
ollama serve

Ollama will be available at:
http://localhost:11434

Check logs and ROCm detection
docker logs -n 80 ollama-amd-rocm71

Look for lines similar to:

amdgpu is supported gpu_type=gfx906
inference compute id=GPU-... library=rocm compute=gfx906 total="32.0 GiB"
Listening on [::]:11434 (version 0.12.3)

This means:

GPU detected
library = rocm
compute = gfx906 (MI50)
If you see:

no suitable rocm found, falling back to CPU
inference compute ... library=cpu

then the container is running on CPU, not GPU. Check:

ROCm installation on host
devices passed: /dev/kfd and /dev/dri/renderD*
Test with a model
Enter the container:

docker exec -it ollama-amd-rocm71 /bin/bash

Pull a model:

ollama pull llama3.2:1b

List models:

ollama list

Simple test:

ollama run llama3.2:1b

HTTP API test from host:

curl http://localhost:11434/api/tags

curl -X POST http://localhost:11434/api/generate \
-H "Content-Type: application/json" \
-d '{
"model": "llama3.2:1b",
"prompt": "Hello from MI50!",
"stream": false
}'

While generating, check GPU usage on host:

/opt/rocm/bin/rocm-smi

If MI50 VRAM and activity go up, inference is running on GPU.

Why not use the official ollama/ollama image?
The official "ollama/ollama" image:

has CPU and CUDA support
does not contain ROCm userspace
On MI50 this usually results in:

no compatible rocm library found ... falling back to CPU

This image:

adds full ROCm 7.1 userspace inside the container
configures Ollama to use ROCm (library=rocm)
is tested specifically on AMD Instinct MI50 (gfx906)
Limitations
Designed and tested for AMD MI50 (gfx906) + ROCm 7.1
May work on other gfx906 / Vega 20 cards, but not guaranteed
Requires working ROCm installation on the host
Image is large (~30.7 GB): full ROCm + Ollama in one container, to "just work"
POLSKI OPIS (skrót)
Ten sam obraz, opisany po polsku.

Co zawiera:

Ubuntu 24.04
ROCm 7.1 userspace
Ollama 0.12.3 (backend ROCm)
GPU: AMD Instinct MI50 (gfx906)
Wymagania hosta:

Ubuntu 22.04 lub 24.04
zainstalowany i działający ROCm 7.1
urządzenia /dev/kfd i /dev/dri/renderD*
użytkownik w grupie "video"
Szybkie sprawdzenie:

ls -l /dev/kfd
ls -l /dev/dri/renderD*
groups

Budowanie obrazu lokalnie (opcjonalnie):

git clone https://github.com/xxDoman/ollama-amd-mi50.git
cd ollama-amd-mi50
docker build -t ollama-amd-rocm71 .

Albo pobranie z Docker Huba:

docker pull xxdoman/ollama-amd-rocm71:latest

Uruchomienie z trwałą lokalizacją modeli:

mkdir -p /opt/ollama-models

docker run -d \
--name ollama-amd-rocm71 \
--device=/dev/kfd \
--device=/dev/dri/renderD128 \
--device=/dev/dri/renderD129 \
--group-add video \
-p 11434:11434 \
-v /opt/ollama-models:/root/.ollama \
xxdoman/ollama-amd-rocm71 \
ollama serve

Ollama będzie dostępna pod adresem:
http://localhost:11434

Sprawdzenie logów:

docker logs -n 80 ollama-amd-rocm71

Szukaj m.in.:

amdgpu is supported gpu_type=gfx906
library=rocm compute=gfx906

Jeżeli jest library=cpu lub komunikat o braku ROCm, to znaczy że liczy na CPU.

Test modelu:

docker exec -it ollama-amd-rocm71 /bin/bash
ollama pull llama3.2:1b
ollama run llama3.2:1b

API z hosta:

curl http://localhost:11434/api/tags
curl -X POST http://localhost:11434/api/generate ...

GPU monitorujesz:

/opt/rocm/bin/rocm-smi
