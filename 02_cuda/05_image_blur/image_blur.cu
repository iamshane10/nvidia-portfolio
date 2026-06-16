#include <iostream>
#include <chrono>
#include <cmath>

#define RADIUS 1

__global__ void boxBlur(float* in, float* out, int M, int N) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    if (row < M && col < N) {
        float sum = 0.0f;
        int count = 0;
        for (int r = row - RADIUS; r <= row + RADIUS; r++) {
            for (int c = col - RADIUS; c <= col + RADIUS; c++) {
                if (r >= 0 && r < M && c >= 0 && c < N) {
                    sum += in[r * N + c];
                    count++;
                }
            }
        }
        out[row * N + col] = sum / count;
    }
}

void cpuBoxBlur(float* in, float* out, int M, int N) {
    for (int row = 0; row < M; row++) {
        for (int col = 0; col < N; col++) {
            float sum = 0.0f;
            int count = 0;
            for (int r = row - RADIUS; r <= row + RADIUS; r++) {
                for (int c = col - RADIUS; c <= col + RADIUS; c++) {
                    if (r >= 0 && r < M && c >= 0 && c < N) {
                        sum += in[r * N + c];
                        count++;
                    }
                }
            }
            out[row * N + col] = sum / count;
        }
    }
}

int main() {
    const int M = 4096;
    const int N = 4096;
    const int bytes = sizeof(float) * M * N;

    float* h_in = new float[M * N];
    float* h_out_cpu = new float[M * N];
    float* h_out_gpu = new float[M * N];

    // gradient initialisation
    for (int r = 0; r < M; r++)
        for (int c = 0; c < N; c++)
            h_in[r * N + c] = (float)(r + c);

    // CPU blur 
    auto t1 = std::chrono::high_resolution_clock::now();
    cpuBoxBlur(h_in, h_out_cpu, M, N);
    auto t2 = std::chrono::high_resolution_clock::now();
    double cpu_ms = std::chrono::duration<double, std::milli>(t2 - t1).count();
    std::cout << "CPU time: " << cpu_ms << " ms" << std::endl;

    // GPU blur 
    float *d_in, *d_out;
    cudaMalloc(&d_in,  bytes);
    cudaMalloc(&d_out, bytes);
    cudaMemcpy(d_in, h_in, bytes, cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    dim3 threadsPerBlock(16, 16);
    dim3 numBlocks((N + 15) / 16, (M + 15) / 16);

    std::cout << "Grid:  " << numBlocks.x << " x " << numBlocks.y << " blocks" << std::endl;
    std::cout << "Block: " << threadsPerBlock.x << " x " << threadsPerBlock.y << " threads" << std::endl;

    cudaEventRecord(start);
    boxBlur<<<numBlocks, threadsPerBlock>>>(d_in, d_out, M, N);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float gpu_ms = 0;
    cudaEventElapsedTime(&gpu_ms, start, stop);
    std::cout << "GPU time: " << gpu_ms << " ms" << std::endl;

    cudaMemcpy(h_out_gpu, d_out, bytes, cudaMemcpyDeviceToHost);

    cudaFree(d_in);
    cudaFree(d_out);

    // verify GPU matches CPU
    bool correct = true;
    for (int r = 0; r < M; r++) {
        for (int c = 0; c < N; c++) {
            if (fabsf(h_out_gpu[r * N + c] - h_out_cpu[r * N + c]) > 1e-3f) {
                std::cout << "Mismatch at (" << r << ", " << c << ")"
                          << " cpu=" << h_out_cpu[r * N + c]
                          << " gpu=" << h_out_gpu[r * N + c] << std::endl;
                correct = false;
                break;
            }
        }
        if (!correct) break;
    }
    if (correct) std::cout << "GPU matches CPU!" << std::endl;

    // speedup 
    std::cout << "Speedup: " << cpu_ms / gpu_ms << "x" << std::endl;

    delete[] h_in;
    delete[] h_out_cpu;
    delete[] h_out_gpu;
}