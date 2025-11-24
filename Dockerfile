FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Podstawowe narzędzia
RUN apt update && apt install -y \
    wget curl ca-certificates gnupg python3-setuptools python3-wheel \
    && rm -rf /var/lib/apt/lists/*

# --- Instalacja AMDGPU / ROCm 7.1 (bez DKMS, tylko userspace) ---

# 1. amdgpu-install
RUN wget https://repo.radeon.com/amdgpu-install/7.1/ubuntu/noble/amdgpu-install_7.1.70100-1_all.deb && \
    apt update && apt install -y ./amdgpu-install_7.1.70100-1_all.deb && \
    rm amdgpu-install_7.1.70100-1_all.deb

# 2. ROCm + HIP (bez modułów kernela)
RUN amdgpu-install --usecase=rocm,hip --no-dkms -y || true

# Sprzątanie APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Instalacja Ollamy 0.12.3 (ROCm bundle) ---
RUN curl -fsSL https://ollama.com/install.sh | OLLAMA_VERSION=0.12.3 sh

# --- Ustawienia środowiska dla ROCm + MI50 ---
ENV OLLAMA_LLM_LIBRARY=rocm \
    HIP_VISIBLE_DEVICES=0 \
    ROCR_VISIBLE_DEVICES=0 \
    CUDA_VISIBLE_DEVICES=-1 \
    OLLAMA_HOST=0.0.0.0:11434

EXPOSE 11434

# Domyślnie startujemy serwer Ollamy
CMD ["ollama", "serve"]
