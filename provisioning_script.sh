#!/bin/bash
set -eo pipefail

# --- CONFIGURATION SWITCHES ---
SDXL_ZIT_NSFW_MODELS="false"

COMFY_DIR="/workspace/ComfyUI/models"

DIFF_DIR="${COMFY_DIR}/diffusion_models"
TE_DIR="${COMFY_DIR}/text_encoders"
VAE_DIR="${COMFY_DIR}/vae"
UPSCALE_DIR="${COMFY_DIR}/upscale_models"
CHECKPOINT_DIR="${COMFY_DIR}/checkpoints"
LORA_DIR="${COMFY_DIR}/loras"
YOLO_DIR="${COMFY_DIR}/ultralytics"
SAMS_DIR="${COMFY_DIR}/sams"
IPADAPTER_DIR="${COMFY_DIR}/ipadapter"
CONTROLNET_DIR="${COMFY_DIR}/controlnet"

echo "Creating model directories..."
mkdir -p "$DIFF_DIR" "$TE_DIR" "$VAE_DIR" "$UPSCALE_DIR" "$CHECKPOINT_DIR" "$LORA_DIR" "$YOLO_DIR" "$SAMS_DIR" "$IPADAPTER_DIR" "$CONTROLNET_DIR"

echo "============================================="
echo "Downloading ZImageTurbo models..."
echo "============================================="
hf download Comfy-Org/z_image_turbo split_files/diffusion_models/z_image_turbo_bf16.safetensors --local-dir "$DIFF_DIR"
hf download Comfy-Org/z_image_turbo split_files/text_encoders/qwen_3_4b.safetensors --local-dir "$TE_DIR"
hf download Comfy-Org/z_image_turbo split_files/vae/ae.safetensors --local-dir "$VAE_DIR"

echo "============================================="
echo "Downloading 4x-UltraSharpV2 Upscaler..."
echo "============================================="
hf download GeraldoZulimar/4x-UltraSharpV2 4x-UltraSharpV2.pth --local-dir "$UPSCALE_DIR"

echo "============================================="
echo "Downloading Lustify SDXL Checkpoint..."
echo "============================================="
hf download aboba2005/lustifySDXLNSFW_ggwpV7 lustifySDXLNSFW_ggwpV7.safetensors --local-dir "$CHECKPOINT_DIR"

echo "============================================="
echo "Downloading LoRas..."
echo "============================================="
hf download tianweiy/DMD2 dmd2_sdxl_4step_lora_fp16.safetensors --local-dir "$LORA_DIR"
hf download datasets/JuDrus/Lora_other Detailed_nipples_xl.safetensors --local-dir "$LORA_DIR"
hf download timothy692/timothy692-RealFeet-SDXL RealFeet.safetensors --local-dir "$LORA_DIR"
hf download timothy692/Lady_Hand_SDXL lady_hand.safetensors --local-dir "$LORA_DIR"

echo "============================================="
echo "Downloading YOLO BBox Models & SAM Model..."
echo "============================================="
hf download timothy692/sam_vit_large sam_vit_l_0b3195.pth --local-dir "$SAMS_DIR"

# Download directly into YOLO_DIR without sub-directories
hf download ashllay/YOLO_Models bbox/nipples_yolov8s.pt --local-dir "$YOLO_DIR" --repo-type model && mv "${YOLO_DIR}/bbox/"* "$YOLO_DIR"
hf download ashllay/YOLO_Models bbox/vagina-v3.2.pt --local-dir "$YOLO_DIR" --repo-type model && mv "${YOLO_DIR}/bbox/"* "$YOLO_DIR"
hf download Bingsu/adetailer face_yolov8m.pt --local-dir "$YOLO_DIR"
hf download Bingsu/adetailer hand_yolov8s.pt --local-dir "$YOLO_DIR"
hf download SimonJoz/comfy bbox/lips-v1.pt --local-dir "$YOLO_DIR" --repo-type model && mv "${YOLO_DIR}/bbox/"* "$YOLO_DIR"
hf download AunyMoons/loras-pack foot-yolov8l.pt --local-dir "$YOLO_DIR"

if [ "$SDXL_ZIT_NSFW_MODELS" = "true" ]; then
    echo "Downloading SDXL ZImageTurbo NSFW models..."
    hf download hfmaster/models-moved sdxl/controlnet/xinsir-controlnet-union-sdxl-1.0-promax.safetensors --local-dir "$CONTROLNET_DIR"
    hf download gemasai/4x_NMKD-Superscale-SP_178000_G 4x_NMKD-Superscale-SP_178000_G.pth --local-dir "$UPSCALE_DIR"
    hf download uwg/upscaler ESRGAN/1x-ITF-SkinDiffDetail-Lite-v1.pth --local-dir "$UPSCALE_DIR"
    hf download h94/IP-Adapter sdxl_models/ip-adapter-plus-face_sdxl_vit-h.safetensors --local-dir "$IPADAPTER_DIR"

    # Flatten logic
    mv "${CONTROLNET_DIR}/sdxl/controlnet/"* "$CONTROLNET_DIR" 2>/dev/null || true
    mv "${UPSCALE_DIR}/ESRGAN/"* "$UPSCALE_DIR" 2>/dev/null || true
    rm -rf "${CONTROLNET_DIR}/sdxl" "${UPSCALE_DIR}/ESRGAN"
fi

# Cleanup
rm -rf "${DIFF_DIR}/split_files" "${TE_DIR}/split_files" "${VAE_DIR}/split_files" "${YOLO_DIR}/bbox"

echo "All model downloads completed successfully!"
