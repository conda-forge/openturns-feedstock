
:: remove -GL from CXXFLAGS
set "CXXFLAGS=-MD"

:: from Azure
set "Boost_ROOT="

mkdir build && cd build
cmake -LAH -G "Ninja" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 ^
    -DPython_FIND_STRATEGY=LOCATION ^
    -DPython_ROOT_DIR="%PREFIX%" ^
    -DPYTHON_SITE_PACKAGES=../Lib/site-packages ^
    ..
if errorlevel 1 exit 1

cmake --build . --target install --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit 1

ctest --config Release -R pyinstallcheck --output-on-failure --timeout 1000 -j%CPU_COUNT%
::if errorlevel 1 exit 1

