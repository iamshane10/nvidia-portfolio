#include <iostream>
#include <chrono>
#include "thread_pool.hpp"

int main() {

    // ── Test 1: basic task execution ──────────────────────────────────
    std::cout << "=== Test 1: basic tasks ===" << std::endl;
    ThreadPool pool(4);
    for (int i = 0; i < 8; i++) {
        pool.submit([i]() {
            std::cout << "task " << i << " running on a worker thread" << std::endl;
        });
    }
    std::this_thread::sleep_for(std::chrono::milliseconds(100));

    // ── Test 2: parallel for vs single threaded ───────────────────────
    std::cout << "\n=== Test 2: parallel speedup ===" << std::endl;

    const int N = 8;
    std::vector<int> results(N, 0);

    // single threaded
    auto t1 = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < N; i++) {
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
        results[i] = i * i;
    }
    auto t2 = std::chrono::high_resolution_clock::now();
    double single = std::chrono::duration<double>(t2 - t1).count();
    std::cout << "single threaded: " << single << "s" << std::endl;

    // parallel
    std::fill(results.begin(), results.end(), 0);
    auto t3 = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < N; i++) {
        pool.submit([i, &results]() {
            std::this_thread::sleep_for(std::chrono::milliseconds(50));
            results[i] = i * i;
        });
    }
    std::this_thread::sleep_for(std::chrono::milliseconds(200));
    auto t4 = std::chrono::high_resolution_clock::now();
    double parallel = std::chrono::duration<double>(t4 - t3).count();
    std::cout << "parallel (4 threads): " << parallel << "s" << std::endl;
    std::cout << "speedup: " << single / parallel << "x" << std::endl;

    return 0;
}