# CMake Project template for mspm0

此为CMake示例模板，用于TI的MSPM0单片机程序的编译工作，源自TI CCS 20.1.1导入`examples/nortos/LP_MSPM0G3507/driverlib/empty_cpp`的示例工程，
使用[mspm0-sdk](https://github.com/TexasInstruments/mspm0-sdk)。该模板：
- 使用 TI SysConfig 生成驱动配置代码和头文件、链接脚本
- 支持 Gcc ARM Toolchain 交叉编译[arm-none-eabi-gcc-xpack](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack)
- 更现代、更可扩展的构建流程
