
curl -fsSLO https://github.com/openturns/build/releases/download/v%PKG_VERSION%/openturns-%PKG_VERSION%-py%PY_VER%-x86_64.exe
if errorlevel 1 exit 1

openturns-%PKG_VERSION%-py%PY_VER%-x86_64.exe /userlevel=1 /S /FORCE /D=%PREFIX%
if errorlevel 1 exit 1

exit 0

: remove sh.exe from PATH
set PATH=%PATH:C:\Program Files\Git\usr\bin;=%

mkdir build && cd build

:: Configure.
cmake -G "MinGW Makefiles" ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX:\=/%/mingw-w64 ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX:\=/%/mingw-w64 ^
  -DLAPACK_LIBRARIES=%LIBRARY_PREFIX:\=/%/mingw-w64/lib/libopenblas.dll.a ^
  -DPYTHON_LIBRARY=%PREFIX:\=/%/libs/libpython%CONDA_PY%.dll.a ^
  -DCMAKE_C_FLAGS_RELEASE="-O2 -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4" ^
  -DCMAKE_CXX_FLAGS_RELEASE="-O2 -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4" ^
  -DPYTHON_SITE_PACKAGES="%SP_DIR:\=/%" ^
  -DUSE_COTIRE=ON -DCOTIRE_MAXIMUM_NUMBER_OF_UNITY_INCLUDES="-j16" ^
  -DUSE_EXPRTK=OFF ^
  ..
:: note: disable ExprTk because linking takes forever
if errorlevel 1 exit 1

:: Build.
mingw32-make install -j %CPU_COUNT%
if errorlevel 1 exit 1

:: Run features test.
python ..\python\test\t_features.py
if errorlevel 1 exit 1
