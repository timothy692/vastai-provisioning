#!/bin/bash
set -eo pipefail

REPO="LuckyOda/comfyui-full-pack"
COMFY_DIR="/workspace/ComfyUI/models"

# Ensure destination directories exist
mkdir -p "${COMFY_DIR}/diffusion_models" \
         "${COMFY_DIR}/text_encoders" \
         "${COMFY_DIR}/vae"

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

dl_civitai() {
    local url="$1"
    local filename="$2"
    local dest="$3"
    
    # Ensure the target directory exists
    mkdir -p "$dest"
    
    # Check if the file already exists
    if [ -f "${dest}/${filename}" ]; then
        echo "[SKIP] Civitai file already exists: ${dest}/${filename}"
    else
        # Verify the API key is passed correctly through the environment variable
        if [ -z "$CIVITAI_API_KEY" ]; then
            echo "ERROR: CIVITAI_API_KEY environment variable is not set. Cannot download."
            exit 1
        fi
        
        local authenticated_url
        if [[ "$url" == *\?* ]]; then
            # If URL already has parameters (like fileId), append token with '&'
            authenticated_url="${url}&token=${CIVITAI_API_KEY}"
        else
            # Simple URL, append token with '?'
            authenticated_url="${url}?token=${CIVITAI_API_KEY}"
        fi
        
        echo "Downloading ${filename} to ${dest} ..."
        
        curl -Lf --progress-bar "$authenticated_url" -o "${dest}/${filename}"
        
        echo "Done"
    fi
}

dl_from "Comfy-Org/Krea-2" "text_encoders/qwen3vl_4b_fp8_scaled.safetensors" "${COMFY_DIR}/text_encoders"
dl_from "Comfy-Org/Krea-2" "vae/qwen_image_vae.safetensors" "${COMFY_DIR}/vae"

dl_from "Comfy-Org/Krea-2" "diffusion_models/krea2_turbo_bf16.safetensors" "${COMFY_DIR}/diffusion_models"
#dl_civitai "https://civitai.com/api/download/models/3066243?fileId=2945029" "redcraftKREA2RedMix_krea2Edition.safetensors" "${COMFY_DIR}/diffusion_models"

dl_civitai "https://civitai.red/api/download/models/3067451?fileId=2946192" "realism_engine_krea2_v1.safetensors" "${COMFY_DIR}/loras"
