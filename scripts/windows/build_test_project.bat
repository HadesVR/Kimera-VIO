@echo off
setlocal
for %%I in ("%~dp0..\..") do set "KVIO_ROOT=%%~fI"
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"

msbuild "%KVIO_ROOT%\sdk_test\test.vcxproj" /p:Configuration=Release /p:Platform=x64 /v:normal
if errorlevel 1 exit /b 1

msbuild "%KVIO_ROOT%\sdk_test\test.vcxproj" /p:Configuration=Debug /p:Platform=x64 /v:normal
if errorlevel 1 exit /b 1

echo TEST_PROJECT_BUILD_COMPLETE_OK
