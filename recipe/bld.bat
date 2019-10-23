
curl -fsSLO https://github.com/openturns/build/releases/download/v%PKG_VERSION%/openturns-%PKG_VERSION%-py%PY_VER%-x86_64.exe
if errorlevel 1 exit 1

openturns-%PKG_VERSION%-py%PY_VER%-x86_64.exe /userlevel=1 /S /FORCE /D=%PREFIX%
if errorlevel 1 exit 1

