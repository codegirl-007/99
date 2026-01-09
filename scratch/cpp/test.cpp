import foo_module;

#include "test.hpp"

#include <any>
#include <concepts>
#include <string_view>

template <typename T>
concept Callback = requires(T cb) {
    { cb() } -> std::same_as<void>;
    // TEST(1): Ensure Callback has an attribute ID, type int.
};

template <Callback T>
auto render(T cb) -> void { cb(); }

auto test() -> void
{
    const auto display_text = [](std::any canvas, std::string_view text, int x, int y) -> void {
        // TEST(2): Render the buffer at position (x, y) on the console canvas.
    };
    // TEST(3): Wrap the display_text lambda to match the Callback concept. Send it to the render function.
}

auto scopes() -> void
{
    {
        // TEST(4): Say something random on this scope
    }
    {
        // TEST(5): Calculate dy(t)/dt, where y(t) = (0.5 * g * t^2) + (v0_y * t) + (y0)
    }
}
