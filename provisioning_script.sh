#!/bin/bash
set -eo pipefail

COMFY_DIR="/workspace/ComfyUI/models"

DIFF_DIR="${COMFY_DIR}/diffusion_models"
TE_DIR="${COMFY_DIR}/text_encoders"
VAE_DIR="${COMFY_DIR}/vae"
UPSCALE_DIR="${COMFY_DIR}/upscale_models"
CHECKPOINT_DIR="${COMFY_DIR}/checkpoints"
LORA_DIR="${COMFY_DIR}/loras"
YOLO_DIR="${COMFY_DIR}/ultralytics" # bbox path not needed 

echo "Creating necessary model directories..."
mkdir -p "$DIFF_DIR" "$TE_DIR" "$VAE_DIR" "$UPSCALE_DIR" "$CHECKPOINT_DIR" "$LORA_DIR" "$YOLO_DIR"

echo "============================================="
echo "Downloading ZIT Diffusion Model..."
echo "============================================="
hf download Comfy-Org/z_image_turbo split_files/diffusion_models/z_image_turbo_bf16.safetensors --local-dir $DIFF_DIR

echo "============================================="
echo "Downloading ZIT Text Encoder (Qwen)..."
echo "============================================="
hf download Comfy-Org/z_image_turbo split_files/text_encoders/qwen_3_4b.safetensors --local-dir $TE_DIR

echo "============================================="
echo "Downloading ZIT VAE..."
echo "============================================="
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
echo "Downloading Detailed Nipples XL LoRA..."
echo "============================================="
hf download datasets/JuDrus/Lora_other Detailed_nipples_xl.safetensors --local-dir $LORA_DIR

echo "============================================="
echo "Downloading DMD2 4-Step LoRA..."
echo "============================================="
hf download tianweiy/DMD2 dmd2_sdxl_4step_lora_fp16.safetensors --local-dir $LORA_DIR

echo "============================================="
echo "Downloading YOLO BBox Models..."
echo "============================================="
hf download ashllay/YOLO_Models bbox/nipples_yolov8s.pt --local-dir $YOLO_DIR
hf download ashllay/YOLO_Models bbox/vagina-v3.2.pt --local-dir $YOLO_DIR

echo "============================================="
echo "All model downloads completed successfully!"
echo "============================================="

mv "${DIFF_DIR}/split_files/diffusion_models/"* "$DIFF_DIR" 2>/dev/null || true
mv "${TE_DIR}/split_files/text_encoders/"* "$TE_DIR" 2>/dev/null || true
mv "${VAE_DIR}/split_files/vae/"* "$VAE_DIR" 2>/dev/null || true
# mv "${YOLO_DIR}/bbox/"* "$YOLO_DIR" 2>/dev/null || true