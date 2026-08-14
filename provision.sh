#!/bin/bash
set -eo pipefail

COMFY_DIR="/workspace/ComfyUI/models"
# --- ADDED: Define the missing target directory variable ---
TARGET_DIR="/workspace/ComfyUI/custom_nodes/ComfyUI_INSTARAW"

# Define destination directories
mkdir -p "${COMFY_DIR}/diffusion_models" \
         "${COMFY_DIR}/text_encoders" \
         "${COMFY_DIR}/vae" \
         "${COMFY_DIR}/upscale_models" \
         "${COMFY_DIR}/checkpoints" \
         "${COMFY_DIR}/loras" \
         "${COMFY_DIR}/ultralytics/bbox" \
         "${COMFY_DIR}/sams" \
         "${COMFY_DIR}/ipadapter" \
         "${COMFY_DIR}/controlnet" \
         "/workspace/ComfyUI/custom_nodes"  # Ensure custom_nodes exists
# --- CONFIGURATION ---
# DOWNLOAD_REP="true"
DOWNLOAD_REP="false"

if [ "$DOWNLOAD_REP" = "true" ]; then
    if [ ! -d "$TARGET_DIR" ]; then
        echo "======================================================================"
        echo "Cloning ComfyUI_INSTARAW repository..."
        echo "======================================================================"
        git clone "https://github.com/timothy692/ComfyUI_INSTARAW.git" "$TARGET_DIR"
        
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
else
    echo "Skipping INSTARAW repo download."
fi

BASE_URL="https://raw.githubusercontent.com/timothy692/vastai-provisioning/main"
run_module() {
    local script_name="$1"
    echo "======================================================================"
    echo "======================================================================"
    echo "======================================================================"
    echo " Downloading models for module: $script_name"
    echo "======================================================================"
    echo "======================================================================"
    echo "======================================================================"
    
    local temp_file
    temp_file=$(mktemp)
    
    curl -sSL "${BASE_URL}/${script_name}" -o "$temp_file"
    
    source "$temp_file"
    rm -f "$temp_file"
}

# run_module "zimageturbo.sh"
# run_module "sdxl_zimageturbo.sh"
# run_module "post_processing.sh"
run_module "krea2.sh"
# run_module "synthid_bypass.sh"
# run_module "bg_flux_kontent.sh"

# run_module "wan22_scail2.sh"
