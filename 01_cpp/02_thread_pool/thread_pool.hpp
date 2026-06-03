#pragma once
#include <condition_variable>
#include <functional>
#include <mutex>
#include <queue>
#include <thread>
#include <vector>

class ThreadPool {
private:
  std::queue<std::function<void()>> tasks_;
  std::vector<std::thread> workers_;
  std::mutex mutex_;
  std::condition_variable cv_;
  bool stop_;

  void worker_loop() {
    while (true) {
      std::function<void()> task;
      {
        std::unique_lock<std::mutex> lock(mutex_);
        cv_.wait(lock, [this]() { return !tasks_.empty() || stop_ == true; });
        if (tasks_.empty() && stop_) break;
        task = tasks_.front();
        tasks_.pop();
      }
      task();
    }
  }

public:
  ThreadPool(int n_threads) {
    stop_ = false;
    for (int i = 0; i < n_threads; i++) {
      workers_.emplace_back([this]() { worker_loop(); });
    }
  }

  ~ThreadPool() {
    {
      std::unique_lock<std::mutex> lock(mutex_);
      stop_ = true;
    }
    cv_.notify_all();
    for (std::thread &worker : workers_) {
      worker.join();
    }
  }

  void submit(std::function<void()> task) {
    {
      std::unique_lock<std::mutex> lock(mutex_);
      tasks_.push(task);
    }
    cv_.notify_one();
  }
};