#!/bin/bash
set -eo pipefail

# Configuration
export HF_XET_HIGH_PERFORMANCE=1 

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

GITHUB_USER="timothy692"
GITHUB_REPO="vastai-provisioning"
GITHUB_BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"

run_module() {
    local script_name="$1"
    echo "======================================"
    echo " Downloading models for module: $script_name"
    echo "======================================"
    
    local temp_file
    temp_file=$(mktemp)
    
    curl -sSL "${BASE_URL}/${script_name}" -o "$temp_file"
    
    source "$temp_file"
    rm -f "$temp_file"
}

# --- CONTROLLER ---
# Add, remove, or comment out scripts below as needed
run_module "zimageturbo.sh"
