# TODO: Split into seperate include cmake file
# 编译工具链设置 
## 使用arm-none-eabi-gcc工具链  
## 从GCC_ARMCOMPILER获取工具链路径
set(CMAKE_SYSTEM_NAME               Generic)
set(CMAKE_SYSTEM_PROCESSOR          arm)
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_CXX_COMPILER_FORCED TRUE)
set(CMAKE_C_COMPILER_ID GNU)
set(CMAKE_CXX_COMPILER_ID GNU)
set(TOOLCHAIN_PREFIX                ${GCC_ARMCOMPILER}/bin/arm-none-eabi-)

message(STATUS "HOST is ${CMAKE_HOST_SYSTEM_NAME}")
if(CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
set(EXEC_SUFFIX ".exe")
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
set(EXEC_SUFFIX)
endif()

set(CMAKE_C_COMPILER                "${TOOLCHAIN_PREFIX}gcc${EXEC_SUFFIX}")
set(CMAKE_ASM_COMPILER              ${CMAKE_C_COMPILER}) 
set(CMAKE_CXX_COMPILER              ${TOOLCHAIN_PREFIX}g++${EXEC_SUFFIX})
set(CMAKE_LINKER                    ${TOOLCHAIN_PREFIX}ld${EXEC_SUFFIX})
set(CMAKE_OBJCOPY                   ${TOOLCHAIN_PREFIX}objcopy${EXEC_SUFFIX})
set(CMAKE_SIZE                      ${TOOLCHAIN_PREFIX}size${EXEC_SUFFIX})
set(CMAKE_EXECUTABLE_SUFFIX ".elf")
set(CMAKE_STATIC_LIBRARY_SUFFIX ".a")

function(mspm0_init STARTUPFILE)

add_custom_target(sysconfig
    COMMAND ${SYSCONFIG_TOOL_DIR}/sysconfig_cli --script "${PROJECT_SOURCE_DIR}/empty.syscfg" -o "${PROJECT_SOURCE_DIR}" -s "${MSPM0_SDK_INSTALL_DIR}/.metadata/product.json" --compiler gcc
    BYPRODUCTS generated_file.c
    DEPENDS ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}.syscfg
    COMMENT "Generate sysconfig files"
)

# 添加头文件目录（对应 Makefile 的 -I）
target_include_directories(
    ${PROJECT_NAME} PRIVATE
    # 项目包含
    "${PROJECT_SOURCE_DIR}" 
    # SDK包含
    "${MSPM0_SDK_INSTALL_DIR}/source/third_party/CMSIS/Core/Include" 
    "${MSPM0_SDK_INSTALL_DIR}/source" 
    # 编译器包含
    "${GCC_ARMCOMPILER}/arm-none-eabi/include/newlib-nano" 
    "${GCC_ARMCOMPILER}/arm-none-eabi/include" 
)

file(READ "${PROJECT_SOURCE_DIR}/device.opt" DEVICEOPT)
message(STATUS "Using device DEFINEs: ${DEVICEOPT}")

target_compile_options(
	${PROJECT_NAME} PUBLIC
    "${DEVICEOPT}"
    -mcpu=cortex-m0plus 
    -march=armv6-m 
    -mthumb 
    -mfloat-abi=soft 
    -O2
    -ffunction-sections 
    -fdata-sections 
    -g 
    -gdwarf-3 
    -gstrict-dwarf 
    -Wall

    $<$<COMPILE_LANGUAGE:C>:
        -std=c99
    >
    $<$<COMPILE_LANGUAGE:CXX>:
        -std=c++11
        -fno-threadsafe-statics 
    >
)

target_link_directories(
    ${PROJECT_NAME} PUBLIC
    "${MSPM0_SDK_INSTALL_DIR}/source" 
    "${GCC_ARMCOMPILER}/arm-none-eabi/lib/thumb/v6-m/nofp" 
    "${PROJECT_SOURCE_DIR}" 
    "${PROJECT_BINARY_DIR}/syscfg" 
)
target_link_libraries(
    ${PROJECT_NAME} PUBLIC
    -T${PROJECT_SOURCE_DIR}/device_linker.lds         # 手动指定链接脚本
    -T${PROJECT_SOURCE_DIR}/device.lds.genlibs        # 引入生成的链接脚本
    gcc
    c
    m
)
target_link_options(
    ${PROJECT_NAME} PUBLIC
    # Output Map
    -Wl,-Map,${PROJECT_NAME}.map            # 生成 map 文件

    -nostartfiles 
    -static
    -Wl,--gc-sections
    -march=armv6-m
    -mthumb
    --specs=nosys.specs

)


add_dependencies(${PROJECT_NAME} sysconfig)

message(STATUS "DEVICE: ${DEVICE} inatialized")
get_property(dirs TARGET ${PROJECT_NAME} PROPERTY INCLUDE_DIRECTORIES)
message(STATUS "Include directories for myapp: ${dirs}")
get_property(dirs TARGET ${PROJECT_NAME} PROPERTY COMPILE_OPTIONS)
message(STATUS "COMPILE_FLAGS ${dirs}")
get_property(dirs TARGET ${PROJECT_NAME} PROPERTY LINK_DIRECTORIES)
message(STATUS "LINK_DIRS ${dirs}")
get_property(dirs TARGET ${PROJECT_NAME} PROPERTY LINK_OPTIONS)
message(STATUS "LINK_OPTIONS ${dirs}")

target_sources(
    ${PROJECT_NAME} PUBLIC
    ${PROJECT_SOURCE_DIR}/ti_msp_dl_config.c
    ${STARTUPFILE}
)

add_custom_command(
    TARGET ${PROJECT_NAME}
    POST_BUILD
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}>)

add_custom_command(
    TARGET ${PROJECT_NAME}
    POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${PROJECT_NAME}>
            ${PROJECT_NAME}.hex)

add_custom_command(
    TARGET ${PROJECT_NAME}
    POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}>
            ${PROJECT_NAME}.bin)

endfunction()
