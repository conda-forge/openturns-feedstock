#!/bin/sh

mkdir build && cd build

if test `uname` = "Darwin"
then
  # tbb/detail/_task.h:216:13: error: aligned deallocation function of type 'void (void *, std::align_val_t) noexcept'
  # is only available on macOS 10.14 or newer
  export CXXFLAGS="${CXXFLAGS} -fno-aligned-allocation"
fi

cmake ${CMAKE_ARGS} -LAH \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  -DSWIG_COMPILE_FLAGS="-O1" \
  -DUSE_R=OFF \
  -D_NLOPT_STOGO_RUNS=1 -D_NLOPT_AGS_RUNS=1 -D_HAVE_FR_LOC_RUNS=0 -D_HAVE_STD_REGEX_RUNS=1 \
  ..
make install -j${CPU_COUNT}
rm -r ${PREFIX}/share/gdb
if test "$CONDA_BUILD_CROSS_COMPILATION" != "1"
then
  ctest -R pyinstallcheck --output-on-failure --schedule-random -j${CPU_COUNT} -E "GeneralizedParetoFactory_std|KrigingAlgorithm_std|ChaosSobol"
fi
