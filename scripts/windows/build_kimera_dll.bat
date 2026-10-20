@echo off
setlocal
for %%I in ("%~dp0..\..") do set "KVIO_ROOT=%%~fI"
rem kimera_vio.dll and its import library kimera_vio.lib, from this source tree
rem against the prebuilt dependencies in sdk\ (see dll\CMakeLists.txt). Output in
rem build\dll\. Needs only sdk\: no vcpkg, no dependency rebuild.
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
set "PATH=C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;%PATH%"

set "BUILD=%KVIO_ROOT%\build\dll"

cmake -S "%KVIO_ROOT%\dll" -B "%BUILD%" -G Ninja -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit /b 1
cmake --build "%BUILD%" -j
rem A failed link can return -1, which "if errorlevel 1" misses.
if %errorlevel% neq 0 exit /b 1

echo KIMERA_DLL_BUILD_COMPLETE_OK
