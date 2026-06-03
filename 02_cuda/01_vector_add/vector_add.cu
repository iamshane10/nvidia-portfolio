#include <iostream>
#include "../helpers/cuda_check.cuh"

__global__ void vectorAdd_k(float* a, float* b, float* c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i<n) {
        c[i] = a[i] + b[i];
    }
}

int main(){
    const int N = 1000;
    int bytes = N*sizeof(float);

    float h_a[N], h_b[N], h_c[N];
    for (int i=0; i<N; i++){
        h_a[i] = i*1.0f;
        h_b[i] = i*2.0f;
    }

    float *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);

    cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);

    int threads_per_block = 256;
    int num_blocks = (N + threads_per_block - 1) / threads_per_block;
    vectorAdd_k<<<threads_per_block, num_blocks>>>(d_a, d_b, d_c, N);
    cudaDeviceSynchronize();

    cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    bool correct = true;
    for (int i=0; i<N; i++) {
        if (h_c[i] != h_a[i] + h_b[i]){
            std::cout<<"Error at "<<i<<"!!!!";
            correct = false;
        }
    }

    if (correct) std::cout << "All results correct!" << std::endl;
}

























































































































