
: remove sh.exe from PATH
set PATH=%PATH:C:\Program Files\Git\usr\bin;=%

mkdir build && cd build

:: Configure.
cmake -G "MinGW Makefiles" ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX:\=/%/mingw-w64 ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX:\=/%/mingw-w64 ^
  -DLAPACK_LIBRARIES=%LIBRARY_PREFIX:\=/%/mingw-w64/lib/libopenblas.dll.a ^
  -DPYTHON_LIBRARY=%PREFIX%/libs/libpython%CONDA_PY%.dll.a ^
  -DCMAKE_C_FLAGS_RELEASE="-O2 -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4 -DNDEBUG -DMS_WIN64" ^
  -DCMAKE_CXX_FLAGS_RELEASE="-O2 -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4 -DNDEBUG -DMS_WIN64 -D_hypot=hypot" ^
  -DPYTHON_SITE_PACKAGES="%SP_DIR:\=/%" ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DUSE_COTIRE=ON -DCOTIRE_MAXIMUM_NUMBER_OF_UNITY_INCLUDES="-j16" ^
  ..
if errorlevel 1 exit 1

:: Build.
mingw32-make install -j %CPU_COUNT%
if errorlevel 1 exit 1

ctest -R pyinstallcheck --output-on-failure -j %CPU_COUNT%
if errorlevel 1 exit 1
