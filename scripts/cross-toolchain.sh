#!/bin/bash

GLIBC_VER=2.41
GCC_VER=14.2.0
LINUX=6.13.4

cd $LXOS_ROOT/sources/

#
# GLIBC
#
echo "[PASS 1] Extracting glibc-$GLIBC_VER..."
tar -xf glibc-$GLIBC_VER.tar.xz

cd glibc-$GLIBC_VER

mkdir -v build
cd       build

../configure --prefix=$LXOS_ROOT/tools \
             --with-sysroot=$LXOS_ROOT \
             --target=x86_64-lfs-linux-gnu   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-new-dtags  \
             --enable-default-hash-style=gnu

make && make install

cd $LXOS_ROOT/sources
rm -rf glibc-$GLIBC_VER

#
# GCC
#
echo "[PASS 1] Extracting gcc-$GCC_VER..."
tar xf gcc-$GCC_VER.tar.xz

cd gcc-$GCC_VER

echo "Extracting mpfr, gmp, and mpc..."
tar -xf ../mpfr-4.2.1.tar.xz
mv -v mpfr-4.2.1 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc

sed -e '/m64=/s/lib64/lib/' \
    -i.orig gcc/config/i386/t-linux64

mkdir -v build
cd       build

../configure                  \
    --target=x86_64-lfs-linux-gnu \
    --prefix=$LXOS_ROOT/tools \
    --with-glibc-version=2.41 \
    --with-sysroot=$LXOS_ROOT \
    --with-newlib             \
    --without-headers         \
    --enable-default-pie      \
    --enable-default-ssp      \
    --disable-nls             \
    --disable-shared          \
    --disable-multilib        \
    --disable-threads         \
    --disable-libatomic       \
    --disable-libgomp         \
    --disable-libquadmath     \
    --disable-libssp          \
    --disable-libvtv          \
    --disable-libstdcxx       \
    --enable-languages=c,c++

make && make install

cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $(x86_64-lfs-linux-gnu-gcc -print-libgcc-file-name)`/include/limits.h

cd $LXOS_ROOT/sources
rm -rf gcc-$GCC_VER

#
# LINUX HEADERS
#
echo "Extracting linux-$LINUX_VER..."
tar -xf linux-$LINUX_VER.tar.xz

cd linux-$LINUX_VER

make mrproper

make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LXOS_ROOT/usr

cd $LXOS_ROOT/sources
rm -rf linux-$LINUX_VER

#
# GLIBC [PASS 2]
#
echo "[PASS 2] Extracting glibc-$GLIBC_VER..."
tar -xf glibc-$GLIBC_VER.tar.xz

cd glibc-$GLIBC_VER

ln -sfv ../lib/ld-linux-x86-64.so.2 $LXOS_ROOT/lib64
ln -sfv ../lib/ld-linux-x86-64.so.2 $LXOS_ROOT/lib64/ld-lsb-x86-64.so.3

patch -Np1 -i ../glibc-2.41-fhs-1.patch

mkdir -v build
cd       build

echo "rootsbindir=/usr/sbin" > configparms

../configure                             \
      --prefix=/usr                      \
      --host=x86_64-lfs-linux-gnu        \
      --build=$(../scripts/config.guess) \
      --enable-kernel=5.4                \
      --with-headers=$LXOS_ROOT/usr/include    \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib

make && make DESTDIR=$LXOS_ROOT install

sed '/RTLDLIST=/s@/usr@@g' -i $LXOS_ROOT/usr/bin/lddsed '/RTLDLIST=/s@/usr@@g' -i $LXOS_ROOT/usr/bin/ldd

cd  $LXOS_ROOT/sources
rm -rf glibc-$GLIBC_VER

#
# LIBSTDC++ from GCC
#
echo "Extracting gcc-$GCC_VER for libstdc++..."
tar -xf gcc-$GCC_VER.tar.xz

cd gcc-$GCC_VER

mkdir -v build
cd       build

../libstdc++-v3/configure           \
    --host=x86_64-lfs-linux-gnu     \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/x86_64-lfs-linux-gnu/include/c++/$GCC_VER

make && make DESTDIR=$LXOS_ROOT install

rm -v $LXOS_ROOT/usr/lib/lib{stdc++{,exp,fs},supc++}.la
