EN VERSION
Ollama + ROCm 7.1 for AMD MI50 (gfx906) – Docker image
This Docker image bundles:

Ubuntu 24.04 (minimal rootfs)
AMD ROCm 7.1 userspace (rocm, hip, no DKMS / kernel modules inside the container)
Ollama 0.12.3 with the ROCm backend
Environment tuned and tested for AMD Instinct MI50 (gfx906)
The goal is to run Ollama inside Docker with full ROCm support on MI50, so that inference runs on the GPU instead of the CPU.

What’s inside
Base image: ubuntu:24.04
ROCm 7.1 userspace installed from the official AMD installer:
amdgpu-install_7.1.70100-1_all.deb
using:
bash
Copy
amdgpu-install --usecase=rocm,hip --no-dkms -y
Ollama 0.12.3 installed via the official script, with:
OLLAMA_LLM_LIBRARY=rocm
OLLAMA_HOST=0.0.0.0:11434
Important:
This image does not ship AMD kernel drivers. It relies on the host kernel + drivers and just mounts the GPU devices into the container.

Host requirements
Linux host (tested on Ubuntu 24.04, should also work on 22.04)
A ROCm‑supported AMD GPU, tested on:
AMD Instinct MI50 (gfx906)
Working ROCm installation on the host:
amdgpu kernel module loaded
/dev/kfd present
/dev/dri/renderD* devices present (e.g. renderD128, renderD129)
Your user in the video group (for GPU device access)
The container uses the host kernel and drivers via:

--device=/dev/kfd
--device=/dev/dri/renderD*
Quick build (from source)
If you want to build locally:

bash
Copy
git clone https://github.com/xxDoman/ollama-amd-mi50.git
cd ollama-amd-mi50
docker build -t ollama-amd-rocm71 .
Otherwise you can simply pull from Docker Hub:

bash
Copy
docker pull xxdoman/ollama-amd-rocm71:latest
Running the container
Basic run (no persistent volume):

bash
Copy
docker run -d \
  --name ollama-amd-rocm71 \
  --device=/dev/kfd \
  --device=/dev/dri/renderD128 \
  --device=/dev/dri/renderD129 \
  --group-add video \
  -p 11434:11434 \
  xxdoman/ollama-amd-rocm71 \
  ollama serve
If you want persistent models (recommended):

bash
Copy
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
Checking logs
bash
Copy
docker logs -n 80 ollama-amd-rocm71
You should see lines like:

text
Copy
amdgpu is supported gpu_type=gfx906
inference compute id=GPU-... library=rocm compute=gfx906 total="32.0 GiB"
Listening on [::]:11434 (version 0.12.3)
Key fields:

amdgpu is supported
library=rocm
compute=gfx906
This means Ollama is using the ROCm backend on MI50, not CPU.

If instead you see something like:

text
Copy
no suitable rocm found, falling back to CPU
inference compute ... library=cpu
then the GPU backend is not active – check:

ROCm installation on the host,
devices passed via --device=/dev/kfd and --device=/dev/dri/renderD*.
Testing with a model
Inside the container:

bash
Copy
docker exec -it ollama-amd-rocm71 /bin/bash
ollama pull llama3.2:1b
ollama list
ollama run llama3.2:1b
From the host (HTTP API test):

bash
Copy
curl http://localhost:11434/api/tags
and:

bash
Copy
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2:1b",
    "prompt": "Hello from MI50!",
    "stream": false
  }'
Example response (shortened):

json
Copy
{
  "model": "llama3.2:1b",
  "response": "Welcome to the world of cricket. I'm happy to chat with you...",
  "done": true
}
While the model is generating, on the host run:

bash
Copy
/opt/rocm/bin/rocm-smi
If MI50 VRAM usage and GPU activity go up, inference is running on the GPU.

Why not just use the official ollama/ollama image?
The official ollama/ollama image:

ships with CPU / CUDA support,
does not include ROCm userspace libraries.
On AMD MI50 it typically prints:

text
Copy
no compatible rocm library found ... falling back to CPU
This Dockerfile:

adds ROCm 7.1 userspace inside the container,
sets OLLAMA_LLM_LIBRARY=rocm,
is tested specifically on gfx906 (MI50).
Known limitations
Designed and tested for:
AMD MI50 (gfx906) + ROCm 7.1 on the host.
May work on other Vega 20 / gfx906 cards, but not guaranteed.
Host must have a working ROCm installation and expose:
/dev/kfd
/dev/dri/renderD*
The image is large (~30.7 GB) – this is a conscious trade‑off for a full ROCm userspace + Ollama bundle: “30 GB of AMD happiness”.
PL VERSION
Ollama + ROCm 7.1 dla AMD MI50 (gfx906) – obraz Dockera
Ten obraz Dockera zawiera:

Ubuntu 24.04 (minimalny system)
AMD ROCm 7.1 w przestrzeni użytkownika (rocm, hip, bez modułów kernela / DKMS wewnątrz kontenera)
Ollama 0.12.3 z backendem ROCm
Konfigurację środowiska pod kartę AMD MI50 (gfx906)
Celem jest uruchomienie Ollamy w Dockerze z pełnym wsparciem ROCm na MI50, tak aby inferencja szła po GPU, a nie po CPU.

