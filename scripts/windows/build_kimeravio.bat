@echo off
setlocal
for %%I in ("%~dp0..\..") do set "KVIO_ROOT=%%~fI"
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
set "PATH=C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;%PATH%"

set "VCPKG_ROOT=%KVIO_ROOT%\vcpkg"
set "TOOLCHAIN=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake"
set "TRIPLET=x64-windows-static-md"
set "SRC=%KVIO_ROOT%"
set "BUILD=%KVIO_ROOT%\build\kimeravio-build"
set "INSTALL=%KVIO_ROOT%\build\install\kimeravio"
set "TRIPLET_ROOT=%KVIO_ROOT%\build\vcpkg-artifacts\installed\x64-windows-static-md"
set "GTSAM_INSTALL=%KVIO_ROOT%\build\install\gtsam"
set "OPENGV_INSTALL=%KVIO_ROOT%\build\install\opengv"
set "DBOW2_INSTALL=%KVIO_ROOT%\build\install\dbow2"
set "KIMERARPGO_INSTALL=%KVIO_ROOT%\build\install\kimerarpgo"
set "OpenCV_DIR=%TRIPLET_ROOT%\share\opencv4"

cmake -S "%SRC%" -B "%BUILD%" -G "Ninja Multi-Config" ^
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
  -DCMAKE_POLICY_DEFAULT_CMP0167=NEW ^
  -DCMAKE_TOOLCHAIN_FILE="%TOOLCHAIN%" ^
  -DVCPKG_TARGET_TRIPLET=%TRIPLET% ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL%" ^
  -DCMAKE_PREFIX_PATH="%GTSAM_INSTALL%;%OPENGV_INSTALL%;%DBOW2_INSTALL%;%KIMERARPGO_INSTALL%;%TRIPLET_ROOT%" ^
  -DBoost_DIR="%TRIPLET_ROOT%\share\boost" ^
  -DOpenCV_DIR="%OpenCV_DIR%" ^
  -DProtobuf_PROTOC_EXECUTABLE="%KVIO_ROOT%\build\vcpkg-artifacts\installed\x64-windows\tools\protobuf\protoc.exe" ^
  -DZLIB_INCLUDE_DIR="%TRIPLET_ROOT%\include" ^
  -DZLIB_LIBRARY="%TRIPLET_ROOT%\lib\zs.lib" ^
  -DZLIB_LIBRARY_RELEASE="%TRIPLET_ROOT%\lib\zs.lib" ^
  -DZLIB_LIBRARY_DEBUG="%TRIPLET_ROOT%\debug\lib\zsd.lib" ^
  -DBZIP2_INCLUDE_DIR="%TRIPLET_ROOT%\include" ^
  -DBZIP2_LIBRARY_RELEASE="%TRIPLET_ROOT%\lib\bz2.lib" ^
  -DBZIP2_LIBRARY_DEBUG="%TRIPLET_ROOT%\debug\lib\bz2d.lib" ^
  -DIconv_INCLUDE_DIR="%TRIPLET_ROOT%\include" ^
  -DIconv_LIBRARY="%TRIPLET_ROOT%\lib\iconv.lib" ^
  -DKIMERA_BUILD_TESTS=OFF ^
  -DKIMERA_BUILD_EXAMPLE=OFF
if errorlevel 1 exit /b 1

cmake --build "%BUILD%" --config Release -j
if errorlevel 1 exit /b 1
cmake --build "%BUILD%" --config Debug -j
if errorlevel 1 exit /b 1

cmake --install "%BUILD%" --config Release
if errorlevel 1 exit /b 1
cmake --install "%BUILD%" --config Debug
if errorlevel 1 exit /b 1

echo KIMERAVIO_BUILD_COMPLETE_OK
