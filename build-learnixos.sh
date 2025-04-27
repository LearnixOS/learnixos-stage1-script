#!/bin/bash

export GIT_ROOT=$PWD

export MAKEFLAGS="-j$(nproc) -l$(nproc)"
export CC=gcc
export CXX=g++
export CFLAGS="-march=x86_64 -mtune=generic -O3 -pipe"
export CXXFLAGS=$CFLAGS
export LXOS_ROOT=$PWD/lxos-root

echo "MAKEFLAGS=\"$MAKEFLAGS\""
echo "CC=$CC CXX=$CXX"
echo "CFLAGS=$CFLAGS"
echo "CXXFLAGS=$CXXFLAGS"
echo "LXOS_ROOT=\"$LXOS_ROOT\""

sleep 1

mkdir $LXOS_ROOT

mkdir -pv $LXOS_ROOT/{etc,var} $LXOS_ROOT/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  ln -sv usr/$i $LXOS_ROOT/$i
done

mkdir -pv $LXOS_ROOT/lib64
mkdir $LXOS_ROOT/tools

echo "Downloading all sources into $LXOS_ROOT/sources..."
wget --input-file=sources --continue --directory-prefix=$LXOS_ROOT/sources
git clone https://github.com/LearnixOS/slim-tools.git $LXOS_ROOT/sources/slim-tools
git clone https://github.com/LearnixOS/lxos-rc $LXOS_ROOT/sources/lxos-rc

echo "Building Cross Compiled tools"
$PWD/scripts/cross-toolchain.sh
