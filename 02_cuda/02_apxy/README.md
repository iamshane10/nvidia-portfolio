## axpy using CUDA

AXPY: c[i] = a * x[i] + y[i], N = 1,048,576 elements

| Launch config <<<threads/block, blocks>>>     | Threads | Time     |
|-------------------|---------|----------|
| <<<512,  512>>>   | 262,144 | 0.230 ms |
| <<<1024, 256>>>   | 262,144 | 0.171 ms |
| <<<4096,  64>>>   | 262,144 | 0.169 ms |

GPU Specs - NVIDIA GTX 1650
Key observation: same total thread count, different organisation.
512 threads/block was slowest due to stride loop overhead.
Block sizes of 256 and 64 (both multiples of 32) performed similarly.