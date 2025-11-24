# Ollama + ROCm 7.1 dla AMD MI50 (gfx906)

Pojedynczy obraz Docker do uruchomienia **Ollama 0.12.3 z ROCm 7.1** na **AMD Instinct MI50 (gfx906)**.

* Host OS: Ubuntu 22.04 / 24.04 z działającym ROCm
* GPU: AMD Instinct MI50 (gfx906)
* Cel: wnioskowanie na **GPU (ROCm)** zamiast na CPU

Obraz **nie** zawiera sterowników jądra (kernel drivers). Używa **jądra Linuksa i sterowników AMD z hosta** za pośrednictwem:
* /dev/kfd
* /dev/dri/renderD* (np. renderD128, renderD129)

-------------------------------------------
## English Documentation

### 1. What this image includes

This image contains:

* Ubuntu 24.04 (minimal rootfs)
* AMD ROCm 7.1 userspace (ROCm + HIP, no DKMS/kernel modules inside the container)
* Ollama **0.12.3** with ROCm backend
* Environment tuned and tested for **AMD Instinct MI50 (gfx906)**

> Note: The container relies on the host’s ROCm-compatible kernel and drivers. If ROCm is broken on the host, the container will also fall back to CPU.

-------------------------------------------
### 2. Host requirements

You need:

* Ubuntu 22.04 / 24.04 (tested on 24.04)
* ROCm-supported AMD GPU (tested: **AMD Instinct MI50 – gfx906**)
* Working ROCm installation on the host:
    * amdgpu kernel module loaded
    * /dev/kfd present
    * /dev/dri/renderD* present (e.g. renderD128, renderD129)
* Your user in the **video** group (for GPU device access)

**Quick checks on the host:**

bash  
ls -l /dev/kfd  
ls -l /dev/dri/renderD*  
groups  

> If ROCm is broken on the host, the container will also fall back to CPU.

-------------------------------------------
### 3. Build image locally (optional)

If you want to build the image yourself instead of pulling from Docker Hub:

bash  
git clone https://github.com/xxDoman/ollama-amd-mi50.git  
cd ollama-amd-mi50  
docker build -t ollama-amd-rocm71 .  

Or pull directly:

bash  
docker pull xxdoman/ollama-amd-rocm71:latest  

-------------------------------------------
### 4. Run the container

#### Basic run (no persistent models)

bash  
docker run -d \  
  --name ollama-amd-rocm71 \  
  --device=/dev/kfd \  
  --device=/dev/dri/renderD128 \  
  --device=/dev/dri/renderD129 \  
  --group-add video \  
  -p 11434:11434 \  
  xxdoman/ollama-amd-rocm71 \  
  ollama serve  

#### Recommended run with persistent models on host

bash  
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

Ollama will listen on:  
**http://localhost:11434**

-------------------------------------------
### 5. Check logs and ROCm detection

bash  
docker logs -n 80 ollama-amd-rocm71  

You should see something like:

text  
amdgpu is supported gpu_type=gfx906  
inference compute id=GPU-... library=rocm compute=gfx906 total="32.0 GiB"  
Listening on [::]:11434 (version 0.12.3)  

This means:
* GPU detected
* **library=rocm**
* **compute=gfx906** (MI50)

If you see instead:

text  
no suitable rocm found, falling back to CPU  
inference compute ... library=cpu  

then the container is running on CPU, not GPU. Check:
* ROCm installation on the host
* Devices passed to the container: /dev/kfd and /dev/dri/renderD*

-------------------------------------------
### 6. Test with a model

#### Inside the container

bash  
docker exec -it ollama-amd-rocm71 /bin/bash  

ollama pull llama3.2:1b  
ollama list  
ollama run llama3.2:1b  

#### HTTP API test from host

bash  
curl http://localhost:11434/api/tags  

bash  
curl -X POST http://localhost:11434/api/generate \  
  -H "Content-Type: application/json" \  
  -d '{  
    "model": "llama3.2:1b",  
    "prompt": "Hello from MI50!",  
    "stream": false  
  }'  

While generating, you can check GPU usage on host:

bash  
/opt/rocm/bin/rocm-smi  

If MI50 VRAM and activity go up, inference is running on GPU.

-------------------------------------------
### 7. Why not use the official ollama/ollama image?

The official Docker image:
* has CPU / CUDA support,
* does not include ROCm userspace.

On MI50 this usually results in:

text  
no compatible rocm library found ... falling back to CPU  

This image:
* adds full ROCm 7.1 userspace inside the container,
* configures Ollama to use ROCm backend (**library=rocm**),
* is tested specifically on AMD Instinct MI50 (gfx906).

-------------------------------------------
### 8. Limitations

* Designed and tested for AMD MI50 (gfx906) + ROCm 7.1.
* May work on other gfx906 / Vega 20 cards, but not guaranteed.
* Requires a working ROCm installation on the host.
* Image is large (~30.7 GB): full ROCm + Ollama in one container so it “just works”.

-------------------------------------------
-------------------------------------------

## Polski opis (skrót)

### Co zawiera obraz

* Ubuntu 24.04
* ROCm 7.1 (userspace)
* Ollama 0.12.3 (backend ROCm)
* Konfiguracja pod AMD Instinct MI50 (gfx906)

> Obraz nie zawiera modułów kernela – korzysta ze sterowników z hosta przez /dev/kfd i /dev/dri/renderD*.

### Wymagania hosta

* Ubuntu 22.04 lub 24.04
* zainstalowany i działający ROCm 7.1
* dostępne urządzenia /dev/kfd i /dev/dri/renderD*
* użytkownik w grupie **video**

**Szybkie sprawdzenie:**

bash  
ls -l /dev/kfd  
ls -l /dev/dri/renderD*  
groups  

### Budowanie lokalnie (opcjonalne)

bash  
git clone https://github.com/xxDoman/ollama-amd-mi50.git  
cd ollama-amd-mi50  
docker build -t ollama-amd-rocm71 .  

Albo pobranie z Docker Huba:

bash  
docker pull xxdoman/ollama-amd-rocm71:latest  

### Uruchomienie z trwałą lokalizacją modeli

bash  
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

Ollama będzie dostępna pod adresem: **http://localhost:11434**

### Logi i GPU

bash  
docker logs -n 80 ollama-amd-rocm71  

Szukaj:

text  
amdgpu is supported gpu_type=gfx906  
library=rocm compute=gfx906  

Jeżeli jest **library=cpu** lub komunikat o braku ROCm, to liczy na CPU.

**Monitorowanie GPU:**

bash  
/opt/rocm/bin/rocm-smi
