@echo off
setlocal
for %%I in ("%~dp0..\..") do set "KVIO_ROOT=%%~fI"
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
set "PATH=C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;%PATH%"

set "EIGEN_DIR=%KVIO_ROOT%\deps\gtsam\gtsam\3rdparty\Eigen"
set "SRC=%KVIO_ROOT%\deps\opengv"
set "BUILD=%KVIO_ROOT%\build\opengv-build"
set "INSTALL=%KVIO_ROOT%\build\install\opengv"

rem Setting CMAKE_CXX_FLAGS replaces CMake's MSVC defaults, which define WIN32. opengv's
rem random_generators helper (built even with BUILD_TESTS=OFF) needs WIN32 for its
rem gettimeofday shim, so put it back rather than patch upstream.
cmake -S "%SRC%" -B "%BUILD%" -G "Ninja Multi-Config" ^
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL%" ^
  -DEIGEN_INCLUDE_DIR="%EIGEN_DIR%" ^
  -DEIGEN_INCLUDE_DIRS="%EIGEN_DIR%" ^
  -DBUILD_TESTS=OFF ^
  -DBUILD_PYTHON=OFF ^
  -DCMAKE_CXX_FLAGS="/DWIN32 /D_WINDOWS /FI cassert"
if errorlevel 1 exit /b 1

cmake --build "%BUILD%" --config Release -j
if errorlevel 1 exit /b 1
cmake --build "%BUILD%" --config Debug -j
if errorlevel 1 exit /b 1

cmake --install "%BUILD%" --config Release
if errorlevel 1 exit /b 1
cmake --install "%BUILD%" --config Debug
if errorlevel 1 exit /b 1

echo OPENGV_BUILD_COMPLETE_OK
