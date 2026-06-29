#!/bin/bash
set -eo pipefail

COMFY_DIR="/workspace/ComfyUI/models"

# Optimized download helper with automatic flattening and renaming support
dl_from() {
    local repo="$1"
    local file="$2"
    local dest="$3"
    local rename="${4:-}" # Optional parameter to rename the file
    
    local original_filename
    original_filename=$(basename "$file")
    
    local final_filename="$original_filename"
    if [ -n "$rename" ]; then
        final_filename="$rename"
    fi
    
    # 1. Check if the final file already exists in the target folder
    if [ -f "${dest}/${final_filename}" ]; then
        echo "[SKIP] File already exists: ${dest}/${final_filename}"
    else
        echo "Downloading ${file} from ${repo} to temporary structure..."
        hf download "$repo" "$file" --local-dir "$dest" 
        
        # 2. Relocate and rename if specified
        if [ -n "$rename" ]; then
            mv "${dest}/${file}" "${dest}/${rename}"
        elif [ "${dest}/${file}" != "${dest}/${original_filename}" ]; then
            mv "${dest}/${file}" "${dest}/${original_filename}"
        fi
        
        # 3. Clean up the empty nested directories created by Hugging Face
        local first_dir="${file%%/*}"
        if [ "$first_dir" != "$file" ] && [ -d "${dest}/${first_dir}" ]; then
            rm -rf "${dest}/${first_dir}"
        fi
        
        echo "[SUCCESS] Saved to ${dest}/${final_filename}"
    fi
}

TARGET_DIR="/workspace/ComfyUI/custom_nodes/Comfyui-SynthidBypass"

# Clone the public repository (token no longer required)
if [ ! -d "$TARGET_DIR" ]; then
    echo "======================================================================"
    echo "Cloning SynthID bypass repository..."
    echo "======================================================================"
    git clone "https://github.com/timothy692/Comfyui-SynthidBypass.git" "$TARGET_DIR"
    
    # Install requirements using the correct virtual environment
    if [ -f "${TARGET_DIR}/requirements.txt" ]; then
        echo "Found requirements.txt. Locating ComfyUI virtual environment..."
        
        # Prioritize the specified .venv path
        if [ -f "/workspace/ComfyUI/.venv/bin/pip" ]; then
            COMFY_PIP="/workspace/ComfyUI/.venv/bin/pip"
        elif [ -f "/venv/main/bin/pip" ]; then
            COMFY_PIP="/venv/main/bin/pip"
        elif [ -f "/workspace/ComfyUI/venv/bin/pip" ]; then
            COMFY_PIP="/workspace/ComfyUI/venv/bin/pip"
        else
            COMFY_PIP="pip"
        fi
        
        echo "Installing dependencies using: $COMFY_PIP"
        "$COMFY_PIP" install --no-cache-dir -r "${TARGET_DIR}/requirements.txt"
    else
        echo "No requirements.txt found in node pack."
    fi
else
    echo "Node pack already exists. Skipping clone."
fi

# 1. Diffusion Models (saved to: models/diffusion_models/)
dl_from "unsloth/Qwen-Image-2512-GGUF" "qwen-image-2512-Q4_K_M.gguf" "${COMFY_DIR}/diffusion_models"
dl_from "jayn7/Z-Image-Turbo-GGUF" "z_image_turbo-Q4_K_M.gguf" "${COMFY_DIR}/diffusion_models"

# 2. Text Encoder & Clip Models (saved to: models/clip/)
dl_from "unsloth/Qwen2.5-VL-7B-Instruct-GGUF" "Qwen2.5-VL-7B-Instruct-Q4_K_M.gguf" "${COMFY_DIR}/clip"
dl_from "worstplayer/Z-Image_Qwen_3_4b_text_encoder_GGUF" "Qwen_3_4b-imatrix-IQ4_XS.gguf" "${COMFY_DIR}/clip"

# 3. VAE Models (saved to: models/vae/)
dl_from "Comfy-Org/Qwen-Image_ComfyUI" "split_files/vae/qwen_image_vae.safetensors" "${COMFY_DIR}/vae"
dl_from "Comfy-Org/Z-Image-ComfyUI" "split_files/vae/ae.safetensors" "${COMFY_DIR}/vae"

# 4. LoRA Models (saved to: models/loras/)
dl_from "lightx2v/Qwen-Image-2512-Lightning" "Qwen-Image-2512-Lightning-4steps-V1.0-fp32.safetensors" "${COMFY_DIR}/loras"

# 5. Diffusion Model Patches / ControlNet (saved to: models/diffusion_model_patches/)
dl_from "Comfy-Org/Qwen-Image-DiffSynth-ControlNets" "split_files/model_patches/qwen_image_canny_diffsynth_controlnet.safetensors" "${COMFY_DIR}/diffusion_model_patches"

# 6. Ultralytics BBox (downloads face_yolov8n.pt and saves as yolov8n-face.pt)
dl_from "Bingsu/adetailer" "face_yolov8n.pt" "${COMFY_DIR}/ultralytics/bbox" "yolov8n-face.pt"

# 7. SAM Model 
dl_from "Buqi7/sam_vit_b_01ec64" "sam_vit_b_01ec64.pth" "${COMFY_DIR}/sams"
