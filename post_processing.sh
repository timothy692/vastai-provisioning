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

dl "flux2-vae.safetensors" "${COMFY_DIR}/vae"
dl_from "titomatus0203/qwen_3_8b_fp8mixed" "qwen_3_8b_fp8mixed.safetensors" "${COMFY_DIR}/text_encoders"

dl_from "black-forest-labs/FLUX.2-klein-9b-fp8" "flux-2-klein-9b-fp8.safetensors" "${COMFY_DIR}/diffusion_models"
# dl_civitai "https://civitai.red/api/download/models/2973304?fileId=2852910" "pornmaster_fluxklein9b.safetensors" "${COMFY_DIR}/diffusion_models"

dl_civitai "https://civitai.red/api/download/models/2960556?fileId=2839878" "snofs_fluxklein9b_v1_4.safetensors" "${COMFY_DIR}/loras"
dl_civitai "https://civitai.red/api/download/models/2876634?fileId=2757593" "realistic_nudes_fluxklein9b.safetensors" "${COMFY_DIR}/loras"
dl_civitai "https://civitai.red/api/download/models/2921102?fileId=2799569" "breastnippledetailer.safetensors" "${COMFY_DIR}/loras"

dl_from "Danrisi/Lenovo_FluxKlein9b_base" "lenovo_flux_klein9b.safetensors" "${COMFY_DIR}/loras"

# dl_from "aboba2005/lustifySDXLNSFW_ggwpV7" "lustifySDXLNSFW_ggwpV7.safetensors" "${COMFY_DIR}/checkpoints"
