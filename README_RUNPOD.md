# LiveAvatar RunPod Setup Guide

Real-time streaming audio-driven avatar generation framework optimized for RunPod deployment.

## Requirements

- **GPU**: NVIDIA GPU with 48GB+ VRAM (recommended: A100 80GB, H100, RTX 6000 Ada)
- **Storage**: ~50GB free disk space (for models)
- **RunPod Template**: PyTorch 2.x with CUDA 12.x

## Quick Start (One-Click Setup)

### Option 1: Fresh Installation

```bash
# Clone and install
cd /workspace
git clone https://github.com/YOUR_USERNAME/LiveAvatar-RunPod.git LiveAvatar
cd LiveAvatar
chmod +x install.sh run.sh
./install.sh
```

### Option 2: Using setup script

```bash
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/LiveAvatar-RunPod/main/setup_runpod.sh | bash
```

## Running LiveAvatar

After installation, start the Gradio server:

```bash
cd /workspace/LiveAvatar
./run.sh
```

The server will output a public URL like:
```
* Running on public URL: https://xxxxx.gradio.live
```

## Configuration

### Default Settings (Single GPU Mode)

| Parameter | Value | Description |
|-----------|-------|-------------|
| Resolution | 704x384 | Output video resolution |
| Frames | 48 | Frames per clip |
| Sample Steps | 4 | Diffusion sampling steps |
| Port | 7860 | Gradio server port |
| Share | True | Public URL enabled |

### Memory Optimization

The setup uses `--offload_model True` to enable model offloading between GPU and CPU, allowing operation on GPUs with less VRAM.

## File Structure

```
LiveAvatar/
├── install.sh          # Auto-installation script
├── run.sh              # Server launch script
├── setup_runpod.sh     # One-click setup script
├── ckpt/
│   ├── Wan2.2-S2V-14B/ # Base diffusion model (~43GB)
│   └── LiveAvatar/     # LoRA weights (~1.3GB)
└── minimal_inference/
    └── gradio_app.py   # Gradio web interface
```

## Troubleshooting

### CUDA Out of Memory
- Ensure `--offload_model True` is set
- Try reducing `--infer_frames` to 32
- Use a GPU with more VRAM

### Gradio Share URL Not Working
- Check if port 7860 is available
- Verify internet connectivity
- The share link expires after 1 week

### Model Download Failed
- Ensure sufficient disk space
- Try re-running the download command:
```bash
source ~/miniconda3/etc/profile.d/conda.sh
conda activate liveavatar
huggingface-cli download Wan-AI/Wan2.2-S2V-14B --local-dir ./ckpt/Wan2.2-S2V-14B
huggingface-cli download Quark-Vision/Live-Avatar --local-dir ./ckpt/LiveAvatar
```

## Credits

- Original LiveAvatar: [Alibaba-Quark/LiveAvatar](https://github.com/Alibaba-Quark/LiveAvatar)
- Base Model: [Wan-AI/Wan2.2-S2V-14B](https://huggingface.co/Wan-AI/Wan2.2-S2V-14B)
- LoRA Weights: [Quark-Vision/Live-Avatar](https://huggingface.co/Quark-Vision/Live-Avatar)

## License

Please refer to the original repository for licensing information.
