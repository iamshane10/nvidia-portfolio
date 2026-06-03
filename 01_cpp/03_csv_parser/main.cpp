#include "table.hpp"
#include <iostream>

int main() {
    Table t;
    t.parse("data.csv");

    // test print
    t.print();

    // test filter
    std::cout << "\n=== Filter: city == London ===" << std::endl;
    Table london = t.filter("city", "London");
    london.print();

    // test sum
    std::cout << "\n=== Sum: age ===" << std::endl;
    std::cout << "Total age: " << t.sum("age") << std::endl;

    // test chained filter + sum
    std::cout << "\n=== Sum: age of London residents ===" << std::endl;
    std::cout << "Total age: " << t.filter("city", "London").sum("age") << std::endl;

    return 0;
}