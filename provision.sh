#!/bin/bash
set -eo pipefail

GITHUB_USER="timothy692"
GITHUB_REPO="vastai-provisioning"
GITHUB_BRANCH="main"

BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"

run_module() {
    local script_name="$1"
    echo "======================================"
    echo " Loading and Running: $script_name"
    echo "======================================"
    
    local temp_file
    temp_file=$(mktemp)
    
    curl -sSL "${BASE_URL}/${script_name}" -o "$temp_file"
    
    source "$temp_file"
    rm -f "$temp_file"
}

# --- CONTROLLER ---
# Add, remove, or comment out scripts below as needed
run_module "module.sh"
