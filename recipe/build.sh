#!/bin/sh

if test `uname` = "Darwin"
then
  SHLIB_EXT='.dylib'
else
  SHLIB_EXT='.so'
fi

mkdir -p build && cd build

cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DLAPACKE_FOUND=TRUE -DOPENTURNS_LIBRARIES="$PREFIX/lib/libopenblas${SHLIB_EXT}" \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
  -DUSE_COTIRE=ON -DCOTIRE_TESTS=OFF -DCOTIRE_MAXIMUM_NUMBER_OF_UNITY_INCLUDES="-j${CPU_COUNT}" \
  ..

make python_unity -j${CPU_COUNT}
make install/fast
DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib ctest -R pyinstallcheck --output-on-failure -j${CPU_COUNT}
