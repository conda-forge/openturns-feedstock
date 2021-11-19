#!/bin/sh

mkdir build && cd build

cmake -LAH \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  -DSWIG_COMPILE_FLAGS="-O1" \
  -DUSE_R=OFF \
  ..
make install -j${CPU_COUNT}
rm -r ${PREFIX}/share/gdb
if test "${BUILD}" == "${HOST}"
then
  ctest -R pyinstallcheck --output-on-failure -j${CPU_COUNT} -E "GeneralizedParetoFactory_std|KrigingAlgorithm_std"
fi
