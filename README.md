EN VERSION
Ollama + ROCm 7.1 for AMD MI50 (gfx906) – Docker image

This Docker image contains:

Ubuntu 24.04 (minimal rootfs)
AMD ROCm 7.1 userspace (rocm, hip, without DKMS / kernel modules)
Ollama 0.12.3 with the ROCm bundle
Environment tuned for AMD MI50 (gfx906)
The goal is to run Ollama inside Docker with full ROCm support on MI50 so that inference runs on the GPU instead of the CPU.

Requirements on the host
Ubuntu 22.04 / 24.04 (tested on 24.04)
Installed and working ROCm on the host (AMD MI50 – gfx906)
Exposed devices:
/dev/kfd
/dev/dri/renderD128
/dev/dri/renderD129 (or other /dev/dri/renderD* depending on your setup)
Your user added to the "video" group (for GPU device access)
Note: This image does not include kernel drivers. It uses the host kernel + drivers via --device=/dev/kfd and /dev/dri/renderD*.

Build the image
git clone https://github.com/xxDoman/ollama-amd-mi50.git
cd ollama-amd-mi50
docker build -t ollama-amd-rocm71 .

Run the container
docker run -d --name ollama-amd \
--device=/dev/kfd \
--device=/dev/dri/renderD128 \
--device=/dev/dri/renderD129 \
--group-add video \
--ipc=host \
-p 11435:11434 \
ollama-amd-rocm71

Check the logs:
docker logs -n 80 ollama-amd

You should see something like:
amdgpu is supported gpu_type=gfx906
inference compute id=GPU-... library=rocm compute=gfx906 ...

Important fields:

amdgpu is supported
library=rocm
compute=gfx906
This means Ollama is using the ROCm backend on MI50, not CPU.

If you see:
no suitable rocm found, falling back to CPU
inference compute ... library=cpu

then the GPU backend is not active (check host ROCm installation and devices passed to Docker).

Test a model
Inside the container:
docker exec -it ollama-amd /bin/bash
ollama run llama3

While the model is generating text, on the host run:
/opt/rocm/bin/rocm-smi

Run it a few times (arrow up + Enter).
If VRAM usage and power/activity of MI50 increase, the model is running on the GPU.

Why not use the default "ollama/ollama" image?
The official "ollama/ollama" Docker image:

ships with CPU / CUDA support,
does not include ROCm userspace libraries,
therefore on AMD MI50 it prints:
no compatible rocm library found
... falling back to CPU
This Dockerfile adds ROCm 7.1 userspace and configures Ollama to use library=rocm on gfx906.

Known limitations
Designed and tested for AMD MI50 (gfx906) + ROCm 7.1.
May work with other Vega 20 / gfx906 cards, but is not guaranteed.
Host must already have a working ROCm installation and expose /dev/kfd and /dev/dri/renderD* to the container.
===============================================================
PL VERSION
Ollama + ROCm 7.1 dla AMD MI50 (gfx906) – obraz Dockera

Ten obraz Dockera zawiera:

Ubuntu 24.04 (minimalny system)
AMD ROCm 7.1 w przestrzeni użytkownika (rocm, hip, bez modułów kernela / DKMS)
Ollama 0.12.3 z bundlem ROCm
Konfigurację środowiska pod kartę AMD MI50 (gfx906)
Celem jest uruchomienie Ollamy w Dockerze z pełnym wsparciem ROCm na MI50, tak aby inferencja szła po GPU (ROCm), a nie po CPU.

Wymagania po stronie hosta
Ubuntu 22.04 / 24.04 (testowane na 24.04)
Zainstalowany i działający ROCm na hoście (karta AMD MI50 – gfx906)
Udostępnione urządzenia:
/dev/kfd
/dev/dri/renderD128
/dev/dri/renderD129 (lub inne /dev/dri/renderD* zależnie od konfiguracji)
Użytkownik w grupie "video" (dostęp do urządzeń GPU)
Uwaga: Ten obraz nie zawiera sterowników kernela. Korzysta z kernela i sterowników z hosta poprzez --device=/dev/kfd oraz /dev/dri/renderD*.

Budowanie obrazu
git clone https://github.com/xxDoman/ollama-amd-mi50.git
cd ollama-amd-mi50
docker build -t ollama-amd-rocm71 .

Uruchamianie kontenera
docker run -d --name ollama-amd \
--device=/dev/kfd \
--device=/dev/dri/renderD128 \
--device=/dev/dri/renderD129 \
--group-add video \
--ipc=host \
-p 11435:11434 \
ollama-amd-rocm71

Sprawdzenie logów:
docker logs -n 80 ollama-amd

Jeśli wszystko działa, zobaczysz m.in.:
amdgpu is supported gpu_type=gfx906
inference compute id=GPU-... library=rocm compute=gfx906 ...

Kluczowe fragmenty:

amdgpu is supported
library=rocm
compute=gfx906
To znaczy, że Ollama korzysta z backendu ROCm na MI50, a nie z CPU.

Jeśli zobaczysz:
no suitable rocm found, falling back to CPU
inference compute ... library=cpu

to GPU nie jest używane (trzeba sprawdzić instalację ROCm na hoście i przekazywane urządzenia do Dockera).

Test modelu
W kontenerze:
docker exec -it ollama-amd /bin/bash
ollama run llama3

W trakcie generacji tekstu, na hoście:
/opt/rocm/bin/rocm-smi

Uruchom kilka razy (strzałka w górę + Enter).
Jeśli zużycie VRAM i aktywność MI50 rosną – model liczy się na GPU.

Dlaczego nie używać domyślnego obrazu "ollama/ollama"?
Oficjalny obraz "ollama/ollama":

ma wsparcie CPU / CUDA,
nie zawiera w środku bibliotek ROCm,
dlatego na MI50 pojawia się komunikat:
no compatible rocm library found
... falling back to CPU
Ten Dockerfile dodaje userspace ROCm 7.1 i ustawia Ollamę tak, aby używała library=rocm na gfx906.

Ograniczenia
Projekt jest przygotowany i testowany dla AMD MI50 (gfx906) + ROCm 7.1.
Może działać na innych kartach Vega 20 / gfx906, ale nie jest to gwarantowane.
Host musi mieć działający ROCm i udostępniać /dev/kfd oraz /dev/dri/renderD* do kontenera.
