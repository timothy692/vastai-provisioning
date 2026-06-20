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

CUSTOM_NODES_DIR="/workspace/ComfyUI/custom_nodes"
TARGET_DIR="/workspace/ComfyUI/custom_nodes/ComfyUI_INSTARAW"

# Ensure the custom_nodes directory exists
mkdir -p "$CUSTOM_NODES_DIR"

# Verify the token is present
if [ -z "$GH_TOKEN" ]; then
    echo "ERROR: GH_TOKEN is not set. Cannot pull node pack."
    exit 1
fi

# Clone the repository
if [ ! -d "$TARGET_DIR" ]; then
    echo "Cloning repository..."
    
    # Clones the renamed repository into the explicit target path
    git clone "https://${GH_TOKEN}@github.com/timothy692/ComfyUI_INSTARAW.git" "$TARGET_DIR"
    
    # Install the requirements
    if [ -f "${TARGET_DIR}/requirements.txt" ]; then
        echo "Found requirements.txt. Installing dependencies..."
        pip install --no-cache-dir -r "${TARGET_DIR}/requirements.txt"
    else
        echo "No requirements.txt found in node pack."
    fi
else
    echo "Node pack already exists. Skipping clone."
fi

BASE_URL="https://raw.githubusercontent.com/timothy692/vastai-provisioning/main"
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

run_module "zimageturbo.sh"
