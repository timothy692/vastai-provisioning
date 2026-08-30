#!/bin/bash
set -eo pipefail

COMFY_DIR="/workspace/ComfyUI/models"
CUSTOM_NODES_DIR="/workspace/ComfyUI/custom_nodes"

# Ensure destination directories exist
mkdir -p "${COMFY_DIR}/checkpoints" \
         "${COMFY_DIR}/clip_vision" \
         "${COMFY_DIR}/diffusion_models" \
         "${COMFY_DIR}/loras" \
         "${COMFY_DIR}/text_encoders" \
         "${COMFY_DIR}/vae" \
         "${CUSTOM_NODES_DIR}"

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

        # 2. Move the file up to the flat target directory
        mv "${dest}/${file}" "${dest}/${filename}"

        # 3. Clean up the empty nested directory tree created by Hugging Face
        local topdir="${file%%/*}"
        if [ "$topdir" != "$file" ]; then
            rm -rf "${dest}/${topdir}"
        fi

        echo "[SUCCESS] Saved to ${dest}/${filename}"
    fi
}

node_pack() {
    local repo_url="$1"
    local name
    name=$(basename "$repo_url" .git)
    local target="${CUSTOM_NODES_DIR}/${name}"

    if [ -d "$target" ]; then
        echo "[SKIP] Node pack already installed: ${name}"
    else
        echo "Cloning ${repo_url}..."
        git clone --depth 1 "$repo_url" "$target"

        if [ -f "${target}/requirements.txt" ]; then
            echo "Installing requirements for ${name}..."
            pip install -r "${target}/requirements.txt"
        fi

        echo "[SUCCESS] Installed node pack: ${name}"
    fi
}

# --- WAN 2.1 14B SCAIL-2 MODEL DOWNLOADS ---

# Checkpoint (SAM 3.1 multiplex)
dl_from "Comfy-Org/sam3.1" "checkpoints/sam3.1_multiplex_fp16.safetensors" "${COMFY_DIR}/checkpoints"

# CLIP Vision
dl_from "Comfy-Org/Wan_2.1_ComfyUI_repackaged" "split_files/clip_vision/clip_vision_h.safetensors" "${COMFY_DIR}/clip_vision"

# Diffusion model (fp8 scaled)
dl_from "Comfy-Org/SCAIL-2" "diffusion_models/wan2.1_14B_SCAIL_2_fp8_scaled.safetensors" "${COMFY_DIR}/diffusion_models"

# LoRAs
dl_from "lightx2v/Wan2.1-I2V-14B-480P-StepDistill-CfgDistill-Lightx2v" "loras/Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors" "${COMFY_DIR}/loras"
dl_from "Kijai/WanVideo_comfy" "Pusa/Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors" "${COMFY_DIR}/loras"
dl_fron "akash-guptag/bounce-wan-lora" "bounceV_01.safetensors" "${COMFY_DIR}/loras"

# Text Encoder
dl_from "Comfy-Org/Wan_2.1_ComfyUI_repackaged" "split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" "${COMFY_DIR}/text_encoders"

# VAE
dl_from "Comfy-Org/Wan_2.1_ComfyUI_repackaged" "split_files/vae/wan_2.1_vae.safetensors" "${COMFY_DIR}/vae"

# --- SCAIL SAMPLER NODE PACKS ---

node_pack "https://github.com/Brobert-in-aus/scail-auto-extend"
node_pack "https://github.com/collbroGTR/comfyui-scail2-infinity"
