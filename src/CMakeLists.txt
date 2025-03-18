cmake_minimum_required(VERSION 3.10)

# 预构建的动态链接库路径
if(UNIX)

    find_package(PkgConfig REQUIRED)
    pkg_check_modules(MPV REQUIRED IMPORTED_TARGET GLOBAL mpv)
    set(MPV_LIBRARY_PATH ${MPV_LIBRARY_DIRS}/libmpv.so)
    
elseif(WIN32)
    file(GLOB MPV_LIBRARY_PATH "${CMAKE_CURRENT_SOURCE_DIR}/dynamicLib/windows/*")
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

# 将路径传递给父作用域
set(MPV_LIBRARY_PATH "${MPV_LIBRARY_PATH}"
    PARENT_SCOPE
)

