#!/bin/bash
# LiveAvatar Gradio Server Launch Script (Single GPU with Share Mode)

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Initialize conda
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    source $HOME/miniconda3/etc/profile.d/conda.sh
elif [ -f "/root/miniconda3/etc/profile.d/conda.sh" ]; then
    source /root/miniconda3/etc/profile.d/conda.sh
else
    echo "Error: Miniconda not found. Please run install.sh first."
    exit 1
fi

conda activate liveavatar

echo "=============================================="
echo "  Starting LiveAvatar Gradio Server"
echo "=============================================="
echo "  Resolution: 704x384"
echo "  Frames: 48"
echo "  Sample Steps: 4"
echo "  Port: 7860"
echo "  Share Mode: Enabled"
echo "=============================================="

CUDA_VISIBLE_DEVICES=0 torchrun \
    --nproc_per_node=1 \
    --master_port=29502 \
    minimal_inference/gradio_app.py \
    --task s2v-14B \
    --size "704*384" \
    --base_seed 420 \
    --training_config liveavatar/configs/s2v_causal_sft.yaml \
    --offload_model True \
    --convert_model_dtype \
    --infer_frames 48 \
    --load_lora \
    --lora_path_dmd "ckpt/LiveAvatar/liveavatar.safetensors" \
    --sample_steps 4 \
    --sample_guide_scale 0 \
    --num_clip 100 \
    --num_gpus_dit 1 \
    --sample_solver euler \
    --ckpt_dir ckpt/Wan2.2-S2V-14B/ \
    --server_port 7860 \
    --server_name "0.0.0.0"
