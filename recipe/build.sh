#!/bin/sh

git clone -b misc --depth 1 https://github.com/jschueller/openturns.git
cd openturns
mkdir build && cd build
cmake ${CMAKE_ARGS} -LAH -G "Ninja" \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DPython_FIND_STRATEGY=LOCATION \
  -DPython_ROOT_DIR=${PREFIX} \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  -DSWIG_COMPILE_FLAGS="-O1" \
  -D_HAVE_FR_LOC_RUNS=0 \
  ..
cmake --build . --target install


git clone --depth 1 https://github.com/openturns/otmorris.git
cd otmorris
mkdir build && cd build
cmake ${CMAKE_ARGS} -LAH -G "Ninja" \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DPython_FIND_STRATEGY=LOCATION \
  -DPython_ROOT_DIR=${PREFIX} \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  -DSWIG_COMPILE_FLAGS="-O1" \
  ..
cmake --build . --target install


git clone -b msvc --depth 1 https://github.com/persalys/persalys.git
cd persalys
mkdir build && cd build
cmake ${CMAKE_ARGS} -LAH -G "Ninja" \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DPython_FIND_STRATEGY=LOCATION \
  -DPython_ROOT_DIR=${PREFIX} \
  -DPython3_FIND_STRATEGY=LOCATION \
  -DPython3_ROOT_DIR=${PREFIX} \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  -DSWIG_COMPILE_FLAGS="-O1" \
  -DUSE_SALOME=OFF -DUSE_PARAVIEW=OFF \
  ..
cmake --build . --target install
if test "$CONDA_BUILD_CROSS_COMPILATION" != "1"
then
  ctest -R pyinstallcheck --output-on-failure --schedule-random -j${CPU_COUNT} -E DataModel
fi
