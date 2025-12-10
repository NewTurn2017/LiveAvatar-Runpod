#!/bin/bash
# LiveAvatar RunPod Auto-Install Script
# Usage: bash install.sh

set -e

echo "=============================================="
echo "  LiveAvatar RunPod Auto-Install Script"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on RunPod or similar environment
WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
INSTALL_DIR="${WORKSPACE_DIR}/LiveAvatar"

# Step 1: Install Miniconda if not exists
print_status "Step 1: Checking Miniconda installation..."
if [ ! -d "$HOME/miniconda3" ]; then
    print_status "Installing Miniconda..."
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
    bash /tmp/miniconda.sh -b -p $HOME/miniconda3
    rm /tmp/miniconda.sh
    print_status "Miniconda installed successfully"
else
    print_status "Miniconda already installed"
fi

# Initialize conda
source $HOME/miniconda3/etc/profile.d/conda.sh

# Accept conda ToS if needed
print_status "Accepting conda Terms of Service..."
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main 2>/dev/null || true
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 2>/dev/null || true

# Step 2: Create conda environment
print_status "Step 2: Creating conda environment (Python 3.10)..."
if conda env list | grep -q "liveavatar"; then
    print_warning "Environment 'liveavatar' already exists, skipping creation"
else
    conda create -n liveavatar python=3.10 -y
fi

# Activate environment
conda activate liveavatar

# Step 3: Install CUDA
print_status "Step 3: Installing CUDA 12.4.1..."
conda install nvidia/label/cuda-12.4.1::cuda -y || print_warning "CUDA installation skipped (may already exist)"

# Step 4: Install PyTorch
print_status "Step 4: Installing PyTorch 2.8.0 with CUDA 12.8 support..."
pip install torch==2.8.0 torchvision==0.23.0 --index-url https://download.pytorch.org/whl/cu128

# Step 5: Install Flash Attention
print_status "Step 5: Installing Flash Attention 2.8.3..."
pip install psutil ninja packaging

# Download pre-built wheel
FLASH_ATTN_WHEEL="flash_attn-2.8.3+cu12torch2.8cxx11abiTRUE-cp310-cp310-linux_x86_64.whl"
FLASH_ATTN_URL="https://github.com/Dao-AILab/flash-attention/releases/download/v2.8.3/${FLASH_ATTN_WHEEL}"
wget -q -O /tmp/${FLASH_ATTN_WHEEL} "$FLASH_ATTN_URL"
pip install /tmp/${FLASH_ATTN_WHEEL}
rm -f /tmp/${FLASH_ATTN_WHEEL}
print_status "Flash Attention installed successfully"

# Step 6: Install requirements
print_status "Step 6: Installing project requirements..."
cd $INSTALL_DIR
pip install -r requirements.txt

# Step 7: Install additional dependencies
print_status "Step 7: Installing additional dependencies..."
pip install gradio hf_transfer

# Step 8: Download models
print_status "Step 8: Downloading models (this may take a while)..."

# Create checkpoint directory
mkdir -p $INSTALL_DIR/ckpt

# Enable fast transfer
export HF_HUB_ENABLE_HF_TRANSFER=1

# Download Wan2.2-S2V-14B model
print_status "Downloading Wan2.2-S2V-14B model (~43GB)..."
huggingface-cli download Wan-AI/Wan2.2-S2V-14B --local-dir $INSTALL_DIR/ckpt/Wan2.2-S2V-14B

# Download LiveAvatar LoRA
print_status "Downloading LiveAvatar LoRA weights (~1.3GB)..."
huggingface-cli download Quark-Vision/Live-Avatar --local-dir $INSTALL_DIR/ckpt/LiveAvatar

# Step 9: Verify installation
print_status "Step 9: Verifying installation..."
python -c "
import torch
import flash_attn
import gradio
print(f'PyTorch: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
print(f'Flash Attention: {flash_attn.__version__}')
print(f'Gradio: {gradio.__version__}')
print('All dependencies installed successfully!')
"

# Check models
if [ -f "$INSTALL_DIR/ckpt/Wan2.2-S2V-14B/diffusion_pytorch_model-00001-of-00004.safetensors" ] && \
   [ -f "$INSTALL_DIR/ckpt/LiveAvatar/liveavatar.safetensors" ]; then
    print_status "Models downloaded successfully!"
else
    print_error "Model download may be incomplete. Please check ckpt directory."
fi

echo ""
echo "=============================================="
echo -e "${GREEN}  Installation Complete!${NC}"
echo "=============================================="
echo ""
echo "To run LiveAvatar:"
echo "  cd $INSTALL_DIR"
echo "  ./run.sh"
echo ""
echo "Or manually:"
echo "  source ~/miniconda3/etc/profile.d/conda.sh"
echo "  conda activate liveavatar"
echo "  ./run.sh"
echo ""
