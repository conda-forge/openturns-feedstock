
:: remove -GL from CXXFLAGS
set "CXXFLAGS=-MD"

:: from Azure
set "Boost_ROOT="

mkdir build && cd build
cmake -LAH -G "Ninja" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR="Library/lib" ^
    -DCMAKE_INSTALL_BINDIR="Library/bin" ^
    -DCMAKE_INSTALL_INCLUDEDIR="Library/include" ^
    -DCMAKE_INSTALL_DATAROOTDIR="Library/share" ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
    -DPython_FIND_STRATEGY=LOCATION ^
    -DPython_ROOT_DIR="%PREFIX%" ^
    ..
if errorlevel 1 exit 1

cmake --build . --target install --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit 1

ctest --config Release -R pyinstallcheck --output-on-failure --timeout 1000
if errorlevel 1 exit 1

exit 1
