#!/bin/bash
set -eo pipefail

REPO="LuckyOda/comfyui-full-pack"
COMFY_DIR="/workspace/ComfyUI/models"

# Ensure destination directories exist
mkdir -p "${COMFY_DIR}/diffusion_models" \
         "${COMFY_DIR}/text_encoders" \
         "${COMFY_DIR}/vae" \
         "${COMFY_DIR}/vae_approx"

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
        
        # 2. Only run mv if the downloaded file is inside a subfolder
        if [ "${dest}/${file}" != "${dest}/${filename}" ]; then
            mv "${dest}/${file}" "${dest}/${filename}"
        fi
        
        # 3. Clean up the empty nested directories created by Hugging Face (e.g., split_files or vae)
        local first_dir="${file%%/*}"
        if [ "$first_dir" != "$file" ] && [ -d "${dest}/${first_dir}" ]; then
            rm -rf "${dest}/${first_dir}"
        fi
        
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

dl_from "Comfy-Org/MiniMax-H3" "diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors" "${COMFY_DIR}/diffusion_models"
dl_from "Comfy-Org/MiniMax-H3" "text_encoders/qwen3vl_32b_minimax_h3_int8_convrot.safetensors" "${COMFY_DIR}/text_encoders"

dl_from "Comfy-Org/MiniMax-H3" "vae/minimax_h3_video_vae_fp16.safetensors" "${COMFY_DIR}/vae"
dl_from "Comfy-Org/MiniMax-H3" "vae/minimax_h3_audio_vae_fp32.safetensors" "${COMFY_DIR}/vae"

dl_from "Kijai/MiniMax-H3_comfy" "loras/minimax_h3_fl2v_lightx2v_turbo_4step_v0.1_comfy.safetensors" "${COMFY_DIR}/loras"

dl_from "Kijai/MiniMax-H3-TAE" "Kijai/MiniMax-H3-TAE" "${COMFY_DIR}/vae_approx"

dl_civitai "https://civitai.red/api/download/models/3224980?fileId=3107031" "minimax-h3-digicam.safetensors" "${COMFY_DIR}/loras"
