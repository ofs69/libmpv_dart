cmake_minimum_required(VERSION 3.10)

# 查找 libmpv 的包
find_package(PkgConfig REQUIRED)
pkg_search_module(MPV REQUIRED IMPORTED_TARGET mpv)

# 检查 libmpv 是否找到
if(MPV_FOUND)
    message(STATUS "Found libmpv at: ${MPV_LIBRARIES} ${MPV_INCLUDE_DIRS}")
else()
    message(FATAL_ERROR "libmpv not found. Please install libmpv-dev.")
endif()

# 拷贝 libmpv 的 .so 文件到构建目录的 libmpv 文件夹
if(UNIX)
    file(INSTALL ${CMAKE_CURRENT_SOURCE_DIR}/dynamicLib/linux/ DESTINATION ${CMAKE_BINARY_DIR}/lib)
elseif(WIN32)
    file(INSTALL ${CMAKE_CURRENT_SOURCE_DIR}/dynamicLib/windows/ DESTINATION ${CMAKE_BINARY_DIR}/lib)
else()

endif()

