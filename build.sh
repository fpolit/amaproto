#!/bin/bash
#
# Simple bash script to build ama protobuf files


CLEAN=1
GFILES=(build)  # generated files and directories
BUILD_DIR=build

if [[ $CLEAN -eq 1 ]]; then
    rm -rf ${GFILES[@]}
fi


mkdir -p $BUILD_DIR
cmake -S . -B $BUILD_DIR -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_COMPILER_WALL=ON \
      -DCMAKE_BUILD_AMADB_PY_PROTO=ON \
      -DCMAKE_BUILD_AMADB_CXX_PROTO=ON \
      -DCMAKE_BUILD_AMACONTROLLER_PY_PROTO=ON \
      -DCMAKE_BUILD_AMACONTROLLER_CXX_PROTO=ON \
      -DCMAKE_BUILD_AMAPROCESSOR_PROTO=ON \
      --log-level=DEBUG || exit 1


make -C $BUILD_DIR
