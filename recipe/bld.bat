
:: remove sh.exe from PATH
set PATH=%PATH:C:\Program Files\Git\usr\bin;=%

:: swig modules need proper stack alignment on 32 bit
if "%ARCH%"=="32" (set SWIG_CXX_FLAGS="-mstackrealign") else (set SWIG_CXX_FLAGS="")

mkdir build && cd build

:: Configure.
cmake -G "MinGW Makefiles" ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%/mingw-w64 ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%/mingw-w64 ^
  -DLAPACK_LIBRARIES=%LIBRARY_PREFIX%/mingw-w64/lib/libopenblas.dll.a ^
  -DPYTHON_LIBRARY=%PREFIX%\libs\libpython%CONDA_PY%.dll.a ^
  -DCMAKE_C_FLAGS_RELEASE="-O2 -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4" ^
  -DCMAKE_CXX_FLAGS_RELEASE="-O2 -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4 %SWIG_CXX_FLAGS%" ^
  -DSITE_PACKAGE=%SP_DIR% ^
  ..
if errorlevel 1 exit 1

:: Build.
mingw32-make install -j %CPU_COUNT% VERBOSE=1
if errorlevel 1 exit 1
