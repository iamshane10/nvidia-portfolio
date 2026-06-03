# matrix_add.cu

Element-wise addition of two 4096×4096 matrices using a 2D thread grid.

## What it does
Each thread computes one element of C = A + B, mapped to a 
2D position using x for columns and y for rows:
```cpp
int col = blockIdx.x * blockDim.x + threadIdx.x;
int row = blockIdx.y * blockDim.y + threadIdx.y;
C[row * N + col] = A[row * N + col] + B[row * N + col];
```

## Launch config
- Matrix: 4096 × 4096 (64MB per matrix, 192MB total)
- Block: 16 × 16 = 256 threads
- Grid: 256 × 256 = 65,536 blocks
- Total threads: 16,777,216 — one per matrix element

## Result
| Operation              | Time     |
|------------------------|----------|
| 4096×4096 matrix add   | 4.79 ms  |

## Key learnings

**2D thread indexing with `dim3`** — `dim3` is a CUDA struct for 
specifying x/y/z dimensions. Constructor syntax is required:
```cpp
dim3 threadsPerBlock(16, 16);   // not = (16, 16)
dim3 numBlocks((N+15)/16, (M+15)/16);
```

**Coalesced memory access** — x dimension maps to columns, y to rows.
Consecutive threads (varying threadIdx.x) access consecutive memory 
addresses in row-major layout. Swapping x and y would make every 
access stride N elements apart — up to 32x slower.

**2D → 1D index** — matrices live in flat memory. Element at 
(row, col) is always `row * N + col`. The 2D grid is just a 
convenient way to assign threads — the underlying memory is still 1D.