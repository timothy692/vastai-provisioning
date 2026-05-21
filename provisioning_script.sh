#!/bin/bash
set -eo pipefail

# --- CONFIGURATION SWITCHES ---
SDXL_ZIT_NSFW_MODELS="true"

COMFY_DIR="/workspace/ComfyUI/models"

DIFF_DIR="${COMFY_DIR}/diffusion_models"
TE_DIR="${COMFY_DIR}/text_encoders"
VAE_DIR="${COMFY_DIR}/vae"
UPSCALE_DIR="${COMFY_DIR}/upscale_models"
CHECKPOINT_DIR="${COMFY_DIR}/checkpoints"
LORA_DIR="${COMFY_DIR}/loras"
CONTROLNET_DIR="${COMFY_DIR}/controlnet"
YOLO_DIR="${COMFY_DIR}/ultralytics" # bbox path not needed 

echo "Creating model directories..."
mkdir -p "$DIFF_DIR" "$TE_DIR" "$VAE_DIR" "$UPSCALE_DIR" "$CHECKPOINT_DIR" "$LORA_DIR" "$CONTROLNET_DIR" "$YOLO_DIR"

echo "============================================="
echo "Downloading ZImageTurbo models..."
echo "============================================="
hf download Comfy-Org/z_image_turbo split_files/diffusion_models/z_image_turbo_bf16.safetensors --local-dir $DIFF_DIR
hf download Comfy-Org/z_image_turbo split_files/text_encoders/qwen_3_4b.safetensors --local-dir $TE_DIR
hf download Comfy-Org/z_image_turbo split_files/vae/ae.safetensors --local-dir $VAE_DIR

echo "============================================="
echo "Downloading 4x-UltraSharpV2 Upscaler..."
echo "============================================="
hf download GeraldoZulimar/4x-UltraSharpV2 4x-UltraSharpV2.pth --local-dir $UPSCALE_DIR

echo "============================================="
echo "Downloading Lustify SDXL Checkpoint..."
echo "============================================="
hf download aboba2005/lustifySDXLNSFW_ggwpV7 lustifySDXLNSFW_ggwpV7.safetensors --local-dir $CHECKPOINT_DIR

echo "============================================="
echo "Downloading LoRas..."
echo "============================================="
hf download tianweiy/DMD2 dmd2_sdxl_4step_lora_fp16.safetensors --local-dir $LORA_DIR
hf download datasets/JuDrus/Lora_other Detailed_nipples_xl.safetensors --local-dir $LORA_DIR
hf download timothy692/timothy692-RealFeet-SDXL RealFeet.safetensors --local-dir $LORA_DIR
hf download timothy692/Lady_Hand_SDXL lady_hand.safetensors --local-dir $LORA_DIR

echo "============================================="
echo "Downloading YOLO BBox Models..."
echo "============================================="
hf download ashllay/YOLO_Models bbox/nipples_yolov8s.pt --local-dir $YOLO_DIR 
hf download ashllay/YOLO_Models bbox/vagina-v3.2.pt --local-dir $YOLO_DIR
hf download Bingsu/adetailer face_yolov8m.pt --local-dir $YOLO_DIR
hf download Bingsu/adetailer hand_yolov8s.pt --local-dir $YOLO_DIR
hf download SimonJoz/comfy bbox/lips-v1.pt --local-dir $YOLO_DIR
hf download AunyMoons/loras-pack foot-yolov8l.pt --local-dir $YOLO_DIR

if [ "$SDXL_ZIT_NSFW_MODELS" = "true" ]; then
    echo "============================================="
    echo "Downloading SDXL ZImageTurbo NSFW models (enabled)"
    echo "============================================="

    hf download hfmaster/models-moved sdxl/controlnet/xinsir-controlnet-union-sdxl-1.0-promax.safetensors --local-dir $CONTROLNET_DIR
    hf download gemasai/4x_NMKD-Superscale-SP_178000_G 4x_NMKD-Superscale-SP_178000_G.pth --local-dir $UPSCALE_DIR
    hf download uwg/upscaler ESRGAN/1x-ITF-SkinDiffDetail-Lite-v1.pth --local-dir $UPSCALE_DIR
else
    echo "Skipping SDXL ZImageTurbo NSFW downloads" 
fi

echo "============================================="
echo "Flattening directories and cleaning up..."
echo "============================================="

# Move z image turbo files up
mv "${DIFF_DIR}/split_files/diffusion_models/"* "$DIFF_DIR" 2>/dev/null || true
mv "${TE_DIR}/split_files/text_encoders/"* "$TE_DIR" 2>/dev/null || true
mv "${VAE_DIR}/split_files/vae/"* "$VAE_DIR" 2>/dev/null || true

# Flatten the conditional models 
if [ "$SDXL_ZIT_NSFW_MODELS" = "true" ]; then
    mv "${CONTROLNET_DIR}/sdxl/controlnet/"* "$CONTROLNET_DIR" 2>/dev/null || true
    mv "${UPSCALE_DIR}/ESRGAN/"* "$UPSCALE_DIR" 2>/dev/null || true
    
    rm -rf "${CONTROLNET_DIR}/sdxl" "${UPSCALE_DIR}/ESRGAN"
fi

# Remove the empty leftover split_files directories 
rm -rf "${DIFF_DIR}/split_files" "${TE_DIR}/split_files" "${VAE_DIR}/split_files"

echo "============================================="
echo "All model downloads completed successfully!"
echo "============================================="
