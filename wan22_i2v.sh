#!/bin/bash
set -eo pipefail

REPO="LuckyOda/comfyui-full-pack"
COMFY_DIR="/workspace/ComfyUI/models"

# Ensure destination directories exist
mkdir -p "${COMFY_DIR}/diffusion_models" \
         "${COMFY_DIR}/text_encoders" \
         "${COMFY_DIR}/vae"

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
    local filename
    filename=$(basename "$file")
    
    # 1. Check if the flattened file already exists in the target folder
    if [ -f "${dest}/${filename}" ]; then
        echo "[SKIP] File already exists: ${dest}/${filename}"
    else
        echo "Downloading ${file} from ${repo} to temporary structure..."
        hf download "$repo" "$file" --local-dir "$dest" 
        
        # 2. Move the file up to the flat target directory
        mv "${dest}/${file}" "${dest}/${filename}"
        
        # 3. Clean up the empty nested directories created by Hugging Face
        rm -rf "${dest}/split_files"
        
        echo "[SUCCESS] Saved to ${dest}/${filename}"
    fi
}

# --- WAN 2.2 MODEL DOWNLOADS ---

# Diffusion Models (automatically flattened directly to: models/diffusion_models/)
dl_from "Comfy-Org/Wan_2.2_ComfyUI_Repackaged" "split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp16.safetensors" "${COMFY_DIR}/diffusion_models"
dl_from "Comfy-Org/Wan_2.2_ComfyUI_Repackaged" "split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp16.safetensors" "${COMFY_DIR}/diffusion_models"

# Text Encoder (automatically flattened directly to: models/text_encoders/)
dl_from "Comfy-Org/Wan_2.2_ComfyUI_Repackaged" "split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" "${COMFY_DIR}/text_encoders"

# VAE (automatically flattened directly to: models/vae/)
dl_from "Comfy-Org/Wan_2.2_ComfyUI_Repackaged" "split_files/vae/wan_2.1_vae.safetensors" "${COMFY_DIR}/vae"
