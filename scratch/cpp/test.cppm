module;
#include <print>

export module foo_module;

export void fizz_buzz()
{
    for (int i = 1; i <= 100; i++) {
        if (i % 15 == 0) {
            std::println("FizzBuzz");
        } else if (i % 3 == 0) {
            std::println("Fizz");
        } else if (i % 5 == 0) {
            std::println("Buzz");
        } else {
            std::println("{}", i);
        }
    }
}
