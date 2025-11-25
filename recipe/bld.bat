
:: remove -GL from CXXFLAGS
set "CXXFLAGS=-MD"

:: from Azure
set "Boost_ROOT="

cmake -LAH -G "Ninja" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 ^
    -DBLA_VENDOR=Generic ^
    -DPython_FIND_STRATEGY=LOCATION ^
    -DPython_ROOT_DIR="%PREFIX%" ^
    -DOPENTURNS_PYTHON_MODULE_PATH=../Lib/site-packages ^
    -DSWIG_COMPILE_FLAGS="/DPy_LIMITED_API=0x030A0000" -DUSE_PYTHON_SABI=ON ^
    -B build .
if errorlevel 1 exit 1

cmake --build build --target install --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit 1

ctest --test-dir build -R pyinstallcheck --output-on-failure --timeout 1000 -j%CPU_COUNT%
if errorlevel 1 exit 1

