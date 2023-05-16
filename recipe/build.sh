#!/bin/sh

mkdir build && cd build

cmake ${CMAKE_ARGS} -LAH \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  -DSWIG_COMPILE_FLAGS="-O1" \
  -D_NLOPT_STOGO_RUNS=1 -D_NLOPT_AGS_RUNS=1 -D_HAVE_FR_LOC_RUNS=0 \
  ..
make install -j${CPU_COUNT}
rm -r ${PREFIX}/share/gdb
if test "$CONDA_BUILD_CROSS_COMPILATION" != "1"
then
  ctest -R pyinstallcheck --output-on-failure --schedule-random -j${CPU_COUNT} -E "GeneralizedParetoFactory_std|KrigingAlgorithm_std|ChaosSobol"
fi
