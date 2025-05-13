# CMakeList.txt: mspm0cmake 的 CMake 项目，在此处包括源代码并定义
# 项目特定的逻辑。

cmake_minimum_required (VERSION 3.12)
set(CMAKE_MAKE_PROGRAM Ninja)
set(CMAKE_GENERATOR Ninja)

set(MSPM0_SDK_INSTALL_DIR "D:/envs/PROJECTS/ti/mspm0-sdk")
set(GCC_ARMCOMPILER "D:/Programs/xpack-arm-none-eabi-gcc-14.2.1-1.1")
set(SYSCONFIG_TOOL_DIR "D:/Programs/ccs2011/ccs/utils/sysconfig_1.23.0")
set(CMAKE_BUILD_TYPE Debug)
include(mspm0_import.cmake)

project(empty C CXX)
# 将源代码添加到此项目的可执行文件。
add_executable (
	${PROJECT_NAME} 
	"empty.cpp" 
)
MSPM0_INIT("${PROJECT_SOURCE_DIR}/startup_mspm0g350x_gcc.c")

