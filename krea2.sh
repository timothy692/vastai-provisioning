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

# Personal LoRas
dl_from "timothy692/rina_v1" "rina_native_v1_000001800.safetensors" "${COMFY_DIR}/loras"
dl_from "timothy692/rina_v1" "rina_native_v1_000002100.safetensors" "${COMFY_DIR}/loras"
dl_from "timothy692/rina_v1" "rina_native_v1_000002400.safetensors" "${COMFY_DIR}/loras"
dl_from "timothy692/rina_v1" "rina_native_v1_000002700.safetensors" "${COMFY_DIR}/loras"
dl_from "timothy692/rina_v1" "rina_native_v1.safetensors" "${COMFY_DIR}/loras"

dl_from "Comfy-Org/Krea-2" "text_encoders/qwen3vl_4b_fp8_scaled.safetensors" "${COMFY_DIR}/text_encoders"
dl_from "wangkanai/wan21-vae" "vae/wan/wan21-vae.safetensors" "${COMFY_DIR}/vae"
# dl_from "Comfy-Org/Krea-2" "vae/qwen_image_vae.safetensors" "${COMFY_DIR}/vae"

# Krea2 raw int8 (with turbo LoRa)
dl_from "Comfy-Org/Krea-2" "diffusion_models/krea2_raw_int8_convrot.safetensors" "${COMFY_DIR}/diffusion_models"
dl_from "Comfy-Org/Krea-2" "loras/krea2_turbo_lora_rank_64_bf16.safetensors" "${COMFY_DIR}/loras"
# Turbo fp8
# dl_from "Comfy-Org/Krea-2" "diffusion_models/krea2_turbo_int8_convrot.safetensors" "${COMFY_DIR}/diffusion_models"
# Redcraft
# dl_civitai "https://civitai.com/api/download/models/3066243?fileId=2945029" "redcraftKREA2RedMix_krea2Edition.safetensors" "${COMFY_DIR}/diffusion_models"

# LoRas
dl_civitai "https://civitai.red/api/download/models/3109006?fileId=2988982" "realism_engine_krea2_v3.safetensors" "${COMFY_DIR}/loras"
dl_civitai "https://civitai.red/api/download/models/3067151?fileId=2945865" "krea2_filterbypass_3vec.safetensors" "${COMFY_DIR}/loras"
dl_civitai "https://civitai.red/api/download/models/3104629?fileId=2984442" "snofs_krea_v1_1.safetensors" "${COMFY_DIR}/loras"
dl_civitai "https://civitai.red/api/download/models/3075606?fileId=2954661" "lenovo_krea2.safetensors" "${COMFY_DIR}/loras"
# dl_civitai "https://civitai.red/api/download/models/3191538?fileId=3072276" "krea2-bloomgirls-realism.safetensors" "${COMFY_DIR}/loras"

# dl_civitai "https://civitai.com/api/download/models/3123277?fileId=3003694" "phone_photography_2025_krea2.safetensors" "${COMFY_DIR}/loras"

# dl_civitai "https://civitai.red/api/download/models/3097834?fileId=2977474" "skindetails_krea2_loraholic.safetensors" "${COMFY_DIR}/loras"
# dl_civitai "https://civitai.red/api/download/models/3088063?fileId=2967551" "Krea2_nsfw_v0.2.safetensors" "${COMFY_DIR}/loras"
# dl_civitai "https://civitai.red/api/download/models/3146215?fileId=3026675" "Breast_Nipple.safetensors" "${COMFY_DIR}/loras"

# Krea2 EDIT
# dl_from "conradlocke/krea2-identity-edit" "krea2_identity_edit_v1_2.safetensors" "${COMFY_DIR}/diffusion_models"
