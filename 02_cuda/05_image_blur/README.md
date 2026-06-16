# image_blur_2d.cu

2D box blur over a 4096×4096 synthetic image, comparing CPU vs GPU performance.

## What it does
Each thread computes one output pixel by averaging its neighbours 
within a RADIUS=1 window (3×3 = up to 9 neighbours). Edge pixels 
have fewer neighbours — a boundary check handles this:

```cpp
for (int r = row - RADIUS; r <= row + RADIUS; r++)
    for (int c = col - RADIUS; c <= col + RADIUS; c++)
        if (r >= 0 && r < M && c >= 0 && c < N)
            sum += in[r * N + c];
out[row * N + col] = sum / count;
```

## Launch config
- Image: 4096 × 4096
- Block: 16 × 16 = 256 threads
- Grid: 256 × 256 = 65,536 blocks
- Total threads: 16,777,216 — one per pixel

## Results
| Version | Time       |
|---------|------------|
| CPU     | 479.66 ms  |
| GPU     | 4.14 ms    |
| Speedup | **115x**   |

## Key learnings

**2D kernels shine on image workloads** — each pixel is independent, 
making this embarrassingly parallel. The GPU processes all 16M pixels 
simultaneously vs the CPU's sequential nested loop.

**Boundary conditions** — edge and corner pixels have fewer than 9 
neighbours. The `if (r >= 0 && r < M ...)` guard handles this cleanly 
without special-casing edges.

**CPU vs GPU timing** — CUDA events measure GPU kernel time only. 
`std::chrono` measures wall-clock CPU time. Comparing them directly 
gives the real-world speedup the GPU provides over sequential code.

**Verification strategy** — rather than computing expected values 
manually, run the same algorithm on CPU and GPU and compare outputs 
with a `fabsf` tolerance. Any mismatch reveals a kernel bug.