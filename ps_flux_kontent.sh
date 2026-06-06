#!/bin/bash
set -eo pipefail

COMFY_DIR="/workspace/ComfyUI/models"

# Define destination directories
mkdir -p "${COMFY_DIR}/diffusion_models" \
         "${COMFY_DIR}/text_encoders" \
         "${COMFY_DIR}/vae" \
         "${COMFY_DIR}/loras" \

dl_from() { 
    local repo="$1"
    local file="$2"
    local dest="$3"
    hf download "$repo" "$file" --local-dir "$dest" 
}

DIFF_MODELS_DIR="${COMFY_DIR}/diffusion_models"

dl_from "Comfy-Org/flux1-kontext-dev_ComfyUI" \
        "split_files/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors" \
        "$DIFF_MODELS_DIR"

# Use find to move any file found inside split_files to the target directory
if [ -d "$DIFF_MODELS_DIR/split_files" ]; then
    find "$DIFF_MODELS_DIR/split_files" -type f -exec mv {} "$DIFF_MODELS_DIR/" \;
    rm -rf "$DIFF_MODELS_DIR/split_files"
fi

dl_from "comfyanonymous/flux_text_encoders" "clip_l.safetensors" "${COMFY_DIR}/text_encoders"
dl_from "comfyanonymous/flux_text_encoders" "t5xxl_fp16.safetensors" "${COMFY_DIR}/text_encoders"

VAE_DIR="${COMFY_DIR}/vae"

dl_from "Comfy-Org/Lumina_Image_2.0_Repackaged" \
        "split_files/vae/ae.safetensors" \
        "$VAE_DIR"

# Use find to move any file found inside split_files to the target directory
if [ -d "$VAE_DIR/split_files" ]; then
    find "$VAE_DIR/split_files" -type f -exec mv {} "$VAE_DIR/" \;
    rm -rf "$VAE_DIR/split_files"
fi

echo "All models downloaded"