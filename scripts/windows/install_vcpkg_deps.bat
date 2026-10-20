@echo off
setlocal
for %%I in ("%~dp0..\..") do set "KVIO_ROOT=%%~fI"
rem The vcpkg dependencies in vcpkg.json (triplet x64-windows-static-md), installed
rem into build\vcpkg-artifacts, where the build_*.bat scripts look for them.
rem Only needed to rebuild the SDK: it takes hours and ~20 GB. The prebuilt sdk\
rem already holds every library and header.
cd /d "%KVIO_ROOT%"
"%KVIO_ROOT%\vcpkg\vcpkg.exe" install --triplet x64-windows-static-md ^
  --downloads-root="%KVIO_ROOT%\build\vcpkg-artifacts\downloads" ^
  --x-buildtrees-root="%KVIO_ROOT%\build\vcpkg-artifacts\buildtrees" ^
  --x-packages-root="%KVIO_ROOT%\build\vcpkg-artifacts\packages" ^
  --x-install-root="%KVIO_ROOT%\build\vcpkg-artifacts\installed"
if errorlevel 1 exit /b 1
echo VCPKG_DEPS_COMPLETE_OK
