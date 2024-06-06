#!/bin/sh

# https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# pyinstallcheck_Bonmin_std (SEGFAULT)
#if test `uname` = "Darwin"; then
#  CMAKE_ARGS="${CMAKE_ARGS} -DUSE_BONMIN=OFF"
#fi

if test `uname` = "Darwin"; then
  CFLAGS="${CFLAGS} -march=nocona -mtune=generic -mno-ssse3 -O1"
  CXXFLAGS="${CXXFLAGS} -march=nocona -mtune=generic -mno-ssse3 -O1"
fi

git clone -b releases/2.11.11 https://github.com/coin-or/CoinUtils.git
cd CoinUtils
CXXFLAGS="${CXXFLAGS} -g" ./configure --prefix=${PREFIX} --enable-gnu-packages
make -j${CPU_COUNT}
make install
cd -

git clone -b releases/0.108.10 https://github.com/coin-or/Osi.git
cd Osi
CXXFLAGS="${CXXFLAGS} -g" ./configure --prefix=${PREFIX}
make -j${CPU_COUNT}
make install
cd -

git clone -b releases/1.17.8 https://github.com/coin-or/Clp.git
cd Clp
CXXFLAGS="${CXXFLAGS} -g" ./configure --prefix=${PREFIX}
make -j${CPU_COUNT}
make install
cd -

git clone -b releases/0.60.7 https://github.com/coin-or/Cgl.git
cd Cgl
CXXFLAGS="${CXXFLAGS} -g" ./configure --prefix=${PREFIX} --enable-gnu-packages
make -j${CPU_COUNT}
make install
cd -

git clone -b releases/2.10.11 https://github.com/coin-or/Cbc.git
cd Cbc
CXXFLAGS="${CXXFLAGS} -g" ./configure --prefix=${PREFIX} --enable-cbc-parallel --enable-gnu-packages
make -j${CPU_COUNT}
make install
cd -

git clone -b releases/3.14.16 https://github.com/coin-or/Ipopt.git
cd Ipopt
CXXFLAGS="${CXXFLAGS} -g" ./configure \
  --without-hsl \
  --disable-java \
  --with-mumps \
  --with-mumps-cflags="-I${PREFIX}/include/mumps_seq" \
  --with-mumps-lflags="-ldmumps_seq -lmumps_common_seq -lpord_seq -lmpiseq_seq -lesmumps -lscotch -lscotcherr -lmetis -lgfortran" \
  --with-asl \
  --with-asl-cflags="-I${PREFIX}/include/asl" \
  --with-asl-lflags="-lasl" \
  --prefix=${PREFIX}
make -j${CPU_COUNT}
make install
cd -

git clone -b releases/1.8.9 https://github.com/coin-or/Bonmin.git
cd Bonmin
CXXFLAGS="${CXXFLAGS} -g" LIBS="-lCoinUtils -lOsi -lCgl" ./configure --prefix=${PREFIX} \
  --with-coinutils-lib="$(pkg-config --libs coinutils)" \
  --with-coinutils-incdir="${PREFIX}/include/coin/" \
  --with-osi-lib="$(pkg-config --libs osi)" \
  --with-osi-incdir="${PREFIX}/include/coin/" \
  --with-clp-lib="$(pkg-config --libs clp)" \
  --with-clp-incdir="${PREFIX}/include/coin/" \
  --with-cgl-lib="$(pkg-config --libs cgl)" \
  --with-cgl-incdir="${PREFIX}/include/coin/" \
  --with-cbc-lib="$(pkg-config --libs cbc)" \
  --with-cbc-incdir="${PREFIX}/include/coin/" \
  --with-ipopt-lib="$(pkg-config --libs ipopt)" \
  --with-ipopt-incdir="${PREFIX}/include/coin/" \
  --with-asl-incdir="${PREFIX}/include/asl" \
  --with-asl-lib="$(pkg-config --libs ipoptamplinterface) -lasl"

make -j${CPU_COUNT}
make install
cd -

cmake ${CMAKE_ARGS} -LAH -G "Ninja" \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_FIND_FRAMEWORK=NEVER \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DPython_FIND_STRATEGY=LOCATION \
  -DPython_ROOT_DIR=${PREFIX} \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  -DSWIG_COMPILE_FLAGS="-O1" \
  -D_HAVE_FR_LOC_RUNS=0 \
  -DBUILD_PYTHON=OFF \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -B build .
cmake --build build --target t_Bonmin_std
cd build

if test `uname` = "Darwin"; then
  lldb ./lib/test/t_Bonmin_std -o 'run' -k 'disas' -o 'quit'
  lldb ./lib/test/t_Bonmin_std -o 'run' -k 'thread backtrace all' -o 'quit'
else
  echo -e "run\nbt\n" > test.gdb
  cat test.gdb
  gdb --batch --command=test.gdb ./lib/test/t_Bonmin_std
fi


exit 1

rm -r ${PREFIX}/share/gdb

if test "$CONDA_BUILD_CROSS_COMPILATION" != "1"
then
  ctest --test-dir build -R pyinstallcheck --output-on-failure --schedule-random -j${CPU_COUNT} -E "GeneralizedParetoFactory_std|KrigingAlgorithm_std|ChaosSobol"
fi
