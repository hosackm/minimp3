cmake_minimum_required(VERSION 3.10)
project(mp3decode C)

# Generate compile_commands.json for use with tools like clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Enable C compiler warnings
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Werror")

# Enable Address Sanitizer (for debugging purposes)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=address")

# Add include directories
include_directories(${PROJECT_SOURCE_DIR}/vendor/minimp3)

# Specify the source files
set(SOURCE_FILES src/main.c)

# Add the executable target
add_executable(mp3decode ${SOURCE_FILES})

# Set the compile options
target_compile_options(mp3decode PRIVATE -O3)
