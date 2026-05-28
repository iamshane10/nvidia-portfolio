#include <iostream>

__global__ void apxy(float a, float* x, float* y, float* c, const int N){
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = gridDim.x * blockDim.x;
    while (i<N) {
        c[i] = a * x[i] + y[i]; 
        i += stride;
    }
} 

int main(){
    const int N = 1 << 20;
    const int bytes = N*sizeof(float);
    float* h_x = new float[N];
    float* h_y = new float[N];
    float* h_c = new float[N];
    for (int i=0; i<N; i++) {
        h_x[i] = i * 1.0f;
        h_y[i] = i * 2.0f;
    }

    float *d_x, *d_y, *d_c;
    cudaMalloc(&d_x, bytes);
    cudaMalloc(&d_y, bytes);
    cudaMalloc(&d_c, bytes);

    cudaMemcpy(d_x, h_x, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, h_y, bytes, cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    apxy<<<512,512>>>(2.5f, d_x, d_y, d_c, N);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms = 0;
    cudaEventElapsedTime(&ms, start, stop);
    std::cout << "Time: " << ms << " ms" << std::endl;

    cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost);
    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_c);

    bool correct = true;
    for (int i=0; i<N; i++) {
        if (h_c[i] != (2.5f * h_x[i] + h_y[i])){
            std::cout<<"Incorrect at "<<i;
            correct = false;
        }
    }
    if (correct){std::cout<<"apxy calculated accurately!";} 
    delete[] h_c;
    delete[] h_x;
    delete[] h_y;
}