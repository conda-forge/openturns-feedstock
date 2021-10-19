#!/bin/sh

if test `uname` = "Linux"
then
  export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${PREFIX}/lib"
fi

mkdir build && cd build

cmake -LAH \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_MACOSX_RPATH=ON \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  -DSWIG_COMPILE_FLAGS="-O1" \
  -DUSE_R=OFF \
  -DUSE_BONMIN=OFF \
  ..
make install -j${CPU_COUNT}
rm -r ${PREFIX}/share/gdb
ctest -R pyinstallcheck --output-on-failure -j${CPU_COUNT} -E "GeneralizedParetoFactory_std|KrigingAlgorithm_std"
