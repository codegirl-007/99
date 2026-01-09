# Tested on Arch + Clang 21
# rm -rf build
# cmake -B build -G Ninja \
#       -DCMAKE_CXX_COMPILER=clang++ \
#       -DCMAKE_CXX_SCAN_DEPS_COMMAND=/usr/bin/clang-scan-deps
# cmake --build build

cmake_minimum_required(VERSION 4.2)
project(p99 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(p99lib STATIC test.cpp)
target_sources(p99lib PUBLIC FILE_SET CXX_MODULES FILES test.cppm)
