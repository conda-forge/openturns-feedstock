#!/bin/sh

git clone -b msvc --depth 1 https://github.com/persalys/persalys.git
cd persalys

mkdir build && cd build

cmake ${CMAKE_ARGS} -LAH -G "Ninja" \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DPython_FIND_STRATEGY=LOCATION \
  -DPython_ROOT_DIR=${PREFIX} \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  ..
cmake --build . --target instal
if test "$CONDA_BUILD_CROSS_COMPILATION" != "1"
then
  ctest -R pyinstallcheck --output-on-failure --schedule-random -j${CPU_COUNT}
fi
