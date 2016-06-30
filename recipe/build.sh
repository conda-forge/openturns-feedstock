#!/bin/sh

if test `uname` = "Darwin"
then
  SO_EXT='.dylib'
else
  SO_EXT='.so'
  export CXXFLAGS="${CXXFLAGS} -DBOOST_MATH_DISABLE_FLOAT128"
fi

mkdir -p build && cd build

cmake \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DLAPACKE_FOUND=TRUE -DOPENTURNS_LIBRARIES="$PREFIX/lib/libopenblas${SO_EXT}" \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
  -DUSE_COTIRE=ON -DCOTIRE_TESTS=OFF -DCOTIRE_MAXIMUM_NUMBER_OF_UNITY_INCLUDES="-j${CPU_COUNT}" \
  ..

make python_unity -j${CPU_COUNT}
make install/fast
DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib ctest -R pyinstallcheck --output-on-failure -j${CPU_COUNT}