Co jest w środku
Obraz bazowy: ubuntu:24.04
Userspace ROCm 7.1 z oficjalnego instalatora AMD:
amdgpu-install_7.1.70100-1_all.deb
instalowany poleceniem:
bash
Copy
amdgpu-install --usecase=rocm,hip --no-dkms -y
Ollama 0.12.3 zainstalowana oficjalnym skryptem, z:
OLLAMA_LLM_LIBRARY=rocm
OLLAMA_HOST=0.0.0.0:11434
Uwaga:
Obraz nie zawiera sterowników kernela. Korzysta z kernela i sterowników z hosta, a GPU jest podawane przez --device=/dev/kfd oraz /dev/dri/renderD*.

Wymagania po stronie hosta
Linux, testowane na Ubuntu 24.04 (powinno działać też na 22.04)
GPU AMD wspierane przez ROCm 7.1, testowane na:
AMD Instinct MI50 (gfx906)
Działający ROCm na hoście:
załadowany moduł amdgpu
obecne /dev/kfd
obecne /dev/dri/renderD* (np. renderD128, renderD129)
Użytkownik w grupie video (dostęp do urządzeń GPU)
Kontener korzysta z kernela/sterowników hosta poprzez:

--device=/dev/kfd
--device=/dev/dri/renderD*
Budowanie lokalnie
Jeśli chcesz zbudować obraz samodzielnie:

bash
Copy
git clone https://github.com/xxDoman/ollama-amd-mi50.git
cd ollama-amd-mi50
docker build -t ollama-amd-rocm71 .
Albo po prostu pobierz z Docker Huba:

bash
Copy
docker pull xxdoman/ollama-amd-rocm71:latest
Uruchamianie kontenera
Prosta wersja (bez trwałych modeli):

bash
Copy
docker run -d \
  --name ollama-amd-rocm71 \
  --device=/dev/kfd \
  --device=/dev/dri/renderD128 \
  --device=/dev/dri/renderD129 \
  --group-add video \
  -p 11434:11434 \
  xxdoman/ollama-amd-rocm71 \
  ollama serve
Wersja z trwałymi modelami (volume):

bash
Copy
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
Sprawdzenie logów
bash
Copy
docker logs -n 80 ollama-amd-rocm71
Jeśli wszystko działa, zobaczysz m.in.:

text
Copy
amdgpu is supported gpu_type=gfx906
inference compute id=GPU-... library=rocm compute=gfx906 total="32.0 GiB"
Listening on [::]:11434 (version 0.12.3)
Kluczowe fragmenty:

amdgpu is supported
library=rocm
compute=gfx906
To znaczy, że Ollama korzysta z backendu ROCm na MI50, a nie z CPU.

Jeśli pojawi się:

text
Copy
no suitable rocm found, falling back to CPU
inference compute ... library=cpu
to GPU nie jest używane – trzeba sprawdzić:

instalację ROCm na hoście,
przekazywane urządzenia --device=/dev/kfd i /dev/dri/renderD*.
Test modelu
W kontenerze:

bash
Copy
docker exec -it ollama-amd-rocm71 /bin/bash
ollama pull llama3.2:1b
ollama list
ollama run llama3.2:1b
Z hosta (przez HTTP API):

bash
Copy
curl http://localhost:11434/api/tags
oraz:

bash
Copy
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2:1b",
    "prompt": "Hello from MI50!",
    "stream": false
  }'
Jeśli w odpowiedzi dostaniesz tekst – wszystko działa.

Podczas generacji, na hoście możesz sprawdzić:

bash
Copy
/opt/rocm/bin/rocm-smi
Jeżeli rośnie zużycie VRAM i aktywność MI50 – model liczy się na GPU.

Dlaczego nie używać domyślnego obrazu ollama/ollama?
Oficjalny obraz ollama/ollama:

ma wsparcie CPU / CUDA,
nie zawiera w środku userspace ROCm.
Na MI50 kończy się to komunikatem:

text
Copy
no compatible rocm library found ... falling back to CPU
Ten Dockerfile:

dodaje ROCm 7.1 userspace wewnątrz kontenera,
ustawia Ollamę tak, aby używała library=rocm na gfx906,
jest przetestowany na AMD MI50 (gfx906).
Ograniczenia
Projekt przygotowany i testowany dla:
AMD MI50 (gfx906) + ROCm 7.1 na hoście.
Może działać na innych kartach Vega 20 / gfx906, ale nie ma gwarancji.
Host musi mieć działający ROCm i udostępniać:
/dev/kfd
/dev/dri/renderD*
Obraz jest duży (~30,7 GB) – to świadomy „overkill”: pełny ROCm 7.1 + Ollama w jednym kontenerze, żeby po prostu działało na MI50.
Jeśli chcesz, mogę też dopasować ten README pod dokładną strukturę Twojego repo (np. sekcja „Tags”, „Changelog”, link do Docker Huba itd.).
