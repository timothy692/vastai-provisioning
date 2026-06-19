#!/bin/bash
set -eo pipefail

# --- CONFIGURATION ---
SDXL_M="true"
POST_PROCESS_M="true"

REPO="LuckyOda/comfyui-full-pack"
COMFY_DIR="/workspace/ComfyUI/models"

# Define destination directories
mkdir -p "${COMFY_DIR}/diffusion_models" \
         "${COMFY_DIR}/text_encoders" \
         "${COMFY_DIR}/vae" \
         "${COMFY_DIR}/upscale_models" \
         "${COMFY_DIR}/checkpoints" \
         "${COMFY_DIR}/loras" \
         "${COMFY_DIR}/ultralytics" \
         "${COMFY_DIR}/sams" \
         "${COMFY_DIR}/ipadapter" \
         "${COMFY_DIR}/controlnet"

dl() {
    hf download "$REPO" "$1" --local-dir "$2"
}

dl_from() { # Usage: dl_from "LuckyOda/comfyui-full-pack" "z_image_turbo_bf16.safetensors" "$DIFF_DIR"
    local repo="$1"
    local file="$2"
    local dest="$3"
    hf download "$repo" "$file" --local-dir "$dest" 
}

echo "Downloading workflow models..."

# Base Models
dl "z_image_turbo_bf16.safetensors" "${COMFY_DIR}/diffusion_models"
dl "qwen_3_4b.safetensors" "${COMFY_DIR}/text_encoders"
dl "ae.safetensors" "${COMFY_DIR}/vae"
dl_from "aboba2005/lustifySDXLNSFW_ggwpV7" "lustifySDXLNSFW_ggwpV7.safetensors" "${COMFY_DIR}/checkpoints"

# Upscalers
dl "4x-UltraSharpV2.pth" "${COMFY_DIR}/upscale_models"

# Checkpoints / LoRas
dl "dmd2_sdxl_4step_lora_fp16.safetensors" "${COMFY_DIR}/loras"
dl "DetailedNipples.safetensors" "${COMFY_DIR}/loras"
dl_from "timothy692/timothy692-RealFeet-SDXL" "RealFeet.safetensors" "${COMFY_DIR}/loras"
dl_from "timothy692/Lady_Hand_SDXL" "lady_hand.safetensors" "${COMFY_DIR}/loras"


# YOLO / BBox / SAM
dl "nipple.pt" "${COMFY_DIR}/ultralytics"
dl "pussyV2.pt" "${COMFY_DIR}/ultralytics"
dl "face_yolov8m.pt" "${COMFY_DIR}/ultralytics"
dl "hand_yolov8s.pt" "${COMFY_DIR}/ultralytics"
dl "lips_v1.pt" "${COMFY_DIR}/ultralytics"
dl_from "AunyMoons/loras-pack" "foot-yolov8l.pt" "${COMFY_DIR}/ultralytics"

dl "sam_vit_b_01ec64.pth" "${COMFY_DIR}/sams"
# dl_from "timothy692/sam_vit_large" "sam_vit_l_0b3195.pth" "${COMFY_DIR}/sams"

if [ "$SDXL_M" = "true" ]; then
    echo "Downloading SDXL Models"

fi

if [ "$POST_PROCESS_M" = "true" ]; then
    echo "Downloading post-processing models"

    dl_from "black-forest-labs/FLUX.2-klein-9b-fp8" "flux-2-klein-9b-fp8.safetensors" "${COMFY_DIR}/diffusion_models"
    dl_from "titomatus0203/qwen_3_8b_fp8mixed" "qwen_3_8b_fp8mixed.safetensors" "${COMFY_DIR}/text_encoders"
    dl "flux2-vae.safetensors" "${COMFY_DIR}/vae"

    dl_from "Danrisi/Lenovo_FluxKlein9b_base" "lenovo_flux_klein9b.safetensors" "${COMFY_DIR}/loras"
    
fi

echo "All models downloaded"
