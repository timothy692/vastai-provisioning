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

ip-adapter-plus-face_sdxl_vit-h.safetensors / ipdapter
xinsir-controlnet-union-sdxl-1.0-promax.safetensors / controlnet

# Base Models
dl "z_image_turbo_bf16.safetensors" "${COMFY_DIR}/diffusion_models"
dl "qwen_3_4b.safetensors" "${COMFY_DIR}/text_encoders"
dl "ae.safetensors" "${COMFY_DIR}/vae"
dl_from "aboba2005/lustifySDXLNSFW_ggwpV7" "lustifySDXLNSFW_ggwpV7.safetensors" "${COMFY_DIR}/checkpoints"

# Upscalers
dl "4x-UltraSharpV2.pth" "${COMFY_DIR}/upscale_models"
4x_NMKD-Superscale-SP_178000_G 4x_NMKD-Superscale-SP_178000_G.pth
1x-ITF-SkinDiffDetail-Lite-v1.pth

# Checkpoints / LoRas
dl "dmd2_sdxl_4step_lora_fp16.safetensors" "${COMFY_DIR}/loras"
dl "DetailedNipples.safetensors" "${COMFY_DIR}/loras"
dl_from "timothy692/timothy692-RealFeet-SDXL" "RealFeet.safetensors" "${COMFY_DIR}/loras"
dl_from "timothy692/Lady_Hand_SDXL" "lady_hand.safetensors" "${COMFY_DIR}/loras"

# YOLO / BBox / SAM
dl "nipple.pt" "${COMFY_DIR}/ultralytics/bbox"
dl "pussyV2.pt" "${COMFY_DIR}/ultralytics/bbox"
dl "face_yolov8m.pt" "${COMFY_DIR}/ultralytics/bbox"
dl "hand_yolov8s.pt" "${COMFY_DIR}/ultralytics/bbox"
dl "lips_v1.pt" "${COMFY_DIR}/ultralytics/bbox"
dl_from "AunyMoons/loras-pack" "foot-yolov8l.pt" "${COMFY_DIR}/ultralytics/bbox"

dl "sam_vit_b_01ec64.pth" "${COMFY_DIR}/sams"
