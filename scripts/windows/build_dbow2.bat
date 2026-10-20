@echo off
setlocal
for %%I in ("%~dp0..\..") do set "KVIO_ROOT=%%~fI"
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
set "PATH=C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;%PATH%"

set "VCPKG_ROOT=%KVIO_ROOT%\vcpkg"
set "TOOLCHAIN=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake"
set "TRIPLET=x64-windows-static-md"
set "SRC=%KVIO_ROOT%\deps\DBoW2"
set "BUILD=%KVIO_ROOT%\build\dbow2-build"
set "INSTALL=%KVIO_ROOT%\build\install\dbow2"
set "OpenCV_DIR=%KVIO_ROOT%\build\vcpkg-artifacts\installed\x64-windows-static-md\share\opencv4"
set "TRIPLET_ROOT=%KVIO_ROOT%\build\vcpkg-artifacts\installed\x64-windows-static-md"

rem DBoW2 is an upstream git submodule; our build changes (patches\DBoW2.patch:
rem vcpkg's BZip2/Iconv targets, the Debug suffix) go on top unless already there.
git -C "%SRC%" apply --reverse --check "%~dp0patches\DBoW2.patch" >nul 2>&1
if errorlevel 1 (
  git -C "%SRC%" apply "%~dp0patches\DBoW2.patch"
  if errorlevel 1 exit /b 1
)

cmake -S "%SRC%" -B "%BUILD%" -G "Ninja Multi-Config" ^
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
  -DCMAKE_TOOLCHAIN_FILE="%TOOLCHAIN%" ^
  -DVCPKG_TARGET_TRIPLET=%TRIPLET% ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL%" ^
  -DOpenCV_DIR="%OpenCV_DIR%" ^
  -DCMAKE_PREFIX_PATH="%TRIPLET_ROOT%" ^
  -DProtobuf_PROTOC_EXECUTABLE="%KVIO_ROOT%\build\vcpkg-artifacts\installed\x64-windows\tools\protobuf\protoc.exe" ^
  -DZLIB_INCLUDE_DIR="%TRIPLET_ROOT%\include" ^
  -DZLIB_LIBRARY_RELEASE="%TRIPLET_ROOT%\lib\zs.lib" ^
  -DZLIB_LIBRARY_DEBUG="%TRIPLET_ROOT%\debug\lib\zsd.lib" ^
  -DBZIP2_INCLUDE_DIR="%TRIPLET_ROOT%\include" ^
  -DBZIP2_LIBRARY_RELEASE="%TRIPLET_ROOT%\lib\bz2.lib" ^
  -DBZIP2_LIBRARY_DEBUG="%TRIPLET_ROOT%\debug\lib\bz2d.lib" ^
  -DIconv_INCLUDE_DIR="%TRIPLET_ROOT%\include" ^
  -DIconv_LIBRARY="%TRIPLET_ROOT%\lib\iconv.lib" ^
  -DBUILD_DBoW2=ON ^
  -DBUILD_Demo=OFF
if errorlevel 1 exit /b 1

cmake --build "%BUILD%" --config Release -j
if errorlevel 1 exit /b 1
cmake --build "%BUILD%" --config Debug -j
if errorlevel 1 exit /b 1

cmake --install "%BUILD%" --config Release
if errorlevel 1 exit /b 1
cmake --install "%BUILD%" --config Debug
if errorlevel 1 exit /b 1

echo DBOW2_BUILD_COMPLETE_OK
