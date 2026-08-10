from pathlib import Path

import torch
from torch import profiler


def main() -> None:
    if not torch.cuda.is_available():
        raise SystemExit(
            "CUDA is not available. Check your NVIDIA driver and CUDA-enabled "
            "PyTorch installation."
        )

    device = torch.device("cuda")
    properties = torch.cuda.get_device_properties(device)
    amp_dtype = (
        torch.bfloat16 if torch.cuda.is_bf16_supported() else torch.float16
    )

    print(f"PyTorch: {torch.__version__}")
    print(f"CUDA runtime: {torch.version.cuda}")
    print(f"GPU: {properties.name}")
    print(f"Mixed-precision dtype: {amp_dtype}")

    torch.manual_seed(0)
    model = torch.nn.Sequential(
        torch.nn.Linear(1024, 2048),
        torch.nn.GELU(),
        torch.nn.Linear(2048, 10),
    ).to(device)
    optimizer = torch.optim.AdamW(model.parameters())
    inputs = torch.randn(512, 1024, device=device)
    targets = torch.randn(512, 10, device=device)

    # Gradient scaling is useful for FP16. BF16 has enough exponent range that it
    # generally does not need scaling, so the same object is disabled in that case.
    scaler = torch.amp.GradScaler("cuda", enabled=amp_dtype == torch.float16)

    def train_step() -> tuple[torch.Tensor, torch.dtype]:
        optimizer.zero_grad(set_to_none=True)
        with torch.autocast(device_type="cuda", dtype=amp_dtype):
            predictions = model(inputs)
            loss = torch.nn.functional.mse_loss(predictions, targets)

        scaler.scale(loss).backward()
        scaler.step(optimizer)
        scaler.update()
        return loss.detach(), predictions.dtype

    # Warm up CUDA kernels before collecting the profile.
    for _ in range(2):
        train_step()
    torch.cuda.synchronize()

    with profiler.profile(
        activities=[
            profiler.ProfilerActivity.CPU,
            profiler.ProfilerActivity.CUDA,
        ],
        record_shapes=True,
        profile_memory=True,
    ) as prof:
        for _ in range(5):
            loss, output_dtype = train_step()
            prof.step()

    torch.cuda.synchronize()
    if output_dtype != amp_dtype:
        raise RuntimeError(
            f"Autocast produced {output_dtype}, but expected {amp_dtype}."
        )

    trace_path = Path(__file__).with_name("torch_cuda_trace.json")
    prof.export_chrome_trace(str(trace_path))

    print(f"Final loss: {loss.item():.6f}")
    print(f"Autocast output dtype: {output_dtype}")
    print(prof.key_averages().table(sort_by="self_cuda_time_total", row_limit=15))
    print(f"Chrome trace: {trace_path}")
    print("CUDA, mixed precision, and the PyTorch profiler are working.")


if __name__ == "__main__":
    main()
