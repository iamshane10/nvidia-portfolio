#include <iostream>

__global__ void matrixVector(float *A, float *B, float *C, int M, int N)
{
    int row = blockDim.x * blockIdx.x + threadIdx.x;
    int col = blockDim.y * blockIdx.y + threadIdx.y;
    if (row < M && col < N)
    {
        C[row * N + col] += A[row * N + col] + B[row * N + col];
    }
}

int main()
{
    const int M = 4096;
    const int N = 4096;
    const int bytes = sizeof(float) * M * N;
    float *h_A = new float[M * N];
    float *h_B = new float[M * N];
    float *h_C = new float[M * N];
    for (int r = 0; r < M; r++)
    {
        for (int c = 0; c < N; c++)
        {
            h_A[r * N + c] = 1.0f;
            h_B[r * N + c] = 1.0f;
        }
    }

    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, bytes);
    cudaMalloc(&d_B, bytes);
    cudaMalloc(&d_C, bytes);

    cudaMemcpy(d_A, h_A, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, bytes, cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    dim3 threadsPerBlock(16, 16);
    dim3 numBlocks((N + 15) / 16, (M + 15) / 16);
    
    std::cout << "Grid:  " << numBlocks.x    << " x " << numBlocks.y    << " blocks"  << std::endl;
    std::cout << "Block: " << threadsPerBlock.x << " x " << threadsPerBlock.y << " threads" << std::endl;

    cudaEventRecord(start);

    matrixVector<<<numBlocks, threadsPerBlock>>>(d_A, d_B, d_C, M, N);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms = 0;
    cudaEventElapsedTime(&ms, start, stop);
    std::cout << "Time: " << ms << " ms" << std::endl;

    cudaMemcpy(h_C, d_C, bytes, cudaMemcpyDeviceToHost);

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    bool correct = true;
    for (int r = 0; r < M; r++)
    {
        for (int c = 0; c < N; c++)
        {
            if (fabsf(h_C[r * N + c] - 2.0f) > 1e-3f)
            {
                std::cout << "Incorrect at row " << r
                          << " got " << h_C[r] << std::endl;
                correct = false;
                break;
            }
            if (!correct) break;
        }
    }
    if (correct)
        std::cout << "Matrix-vector correct!" << std::endl;

    delete[] h_A;
    delete[] h_B;
    delete[] h_C;
    return 0;
}