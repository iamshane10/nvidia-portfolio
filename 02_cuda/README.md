# Week 4 — CUDA-GPU Fundamentals

First real CUDA kernels. The goal this week was to understand the 
host/device model, write kernels, and get comfortable with the 
CUDA memory flow.

---

## The CUDA memory flow

Every CUDA program this week followed the same pattern:

1. Allocate arrays on the host (CPU RAM)
2. Allocate arrays on the device (GPU VRAM) with `cudaMalloc`
3. Copy data host → device with `cudaMemcpy`
4. Launch kernel — thousands of threads run simultaneously
5. Copy results device → host with `cudaMemcpy`
6. Free device memory with `cudaFree`

The host and device are physically separate — data doesn't 
appear on the GPU automatically. Every transfer is explicit.

---

## Key concepts

**Threads, blocks, grids** — kernels launch thousands of threads 
organised into blocks. Each thread gets a unique index:
```cpp
int i = blockIdx.x * blockDim.x + threadIdx.x;
```

**One thread per element** — the core pattern. Thread `i` handles 
element `i`. The GPU processes all elements simultaneously.

**Grid-stride loop** — when you have fewer threads than elements, 
each thread strides through the array handling multiple elements:
```cpp
int stride = gridDim.x * blockDim.x;
while (i < N) {
    // process element i
    i += stride;
}
```

**Row-major layout** — 2D matrices are stored as flat 1D arrays. 
Element at (row, col) lives at index `row * N + col`. Both host 
and kernel use the same formula — `cudaMemcpy` just copies bytes 
with no concept of shape.

**`cudaDeviceSynchronize` and CUDA events** — kernel launches are 
asynchronous. Without synchronization the CPU moves on before the 
GPU finishes. `cudaEventSynchronize` blocks until the GPU is done 
and gives accurate kernel timing.

**`checkCuda` on everything** — CUDA calls fail silently by default. 
Wrapping every call with `checkCuda` gives immediate, clear error 
messages with file and line number instead of mysterious crashes later.

**Float comparison** — never use `==` with floats. GPU arithmetic 
accumulates small rounding errors. Always use a tolerance:
```cpp
fabsf(result - expected) > 1e-3f
```

---

## Projects

### vector_add.cu
Adds two float arrays element-wise. First kernel — establishes 
the basic host/device memory flow and `checkCuda` habit.

### axpy.cu
BLAS-style operation: `c[i] = a * x[i] + y[i]` over 1M elements.
Introduced the grid-stride loop and CUDA event timing.

**Launch config comparison — N = 1,048,576 elements:**

| Config            | Total threads | Time     |
|-------------------|---------------|----------|
| <<<512,  512>>>   | 262,144       | 0.230 ms |
| <<<1024, 256>>>   | 262,144       | 0.171 ms |
| <<<4096,  64>>>   | 262,144       | 0.169 ms |

Same total thread count, different organisation. 512 threads/block 
was slowest because each thread processed 4 elements via the stride 
loop. Threads per block should always be a multiple of 32 — the GPU 
schedules threads in groups of 32 called warps, so partial warps 
waste execution slots.

### matrix_vector.cu
Matrix-vector multiply: `A * x = y` on a 4096×4096 matrix.
One thread per output row — each thread computes the dot product 
of its row with the vector x using row-major index arithmetic.

**Result: 2.70 ms for 4096×4096 (16M multiply-accumulate operations)**

The tolerance for verification was loosened to `1e-1f` — summing 
4096 floats per row accumulates more rounding error than a single 
multiply, so a tighter tolerance would produce false failures.

---

## The CUDA connection to Phase 1

| C++ (Phase 1)       | CUDA (Phase 2)         |
|---------------------|------------------------|
| `new` / `delete[]`  | `cudaMalloc/cudaFree`  |
| heap allocation     | device allocation      |
| RAII destructor     | `cudaFree` in cleanup  |
| flat array indexing | row-major kernel math  |