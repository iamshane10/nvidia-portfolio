# Phase 1 — C++ Foundations

Three projects to build the mental model needed for CUDA. The core theme across all of them: **you are responsible for memory, timing, and data — nothing is automatic.**

---

## Week 1 — MyVector

A re-implementation of `std::vector` from scratch using manual heap allocation.

**What it does:** Dynamic array that grows automatically, supports copy and move semantics, and cleans up its own memory.

**Key things I learned:**

- Heap memory (`new` / `delete[]`) is completely manual — if you forget to free it, it leaks silently with no error. This is exactly how `cudaMalloc` / `cudaFree` works on the GPU.
- **RAII** — tying a resource's lifetime to an object's lifetime. The destructor calls `delete[]` automatically when the vector goes out of scope, so you never have to remember to free it manually.
- **Copy vs move** — copy allocates fresh memory and duplicates every element. Move just steals the pointer and nulls out the source — no allocation, no copying. For GPU buffers this matters a lot: you don't want to copy gigabytes of data when you can just transfer ownership.
- `const MyVector&` on copy constructors is a promise that you won't modify the source. Without it the compiler blocks you from copying const objects or temporaries.
- `noexcept` on move operations tells the compiler they can't fail, which lets it prefer moves over copies in performance-critical situations.
- **Operator overloading** — `operator[]` hooks into the `v[i]` syntax by telling the compiler what to do when someone indexes your class. The `operator` keyword is what gives the symbol its meaning — you can't use `fetch[]` instead.

---

## Week 2 — Thread Pool

A fixed-size pool of worker threads that execute tasks from a shared queue concurrently.

**What it does:** Spawns N threads once on creation, accepts tasks via `submit()`, workers sleep when idle and wake when notified, shuts down gracefully when destroyed.

**Key things I learned:**

- A **mutex** protects shared data — only one thread can lock it at a time. You only hold it while touching the shared queue, not while executing tasks. This is the minimum-lock-time principle.
- A **condition variable** puts threads to sleep efficiently instead of busy-waiting. Crucially, `cv_.wait()` releases the lock while sleeping — if it didn't, no one could ever add tasks and the whole pool would deadlock.
- The mutex is locked in exactly three places: `submit()` when writing to the queue, `worker_loop()` when reading from the queue, and the destructor when setting the stop flag. Every time for the same reason — touching shared data.
- **Spurious wakeups** are a real thing — the OS can randomly wake a sleeping thread for no reason. The lambda condition in `cv_.wait()` handles this by looping back to sleep if the condition isn't actually true.
- Task execution happens completely outside the lock — four workers can each be running their own task simultaneously. The lock is held for microseconds just to grab from the queue.
- **Graceful shutdown** — setting `stop_ = true` and calling `notify_all()` wakes every thread. Workers finish any remaining tasks before exiting instead of abandoning them mid-flight.

---

## Week 3 — CSV Parser

A CSV file parser that loads data into an in-memory table and supports filtering and aggregation.

**What it does:** Reads a CSV into headers and rows, supports `filter(column, value)` returning a new Table, and `sum(column)` returning a double.

**Key things I learned:**

- **`const type&` everywhere** — use it for function parameters and range-based for loops whenever you're just reading. Strings and vectors aren't cheap to copy, so `const std::string&` reads without copying. Leaving it out silently copies every element.
- **`std::ifstream`** opens a file and maintains an internal cursor. Every `std::getline` call reads from the cursor's current position and advances it past the newline — so the first `getline` gets headers and the while loop gets everything else without overlap.
- **`std::stringstream`** treats a string like a stream so you can read from it the same way you'd read from a file. Combined with `std::getline(ss, token, ',')` it splits a string on any delimiter cleanly.
- `getline()` takes the stream as the first parameter, the variable to write into as the second, and an optional delimiter as the third. Without a delimiter it splits on newlines.
- **`std::stod`** converts a string to a double — you need this because `"30" + "25"` in C++ is string concatenation, not addition. The whole `std` family: `stoi` for int, `stof` for float, `stol` for long.
- Returning a new `Table` from `filter()` enables chaining — `t.filter("city", "London").sum("age")` works because each call returns a value you can immediately call methods on.

---

## Connection to CUDA

Every concept here maps directly to Phase 2 (under `02_cuda`):

| C++ concept | CUDA equivalent |
|-------------|----------------|
| `new` / `delete[]` | `cudaMalloc` / `cudaFree` |
| RAII destructor | GPU buffer wrapper class |
| Move semantics | Passing GPU buffers without copying |
| Mutex + shared data | Atomic operations on GPU memory |
| Thread pool workers | CUDA kernel threads |
| Data layout in flat arrays | How kernels expect memory on the GPU |

---