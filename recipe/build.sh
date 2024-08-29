#!/bin/sh

CFLAGS="${CFLAGS} -g -O1"
CXXFLAGS="${CXXFLAGS} -g -O1"

curl -L https://github.com/coin-or/Osi/archive/releases/0.108.11.tar.gz | tar xz
cd Osi-releases-0.108.11/
curl -L https://raw.githubusercontent.com/conda-forge/coin-or-osi-feedstock/main/recipe/0001-Patch-for-downstream.patch | patch -p1
./configure --prefix="${PREFIX}" --exec-prefix="${PREFIX}"
make -j "${CPU_COUNT}"
make install
cd ..

curl -L https://github.com/coin-or/Cbc/archive/releases/2.10.12.tar.gz | tar xz
cd Cbc-releases-2.10.12/
mkdir Data
git clone --depth 1 https://github.com/coin-or-tools/Data-Sample.git Data/Sample
patch -p1 -i ${RECIPE_DIR}/cbc_debug.patch
curl -L https://raw.githubusercontent.com/conda-forge/coin-or-cbc-feedstock/main/recipe/patches/0001-Patch-for-downstream.patch | patch -p1
./configure --prefix="${PREFIX}" --exec-prefix="${PREFIX}" --disable-cbc-parallel --enable-gnu-packages
make -j "${CPU_COUNT}"
make install
# make test || "cbc test :["
cd ..

curl -L https://github.com/coin-or/Bonmin/archive/refs/tags/releases/1.8.9.tar.gz | tar xz
cd Bonmin-releases-1.8.9/
mkdir Data
git clone --depth 1 https://github.com/coin-or-tools/Data-Sample.git Data/Sample
patch -p1 -i ${RECIPE_DIR}/bonmini_debug.patch
LIBS="-lCoinUtils -lOsi -lCgl" ./configure --prefix="${PREFIX}" \
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
make -j ${CPU_COUNT}
make install
cd Bonmin/test
make
./CppExample
cd ../..
# make test || "bonmin test :["
cd ..

# https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

cmake ${CMAKE_ARGS} -LAH -G "Ninja" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_FIND_FRAMEWORK=NEVER \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DPython_FIND_STRATEGY=LOCATION \
  -DPython_ROOT_DIR=${PREFIX} \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  -DSWIG_COMPILE_FLAGS="-O1" \
  -D_HAVE_FR_LOC_RUNS=0 \
  -DUSE_CERES=OFF -DUSE_PAGMO=OFF -DUSE_CMINPACK=OFF -DUSE_NLOPT=OFF -DUSE_HDF5=OFF -DUSE_DLIB=OFF -DUSE_NANOFLANN=OFF -DUSE_CUBA=OFF -DUSE_PRIMESIEVE=OFF -DUSE_SPECTRA=OFF -DUSE_TBB=OFF \
  -B build .
cmake --build build --target t_Bonmin_std --parallel ${CPU_COUNT}

if test "$CONDA_BUILD_CROSS_COMPILATION" != "1"
then
  ctest --test-dir build -R cppcheck_Bonmin_std --output-on-failure -V || echo "nope"
#   ./build/lib/test/t_Bonmin_std || echo "nope"
  if test `uname` = "Darwin"; then
#     echo -e "run\n\bt" > test.gdb
#     gdb --batch --command=test.gdb ./build/lib/test/t_Bonmin_std

    # https://stackoverflow.com/questions/26812047/scripting-lldb-to-obtain-a-stack-trace-after-a-crash
    lldb ./build/lib/test/t_Bonmin_std --batch --one-line 'process launch' --one-line-on-crash 'bt' --one-line-on-crash 'quit'
  fi
  
fi


exit 1
