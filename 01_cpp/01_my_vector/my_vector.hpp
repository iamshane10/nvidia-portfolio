template <typename T>

class MyVector {
private:
  T *data_;
  int size_;
  int capacity_;

public:
  MyVector() {
    data_ = nullptr;
    size_ = 0;
    capacity_ = 0;
  }

  MyVector(const MyVector& other) {
    T *new_data = new T[other.capacity_];
    size_ = other.size_;
    capacity_ = other.capacity_;
    for (int i = 0; i < size_; i++) {
      new_data[i] = other.data_[i];
    }
    data_ = new_data;
  }

  MyVector(MyVector&& other) noexcept {
    data_ = other.data_;
    size_ = other.size_;
    capacity_ = other.capacity_;

    other.data_=nullptr;
    other.size_=0;
    other.capacity_=0;
  }

  MyVector& operator=(const MyVector& other) {
    if (this == &other) {
      return *this;
    }
    delete[] data_;
    T *new_data = new T[other.capacity_];
    size_ = other.size_;
    capacity_ = other.capacity_;
    for (int i = 0; i < other.size_; i++) {
        new_data[i] = other.data_[i];
    }
    data_ = new_data;
    return *this;
  }

  MyVector& operator=(MyVector&& other) noexcept {
    if (this == &other) {
      return *this;
    }
    delete[] data_;
    data_ = other.data_;
    size_ = other.size_;
    capacity_ = other.capacity_;

    other.data_=nullptr;
    other.size_=0;
    other.capacity_=0;
    return *this;
  }

  ~MyVector() { delete[] data_; }

  void push_back(T value) {
    if (size_ == capacity_) {
      grow();
    }
    data_[size_] = value;
    size_++;
  }

  void grow() {
    capacity_ = (capacity_ == 0) ? 1 : 2 * capacity_;
    T *new_data = new T[capacity_];
    for (int i = 0; i < size_; i++) {
      new_data[i] = data_[i];
    }
    delete[] data_;
    data_ = new_data;
  }

  T &operator[](int idx) { return data_[idx]; }

  int size() { return size_; }

  int capacity() { return capacity_; }

  void resize(int n) {
    if (n > capacity_) {
      T *new_data = new T[n];
      for (int i = 0; i < size_; i++) {
        new_data[i] = data_[i];
      }
      delete[] data_;
      data_ = new_data;
      capacity_ = n;
    }
    size_ = n;
  }
};