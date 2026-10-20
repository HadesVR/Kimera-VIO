@echo off
setlocal
for %%I in ("%~dp0..\..") do set "KVIO_ROOT=%%~fI"
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
set "PATH=C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;%PATH%"

set "VCPKG_ROOT=%KVIO_ROOT%\vcpkg"
set "TOOLCHAIN=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake"
set "TRIPLET=x64-windows-static-md"
set "SRC=%KVIO_ROOT%\deps\gtsam"
set "BUILD=%KVIO_ROOT%\build\gtsam-build"
set "INSTALL=%KVIO_ROOT%\build\install\gtsam"
set "TRIPLET_ROOT=%KVIO_ROOT%\build\vcpkg-artifacts\installed\x64-windows-static-md"

cmake -S "%SRC%" -B "%BUILD%" -G "Ninja Multi-Config" ^
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
  -DCMAKE_POLICY_DEFAULT_CMP0167=NEW ^
  -DCMAKE_TOOLCHAIN_FILE="%TOOLCHAIN%" ^
  -DVCPKG_TARGET_TRIPLET=%TRIPLET% ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL%" ^
  -DBoost_DIR="%TRIPLET_ROOT%\share\boost" ^
  -DBoost_NO_BOOST_CMAKE=OFF ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DGTSAM_BUILD_TESTS=OFF ^
  -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF ^
  -DGTSAM_BUILD_TIMING_ALWAYS=OFF ^
  -DGTSAM_BUILD_UNSTABLE=ON ^
  -DGTSAM_USE_SYSTEM_EIGEN=OFF ^
  -DGTSAM_POSE3_EXPMAP=ON ^
  -DGTSAM_ROT3_EXPMAP=ON ^
  -DGTSAM_TANGENT_PREINTEGRATION=OFF ^
  -DGTSAM_WITH_TBB=ON ^
  -DGTSAM_BUILD_PYTHON=OFF ^
  -DGTSAM_INSTALL_MATLAB_TOOLBOX=OFF
if errorlevel 1 exit /b 1

cmake --build "%BUILD%" --config Release -j
if errorlevel 1 exit /b 1
cmake --build "%BUILD%" --config Debug -j
if errorlevel 1 exit /b 1

cmake --install "%BUILD%" --config Release
if errorlevel 1 exit /b 1
cmake --install "%BUILD%" --config Debug
if errorlevel 1 exit /b 1

echo GTSAM_BUILD_COMPLETE_OK
