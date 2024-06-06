#!/bin/sh

# https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# pyinstallcheck_Bonmin_std (SEGFAULT)
#if test `uname` = "Darwin"; then
#  CMAKE_ARGS="${CMAKE_ARGS} -DUSE_BONMIN=OFF"
#fi

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
echo -e "run\nbt\n" > test.gdb
cat test.gdb
gdb --batch --command=test.gdb ./lib/test/t_Bonmin_std
exit 1

rm -r ${PREFIX}/share/gdb

if test "$CONDA_BUILD_CROSS_COMPILATION" != "1"
then
  ctest --test-dir build -R pyinstallcheck --output-on-failure --schedule-random -j${CPU_COUNT} -E "GeneralizedParetoFactory_std|KrigingAlgorithm_std|ChaosSobol"
fi
