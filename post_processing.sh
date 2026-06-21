#!/bin/bash
set -eo pipefail

REPO="LuckyOda/comfyui-full-pack"
COMFY_DIR="/workspace/ComfyUI/models"

dl() {
    local file="$1"
    local dest="$2"
    
    # Check if the file already exists in the destination directory
    if [ -f "${dest}/${file}" ]; then
        echo "[SKIP] File already exists: ${dest}/${file}"
    else
        hf download "$REPO" "$file" --local-dir "$dest"
    fi
}

dl_from() {
    local repo="$1"
    local file="$2"
    local dest="$3"
    
    # Check if the file already exists in the destination directory
    if [ -f "${dest}/${file}" ]; then
        echo "[SKIP] File already exists: ${dest}/${file}"
    else
        hf download "$repo" "$file" --local-dir "$dest" 
    fi
}

dl_from "titomatus0203/qwen_3_8b_fp8mixed" "qwen_3_8b_fp8mixed.safetensors" "${COMFY_DIR}/text_encoders"
dl_from "black-forest-labs/FLUX.2-klein-9b-fp8" "flux-2-klein-9b-fp8.safetensors" "${COMFY_DIR}/diffusion_models"
dl "flux2-vae.safetensors" "${COMFY_DIR}/vae"

dl_from "Danrisi/Lenovo_FluxKlein9b_base" "lenovo_flux_klein9b.safetensors" "${COMFY_DIR}/loras"
    
