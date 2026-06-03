# matrix_vector.cu

Matrix-vector multiply: `A * x = y` on a 4096×4096 matrix.

## What it does
Each thread computes one output element — the dot product of its 
assigned row of A with the vector x:
```cpp
for (int col = 0; col < N; col++)
    sum += A[row * N + col] * x[col];
```

## Launch config
- Matrix: 4096 × 4096 (64MB)
- Threads per block: 256
- Blocks: 16
- Total threads: 4096 — one per output row

## Result
| Operation              | Time     |
|------------------------|----------|
| 4096×4096 mat-vec mult | 2.70 ms  |

## Key learning
2D matrices are stored as flat 1D arrays in both host and device 
memory. Element at (row, col) is accessed as `A[row * N + col]`. 
`cudaMemcpy` copies raw bytes — the shape only exists in the index 
arithmetic.