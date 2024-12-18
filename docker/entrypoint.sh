#!/bin/bash

# Marker file path
INIT_MARKER="/var/run/container_initialized"
DOWNLOAD_MODELS=${DOWNLOAD_MODELS:-"true"}  # Default if not set
REPO_DIR=${REPO_DIR:-"/workspace/diffusion-pipe"}

echo "DOWNLOAD_MODELS is: $DOWNLOAD_MODELS"

source /opt/conda/etc/profile.d/conda.sh
conda activate pyenv

if [ ! -f "$INIT_MARKER" ]; then
    echo "First-time initialization..."

    echo "Installing CUDA nvcc..."
    conda install -y -c nvidia cuda-nvcc --override-channels

    echo "Installing dependencies from requirements.txt..."
    pip install --no-cache-dir -r $REPO_DIR/requirements.txt

    export PYTHONPATH="$REPO_DIR:$REPO_DIR/submodules/HunyuanVideo:$PYTHONPATH"
    export PYTHONPATH="$REPO_DIR:$REPO_DIR/configs:$PYTHONPATH"
    export PATH="$REPO_DIR:$PATH"

    if [ "$DOWNLOAD_MODELS" = "true" ]; then
        echo "DOWNLOAD_MODELS is true, downloading models..."
        MODEL_DIR="/workspace/models"
        mkdir -p "$MODEL_DIR"

        # Clone llava-llama-3-8b-text-encoder-tokenizer repository
        if [ ! -d "${MODEL_DIR}/llava-llama-3-8b-text-encoder-tokenizer" ]; then
            git clone https://huggingface.co/Kijai/llava-llama-3-8b-text-encoder-tokenizer "${MODEL_DIR}/llava-llama-3-8b-text-encoder-tokenizer"
            cd "${MODEL_DIR}/llava-llama-3-8b-text-encoder-tokenizer"
            git lfs pull
            cd -
        fi

        # Download hunyuan_video_720_cfgdistill_fp8_e4m3fn model
        if [ ! -f "${MODEL_DIR}/hunyuan_video_720_cfgdistill_fp8_e4m3fn.safetensors" ]; then
            curl -L -o "${MODEL_DIR}/hunyuan_video_720_cfgdistill_fp8_e4m3fn.safetensors" "https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_720_cfgdistill_fp8_e4m3fn.safetensors?download=true"
        fi

        # Download hunyuan_video_vae_fp32 model
        if [ ! -f "${MODEL_DIR}/hunyuan_video_vae_fp32.safetensors" ]; then
            curl -L -o "${MODEL_DIR}/hunyuan_video_vae_fp32.safetensors" "https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_vae_fp32.safetensors?download=true"
        fi

        # Download hunyuan_video_vae_fp16 model
        if [ ! -f "${MODEL_DIR}/hunyuan_video_vae_fp16.safetensors" ]; then
            curl -L -o "${MODEL_DIR}/hunyuan_video_vae_fp16.safetensors" "https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_vae_fp16.safetensors?download=true"
        fi

        # Clone the entire CLIP repo
        if [ ! -d "${MODEL_DIR}/clip-vit-large-patch14" ]; then
            git clone https://huggingface.co/openai/clip-vit-large-patch14 "${MODEL_DIR}/clip-vit-large-patch14"
            cd "${MODEL_DIR}/clip-vit-large-patch14"
            git lfs pull
            cd -
        fi
    else
        echo "DOWNLOAD_MODELS is false, skipping model downloads."
    fi

    # Create marker file
    touch "$INIT_MARKER"
    echo "Initialization complete."
else
    echo "Container already initialized. Skipping first-time setup."
fi

exec python /workspace/diffusion-pipe/gradio_interface.py
