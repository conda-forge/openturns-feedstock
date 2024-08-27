#!/bin/sh

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
  -B build .
cmake --build build --target t_Bonmin_std --parallel ${CPU_COUNT}

if test "$CONDA_BUILD_CROSS_COMPILATION" != "1"
then
  ctest --test-dir build -R cppcheck_Bonmin_std --output-on-failure -V || echo "nope"
  
  if test `uname` = "Darwin"; then
#     echo -e "run\n\bt" > test.gdb
#     gdb --batch --command=test.gdb ./build/lib/test/t_Bonmin_std

    # https://stackoverflow.com/questions/26812047/scripting-lldb-to-obtain-a-stack-trace-after-a-crash
    lldb ./build/lib/test/t_Bonmin_std --batch --one-line 'process launch' --one-line-on-crash 'bt' --one-line-on-crash 'quit'
  fi
  
fi



