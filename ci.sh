
#!/bin/bash

# Create build directory if it doesn't exist
if [ ! -d "build" ]; then
    echo "Creating build directory..."
    mkdir build
fi

# Navigate to the build directory
cd build

# Run CMake configuration
echo "Configuring the project with CMake..."
if ! cmake ..; then
    echo "CMake configuration failed."
    exit 1
fi

# Build the project
echo "Building the project..."
if ! cmake --build .; then
    echo "Build failed."
    exit 1
fi

# Run tests with CTest
echo "Running tests..."
if ! ctest; then
    echo "Tests failed."
    exit 1
fi

echo "Build and tests completed successfully."