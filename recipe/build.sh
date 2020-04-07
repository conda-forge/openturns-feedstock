#!/bin/sh

if test `uname` = "Linux"
then
  export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${PREFIX}/lib"
fi

mkdir build && cd build

cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_MACOSX_RPATH=ON \
  -DUSE_COTIRE=ON -DCOTIRE_MAXIMUM_NUMBER_OF_UNITY_INCLUDES="-j8" \
  -DSWIG_COMPILE_FLAGS="-O1" \
  ..
make install -j${CPU_COUNT}
rm -r ${PREFIX}/share/gdb
ctest -R pyinstallcheck --output-on-failure -j${CPU_COUNT} -E docstring_model_copula
