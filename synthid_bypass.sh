#!/bin/bash
set -eo pipefail

COMFY_DIR="/workspace/ComfyUI/models"

# Optimized download helper that flattens any subfolders automatically
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
        
        # 2. Only move if the downloaded file is inside a subfolder
        if [ "${dest}/${file}" != "${dest}/${filename}" ]; then
            mv "${dest}/${file}" "${dest}/${filename}"
        fi
        
        # 3. Clean up the empty nested directories created by Hugging Face
        local first_dir="${file%%/*}"
        if [ "$first_dir" != "$file" ] && [ -d "${dest}/${first_dir}" ]; then
            rm -rf "${dest}/${first_dir}"
        fi
        
        echo "[SUCCESS] Saved to ${dest}/${filename}"
    fi
}

# --- MODEL DOWNLOADS ---

dl_from "Comfy-Org/Qwen-Image-DiffSynth-ControlNets" "split_files/model_patches/qwen_image_canny_diffsynth_controlnet.safetensors" "${COMFY_DIR}/controlnet"

dl_from "Buqi7/sam_vit_b_01ec64" "sam_vit_b_01ec64.pth" "${COMFY_DIR}/sams"

dl_from "ashllay/YOLO_Models" "bbox/face_yolov8n.pt" "${COMFY_DIR}/ultralytics/bbox"

dl_from "Remudl/qwen-image-vae" "qwen-image-vae.safetensors" "${COMFY_DIR}/vae"
dl_from "dooszypehnees/ae.safetensors" "ae.safetensors" "${COMFY_DIR}/vae"

dl_from "worstplayer/Z-Image_Qwen_3_4b_text_encoder_GGUF" "Qwen_3_4b-imatrix-IQ4_XS.gguf" "${COMFY_DIR}/text_encoders"
dl_from "unsloth/Qwen2.5-VL-7B-Instruct-GGUF" "Qwen2.5-VL-7B-Instruct-Q4_K_M.gguf" "${COMFY_DIR}/text_encoders"

dl_from "unsloth/Qwen-Image-2512-GGUF" "qwen-image-2512-Q4_K_M.gguf" "${COMFY_DIR}/unet"
dl_from "jayn7/Z-Image-Turbo-GGUF" "z_image_turbo-Q4_K_M.gguf" "${COMFY_DIR}/unet"
