#include <iostream>

__global__ void matrixVector(float* A, float* x, float* y, int M, int N){
    int row = blockDim.x * blockIdx.x + threadIdx.x;
    if (row<M) {
        float sum = 0.0f;
        for (int col=0; col<N; col++){
            sum += A[row*N + col] * x[col];
        }
        y[row] = sum;
    }
}

int main() {
    const int M=4096; 
    const int N=4096;
    const int bytes_A = sizeof(float)*M*N;
    const int bytes_x = sizeof(float)*N;
    const int bytes_y = sizeof(float)*M;
    float* h_A = new float[M*N];
    float* h_x = new float[N]; 
    float* h_y = new float[M];
    for (int r=0; r<M; r++){
        for (int c=0;c<N; c++) {
            h_A[r*N + c] = 1.0f;
        }
    }

    for (int i=0; i<N; i++){
        h_x[i] = 1.0f;
    }

    float *d_A, *d_x, *d_y;
    cudaMalloc(&d_A, bytes_A);
    cudaMalloc(&d_x, bytes_x);
    cudaMalloc(&d_y, bytes_y);

    cudaMemcpy(d_A, h_A, bytes_A, cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, h_x, bytes_x, cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    
    int threadsPerBlock = 256;
    int numBlocks = (M + threadsPerBlock - 1) / threadsPerBlock;
    
    cudaEventRecord(start);

    matrixVector<<<numBlocks, threadsPerBlock>>>(d_A, d_x, d_y, M, N);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms = 0;
    cudaEventElapsedTime(&ms, start, stop);
    std::cout << "Time: " << ms << " ms" << std::endl;

    cudaMemcpy(h_y, d_y, bytes_y, cudaMemcpyDeviceToHost);

    cudaFree(d_A);
    cudaFree(d_x);
    cudaFree(d_y);

    bool correct = true;
    for (int r = 0; r < M; r++) {
        if (fabsf(h_y[r] - (float)N) > 0.1f) {
            std::cout << "Incorrect at row " << r 
                    << " got " << h_y[r] << std::endl;
            correct = false;
            break;
        }
    }
    if (correct) std::cout << "Matrix-vector correct!" << std::endl;

    delete[] h_A;
    delete[] h_x;
    delete[] h_y;
    return 0;
}