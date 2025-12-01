cmake_minimum_required(VERSION 3.14)
project(MathOperations)
# Clean configuration
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "" FORCE)
# Delete cached variables that might cause issues
unset(CMAKE_PREFIX_PATH CACHE)
unset(CMAKE_INCLUDE_PATH CACHE)
unset(CMAKE_LIBRARY_PATH CACHE)
# Enable C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# Вимкнути кешування шляхів, що викликає проблеми
set(CMAKE_SKIP_RPATH OFF)
set(CMAKE_SKIP_BUILD_RPATH OFF)
# Include Threads
find_package(Threads REQUIRED)
# Find or fetch Google Test
find_package(GTest QUIET)
if (NOT GTest_FOUND)
    include(FetchContent)
    FetchContent_Declare(
        googletest
        URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
    )
    FetchContent_MakeAvailable(googletest)
endif ()
# Add static library for math_operations
add_library(math_operations STATIC
    math_operations.cpp
    math_operations.h
)
# Add executable for the main application
add_executable(test_app
    main.cpp
)
# Link math_operations to the main application
target_link_libraries(test_app PRIVATE math_operations)
# Add unit test target
add_executable(unit_tests
    tests/unit_tests.cpp
)
# Link math_operations, GTest, and Threads to unit_tests
target_link_libraries(unit_tests PRIVATE math_operations GTest::gtest GTest::gtest_main Threads::Threads)
# Enable testing
enable_testing()
# Register the unit tests
add_test(NAME UnitTests COMMAND unit_tests)
# Add a custom target to run tests
add_custom_target(run_tests
    COMMAND ctest -C $<CONFIG> --output-on-failure
    DEPENDS unit_tests
)
# Примітка: Якщо потрібен vcpkg, додай: vcpkg integrate install (локально) або інтегруй у CI