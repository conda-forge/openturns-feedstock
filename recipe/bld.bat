del /s /q "C:\Program Files\R"

curl -fsSLO https://github.com/openturns/build/releases/download/v%PKG_VERSION%/openturns-%PKG_VERSION%-py%PY_VER%-x86_64.exe
if errorlevel 1 exit 1

openturns-%PKG_VERSION%-py%PY_VER%-x86_64.exe /userlevel=1 /S /FORCE /D=%PREFIX%
if errorlevel 1 exit 1

:: our lapack libs conflict when numpy is loaded first
del %SP_DIR%\openturns\libblas.dll
del %SP_DIR%\openturns\libcblas.dll
del %SP_DIR%\openturns\liblapack.dll
del %SP_DIR%\openturns\liblapacke.dll

cmake -LAH -G "Ninja" -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" -DBLAS_LIBRARIES=1 -DLAPACK_LIBRARIES=1 -DPython_FIND_STRATEGY=LOCATION -DPython_ROOT_DIR="%PREFIX%" .
if errorlevel 1 exit 1

ctest -R pyinstallcheck --output-on-failure --timeout 1000 -E "docstring|example"
if errorlevel 1 exit 1
