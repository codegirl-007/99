#pragma once

// clang-format off

// Identifier call
inline auto foo(int arg) -> void { foo(arg); }

// Qualified call
namespace ns {
    void bar(int);
}
inline auto bar(int arg) -> void { ns::bar(arg); }

// Member & pointer member call
struct S {
    void baz(int);
};
inline auto baz(S obj, int arg) -> void { obj.baz(arg); }
inline auto baz(S* obj, int arg) -> void { obj->baz(arg); }

// Template call
template <class T> void qux(T);
inline auto qux(int arg) -> void { qux<int>(arg); }

// Function pointer call
using Fn = void (*)(int);
inline auto quux(Fn fp, int arg) -> void { (*fp)(arg); }
