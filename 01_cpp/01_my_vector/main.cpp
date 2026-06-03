#include <iostream>
#include "my_vector.hpp"

int main() {

    // ── Test 1: push_back and operator[] ──────────────────────────────
    std::cout << "=== Test 1: push_back + operator[] ===" << std::endl;
    MyVector<int> v;
    v.push_back(10);
    v.push_back(20);
    v.push_back(30);
    std::cout << v[0] << " " << v[1] << " " << v[2] << std::endl; // 10 20 30

    // ── Test 2: size and capacity ─────────────────────────────────────
    std::cout << "=== Test 2: size + capacity ===" << std::endl;
    std::cout << "size: "     << v.size()     << std::endl; // 3
    std::cout << "capacity: " << v.capacity() << std::endl; // 4 (doubled from 1→2→4)

    // ── Test 3: grow triggers correctly ──────────────────────────────
    std::cout << "=== Test 3: grow ===" << std::endl;
    MyVector<int> g;
    for (int i = 0; i < 10; i++) {
        g.push_back(i);
        std::cout << "size: " << g.size() << " capacity: " << g.capacity() << std::endl;
    }
    // capacity should double: 1→2→4→8→16

    // ── Test 4: copy constructor ──────────────────────────────────────
    std::cout << "=== Test 4: copy constructor ===" << std::endl;
    MyVector<int> copy = v;
    copy[0] = 99;
    std::cout << "v[0]:    " << v[0]    << std::endl; // 10 — unchanged
    std::cout << "copy[0]: " << copy[0] << std::endl; // 99 — independent

    // ── Test 5: copy assignment ───────────────────────────────────────
    std::cout << "=== Test 5: copy assignment ===" << std::endl;
    MyVector<int> a;
    a.push_back(100);
    a.push_back(200);
    MyVector<int> b;
    b = a;
    b[0] = 999;
    std::cout << "a[0]: " << a[0] << std::endl; // 100 — unchanged
    std::cout << "b[0]: " << b[0] << std::endl; // 999 — independent

    // ── Test 6: move constructor ──────────────────────────────────────
    std::cout << "=== Test 6: move constructor ===" << std::endl;
    MyVector<int> source1;
    source1.push_back(1);
    source1.push_back(2);
    MyVector<int> moved1 = std::move(source1);
    std::cout << "moved1[0]:      " << moved1[0]      << std::endl; // 1
    std::cout << "source1 size:   " << source1.size() << std::endl; // 0

    // ── Test 7: move assignment ───────────────────────────────────────
    std::cout << "=== Test 7: move assignment ===" << std::endl;
    MyVector<int> source2;
    source2.push_back(42);
    source2.push_back(43);
    MyVector<int> moved2;
    moved2 = std::move(source2);
    std::cout << "moved2[0]:      " << moved2[0]      << std::endl; // 42
    std::cout << "source2 size:   " << source2.size() << std::endl; // 0

    // ── Test 8: resize ────────────────────────────────────────────────
    std::cout << "=== Test 8: resize ===" << std::endl;
    MyVector<int> r;
    r.push_back(1);
    r.push_back(2);
    r.push_back(3);
    r.resize(6);
    std::cout << "size after resize(6):     " << r.size()     << std::endl; // 6
    std::cout << "capacity after resize(6): " << r.capacity() << std::endl; // 6
    r.resize(2);
    std::cout << "size after resize(2):     " << r.size()     << std::endl; // 2
    std::cout << "capacity after resize(2): " << r.capacity() << std::endl; // 6 — unchanged

    // ── Test 9: works with floats too (template) ──────────────────────
    std::cout << "=== Test 9: template with float ===" << std::endl;
    MyVector<float> f;
    f.push_back(1.1f);
    f.push_back(2.2f);
    f.push_back(3.3f);
    std::cout << f[0] << " " << f[1] << " " << f[2] << std::endl; // 1.1 2.2 3.3

    std::cout << "=== All tests passed ===" << std::endl;
    return 0;
}