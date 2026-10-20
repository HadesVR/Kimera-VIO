cmake_minimum_required(VERSION 3.20)
project(kimera_vio_dll VERSION 1.0 LANGUAGES CXX C)

# HadesVR: Kimera-VIO as one Windows DLL (kimera_vio.dll + its import library),
# compiled from this source tree against the prebuilt dependencies in ../sdk
# (headers and static libraries, built by scripts/windows/). Everything Kimera
# needs is linked in, so the DLL depends only on Windows and the VC++ runtime.
# scripts/windows/build_kimera_dll.bat drives it.
#
# Exported: every public symbol of Kimera's own objects (WINDOWS_EXPORT_ALL_SYMBOLS),
# all of glog and gflags (Kimera's logging and settings live in this DLL, so a
# program sets them here), and kimera_dll.h. A program using the DLL must not
# link its own glog or gflags.

if(NOT MSVC)
    message(FATAL_ERROR "The DLL build is for MSVC; elsewhere build Kimera-VIO with its own CMakeLists.txt.")
endif()

set(KVIO_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/..")
set(KIMERA_SDK_DIR "${KVIO_ROOT}/sdk" CACHE PATH "Prebuilt dependencies (headers + static libraries)")
set(SDK_LIB_DIR "${KIMERA_SDK_DIR}/lib/Release")
if(NOT EXISTS "${SDK_LIB_DIR}/libgtsam.lib")
    message(FATAL_ERROR "No prebuilt dependencies at ${KIMERA_SDK_DIR} (set KIMERA_SDK_DIR)")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
# The dependencies are Release /MD only, and Kimera's own build used CMake's
# Release flags (/O2 /Ob2 /DNDEBUG): the same here, so results match the SDK.
set(CMAKE_CONFIGURATION_TYPES "Release" CACHE STRING "" FORCE)
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")

add_library(kimera_vio SHARED "${CMAKE_CURRENT_SOURCE_DIR}/kimera_dll.cpp")
set_target_properties(kimera_vio PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)

# Kimera's own source lists (the same folders as ../CMakeLists.txt). Pangolin is in
# the SDK, as it was for the SDK's Kimera build.
set(Pangolin_FOUND TRUE)
foreach(dir dataprovider playground frontend backend factors mesh initial utils
            pipeline common loopclosure logging imu-frontend visualizer)
    add_subdirectory("${KVIO_ROOT}/src/${dir}" "src/${dir}")
endforeach()
add_subdirectory("${KVIO_ROOT}/third_party/triangle" "third_party/triangle")

# This tree's headers first: sdk/include also holds a copy of Kimera's.
target_include_directories(kimera_vio
    PUBLIC
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${KVIO_ROOT}/include"
    PRIVATE
        "${KIMERA_SDK_DIR}/include"
        "${KIMERA_SDK_DIR}/include/opencv4"
        "${KIMERA_SDK_DIR}/include/gtsam/3rdparty/Eigen")
target_compile_options(kimera_vio PRIVATE /bigobj /wd4251 /wd4275)
# Kimera's own definitions, then what the dependencies' CMake packages would add
# (the SDK has none): Pangolin's Windows switches, glog's export macros.
# OpenCV's Eigen Tensor support wants Eigen's unsupported modules, which the
# SDK's Eigen lacks; Kimera doesn't use it.
target_compile_definitions(kimera_vio PRIVATE
    _CRT_SECURE_NO_WARNINGS _SCL_SECURE_NO_WARNINGS _USE_MATH_DEFINES NOMINMAX
    Pangolin_FOUND=1 _WIN_ HAVE_GLEW GLOG_USE_GLOG_EXPORT OPENCV_DISABLE_EIGEN_TENSOR_SUPPORT
    KIMERA_DLL_BUILD)

# glog and gflags go in as objects rather than libraries, so that the export list
# (made from the target's objects) carries them.
function(lib_objects lib out_var)
    get_filename_component(name "${lib}" NAME_WE)
    set(dir "${CMAKE_BINARY_DIR}/lib_objects/${name}")
    execute_process(COMMAND "${CMAKE_AR}" /NOLOGO /LIST "${lib}"
                    OUTPUT_VARIABLE members RESULT_VARIABLE rc OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(rc)
        message(FATAL_ERROR "lib /LIST ${lib} failed")
    endif()
    string(REPLACE "\r" "" members "${members}")
    string(REPLACE "\n" ";" members "${members}")
    file(MAKE_DIRECTORY "${dir}")
    set(objs "")
    set(i 0)
    foreach(m IN LISTS members)
        string(REPLACE "\\" "/" base "${m}")
        get_filename_component(base "${base}" NAME)
        set(obj "${dir}/${i}_${base}")
        if(NOT EXISTS "${obj}")
            execute_process(COMMAND "${CMAKE_AR}" /NOLOGO "/EXTRACT:${m}" "/OUT:${obj}" "${lib}" RESULT_VARIABLE rc)
            if(rc)
                message(FATAL_ERROR "lib /EXTRACT:${m} ${lib} failed")
            endif()
        endif()
        list(APPEND objs "${obj}")
        math(EXPR i "${i} + 1")
    endforeach()
    set(${out_var} "${objs}" PARENT_SCOPE)
endfunction()
lib_objects("${SDK_LIB_DIR}/glog.lib" GLOG_OBJS)
lib_objects("${SDK_LIB_DIR}/gflags_static.lib" GFLAGS_OBJS)
target_sources(kimera_vio PRIVATE ${GLOG_OBJS} ${GFLAGS_OBJS})

# Every other prebuilt library; the linker keeps only what Kimera uses.
file(GLOB SDK_LIBS "${SDK_LIB_DIR}/*.lib")
list(FILTER SDK_LIBS EXCLUDE REGEX "/(kimera_vio|triangle|glog|gflags_static)\\.lib$")
target_link_libraries(kimera_vio PRIVATE triangle ${SDK_LIBS}
    ws2_32 wsock32 winmm Iphlpapi Rpcrt4 Bcrypt Ncrypt Crypt32 Vfw32 gdi32 comdlg32
    ole32 oleaut32 uuid opengl32 glu32 shlwapi version dbghelp psapi)
# 4217/4049: symbols the headers declare as imported but that are linked in here.
target_link_options(kimera_vio PRIVATE /IGNORE:4217,4049,4286)
