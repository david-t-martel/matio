#!/bin/bash

set -ex

if [[ "${USE_CMAKE:-no}" == "no" ]]; then
    ./autogen.sh
    if [[ "$HDF5_VERSION" == "foo" ]]; then
        ./configure --enable-shared --enable-debug --enable-mat73=$ENABLE_MAT73 --enable-extended-sparse=$ENABLE_EXTENDED_SPARSE --with-zlib=$WITH_ZLIB --with-pic; CC=foo
        cat ./src/matioConfig.h
    fi
    WITH_HDF5="$TRAVIS_BUILD_DIR/hdf5-$HDF5_VERSION.$HDF5_PATCH_VERSION${HDF5_BUILD_VERSION:+-$HDF5_BUILD_VERSION}/hdf5"
    if [[ "$CC" == "gcc-4.8" ]]; then
        ./configure --enable-shared --enable-coverage --enable-debug --enable-mat73=$ENABLE_MAT73 --enable-extended-sparse=$ENABLE_EXTENDED_SPARSE --with-zlib=$WITH_ZLIB --with-pic --with-hdf5=$WITH_HDF5
        cat ./src/matioConfig.h
    elif [[ "$CC" == "clang" ]]; then
        ./configure --enable-shared --enable-debug --enable-mat73=$ENABLE_MAT73 --enable-extended-sparse=$ENABLE_EXTENDED_SPARSE --with-zlib=$WITH_ZLIB --with-pic --with-hdf5=$WITH_HDF5
        cat ./src/matioConfig.h
    fi
    if [[ "$HDF5_VERSION" == "foo" ]]; then
        CC=$(which clang)
    fi
fi
if [[ "${USE_CMAKE:-no}" == "yes" ]]; then
    if [[ "$TRAVIS_OS_NAME" == "linux" ]] && [[ "${USE_CONAN:-no}" == "no" ]]; then
        HDF5_DIR=$HOME/CMake-hdf5-$HDF5_VERSION.$HDF5_PATCH_VERSION/HDF5-$HDF5_VERSION.$HDF5_PATCH_VERSION-Linux/HDF_Group/HDF5/$HDF5_VERSION.$HDF5_PATCH_VERSION
        CMAKE_PREFIX_PATH=-DCMAKE_PREFIX_PATH=$HDF5_DIR/cmake
    fi

    if [[ "${USE_CONAN:-no}" == "yes" ]]; then
        CMAKE_CONAN_ARG=-DMATIO_USE_CONAN=TRUE
    fi

    SRC_DIR=$TRAVIS_BUILD_DIR
    BUILD_DIR=$HOME/matio_cmake
    mkdir -p $BUILD_DIR
    pushd $BUILD_DIR

    cmake $SRC_DIR -DCMAKE_BUILD_TYPE=Debug \
                   $CMAKE_PREFIX_PATH \
                   -DMATIO_EXTENDED_SPARSE=$ENABLE_EXTENDED_SPARSE \
                   -DMATIO_MAT73=$ENABLE_MAT73 \
                   -DMATIO_WITH_HDF5=$ENABLE_MAT73 \
                   -DMATIO_WITH_ZLIB=$WITH_ZLIB \
                   -DMATIO_SHARED=TRUE \
                   $CMAKE_CONAN_ARG
    popd
fi
