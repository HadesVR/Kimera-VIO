$KVIO_ROOT = (Resolve-Path "$PSScriptRoot\..\..").Path   # the fork's root
$ErrorActionPreference = "Stop"

$SDK = "$KVIO_ROOT\sdk"
$KVIO_SRC = $KVIO_ROOT
$GTSAM = "$KVIO_ROOT\build\install\gtsam"
$OPENGV = "$KVIO_ROOT\build\install\opengv"
$DBOW2 = "$KVIO_ROOT\build\install\dbow2"
$RPGO = "$KVIO_ROOT\build\install\kimerarpgo"
$KVIO = "$KVIO_ROOT\build\install\kimeravio"
$VCPKG = "$KVIO_ROOT\build\vcpkg-artifacts\installed\x64-windows-static-md"

New-Item -ItemType Directory -Force -Path "$SDK\include" | Out-Null
New-Item -ItemType Directory -Force -Path "$SDK\lib\Release" | Out-Null
New-Item -ItemType Directory -Force -Path "$SDK\lib\Debug" | Out-Null
New-Item -ItemType Directory -Force -Path "$SDK\vocabulary" | Out-Null
New-Item -ItemType Directory -Force -Path "$SDK\params" | Out-Null

Write-Host "=== Copying headers ==="
robocopy "$KVIO_SRC\include" "$SDK\include" /E /NFL /NDL /NJH /NJS /MT:8 | Out-Null
robocopy "$GTSAM\include" "$SDK\include" /E /NFL /NDL /NJH /NJS /MT:8 | Out-Null
robocopy "$OPENGV\include" "$SDK\include" /E /NFL /NDL /NJH /NJS /MT:8 | Out-Null
robocopy "$DBOW2\include" "$SDK\include" /E /NFL /NDL /NJH /NJS /MT:8 | Out-Null
robocopy "$RPGO\include" "$SDK\include" /E /NFL /NDL /NJH /NJS /MT:8 | Out-Null
robocopy "$VCPKG\include" "$SDK\include" /E /NFL /NDL /NJH /NJS /MT:8 | Out-Null

Write-Host "=== Copying Release libs ==="
# vcpkg triplet (already release-named)
robocopy "$VCPKG\lib" "$SDK\lib\Release" *.lib /NFL /NDL /NJH /NJS /MT:8 | Out-Null
# hand-built deps: release-named files only (exclude Debug-suffixed variants)
Copy-Item "$KVIO\lib\kimera_vio.lib" "$SDK\lib\Release\"
Copy-Item "$KVIO\lib\triangle.lib" "$SDK\lib\Release\"
Copy-Item "$GTSAM\lib\libgtsam.lib" "$SDK\lib\Release\"
Copy-Item "$GTSAM\lib\libgtsam_unstable.lib" "$SDK\lib\Release\"
Copy-Item "$GTSAM\lib\metis-gtsam.lib" "$SDK\lib\Release\"
Copy-Item "$OPENGV\lib\opengv.lib" "$SDK\lib\Release\"
Copy-Item "$DBOW2\lib\DBoW2.lib" "$SDK\lib\Release\"
Copy-Item "$RPGO\lib\KimeraRPGO.lib" "$SDK\lib\Release\"
Copy-Item "$RPGO\lib\rpgo_max_clique.lib" "$SDK\lib\Release\"

Write-Host "=== Copying Debug libs ==="
robocopy "$VCPKG\debug\lib" "$SDK\lib\Debug" *.lib /NFL /NDL /NJH /NJS /MT:8 | Out-Null
Copy-Item "$KVIO\lib\kimera_viod.lib" "$SDK\lib\Debug\"
Copy-Item "$KVIO\lib\triangled.lib" "$SDK\lib\Debug\"
Copy-Item "$GTSAM\lib\libgtsamDebug.lib" "$SDK\lib\Debug\"
Copy-Item "$GTSAM\lib\libgtsam_unstableDebug.lib" "$SDK\lib\Debug\"
Copy-Item "$GTSAM\lib\metis-gtsamDebug.lib" "$SDK\lib\Debug\"
Copy-Item "$OPENGV\lib\opengvd.lib" "$SDK\lib\Debug\"
Copy-Item "$DBOW2\lib\DBoW2d.lib" "$SDK\lib\Debug\"
Copy-Item "$RPGO\lib\KimeraRPGOd.lib" "$SDK\lib\Debug\"
Copy-Item "$RPGO\lib\rpgo_max_cliqued.lib" "$SDK\lib\Debug\"

Write-Host "=== Copying vocabulary + params ==="
Copy-Item "$KVIO_SRC\vocabulary\ORBvoc.yml" "$SDK\vocabulary\"
Copy-Item "$KVIO_SRC\vocabulary\LICENSE.txt" "$SDK\vocabulary\"
robocopy "$KVIO_SRC\params" "$SDK\params" /E /NFL /NDL /NJH /NJS /MT:8 | Out-Null

Write-Host "=== Done. Sizes: ==="
$relCount = (Get-ChildItem "$SDK\lib\Release\*.lib").Count
$dbgCount = (Get-ChildItem "$SDK\lib\Debug\*.lib").Count
Write-Host "Release libs: $relCount"
Write-Host "Debug libs: $dbgCount"
