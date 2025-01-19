#!/bin/sh 
set -e
cd $LFS/sources
tar -xf binutils-2.43.1.tar.xz
cd binutils-2.43.1
mkdir -v build
cd build
../configure --prefix=$LFS/tools       \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-default-hash-style=gnu \
             --enable-multilib
make 
make install

cd $LFS/sources
tar -xvf gcc-14.2.0.tar.xz
cd gcc-14.2.0
tar -xf ../mpfr-4.2.1.tar.xz
mv -v mpfr-4.2.1 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc 
sed -e '/m64=/s/lib64/lib/' -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/'  -i.orig gcc/config/i386/t-linux64

sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' -i gcc/config/i386/i386.h 

mkdir -v build
cd       build

mlist=m64.m32 
../configure                  \
    --target=$LFS_TGT                              \
    --prefix=$LFS/tools                            \
    --with-glibc-version=2.40                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --enable-default-pie                           \
    --enable-default-ssp                           \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-shared                               \
    --enable-multilib --with-multilib-list=$mlist  \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++

make
make install

cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h 

cd ..


cd $LFS/sources
tar -xvf linux-6.12.7.tar.xz
cd linux-6.12.7 
make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr


cd $LFS/sources
tar -xvf glibc-2.40.tar.xz
cd glibc-2.40
ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3

patch -Np1 -i ../glibc-2.40-fhs-1.patch 
mkdir -v build
cd       build
echo "rootsbindir=/usr/sbin" > configparms
../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=5.4                \
      --with-headers=$LFS/usr/include    \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib

make
make DESTDIR=$LFS install
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

cd $LFS/sources/glibc-2.40/build

make clean
find .. -name "*.a" -delete 
CC="$LFS_TGT-gcc -m32" CXX="$LFS_TGT-g++ -m32" ../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT32                  \
      --build=$(../scripts/config.guess) \
      --enable-kernel=5.4                 \
      --with-headers=$LFS/usr/include    \
      --disable-nscd                     \
      --libdir=/usr/lib32                \
      --libexecdir=/usr/lib32            \
      libc_cv_slibdir=/usr/lib32
make 
make DESTDIR=$PWD/DESTDIR install
cp -a DESTDIR/usr/lib32 $LFS/usr/
install -vm644 DESTDIR/usr/include/gnu/lib-names-32.h $LFS/usr/include/gnu/
install -vm644 DESTDIR/usr/include/gnu/stubs-32.h $LFS/usr/include/gnu/
ln -svf ../lib32/ld-linux.so.2 $LFS/lib/ld-linux.so.2


cd $LFS/sources
rm -rf gcc-14.2.0 
tar -xvf gcc-14.2.0.tar.xz 
cd gcc-14.2.0 
mkdir -v build
cd       build
../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --enable-multilib               \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/14.2.0 
make 
make DESTDIR=$LFS install 
rm -v $LFS/usr/lib/libstdc++exp.la 
rm -v $LFS/usr/lib/libstdc++fs.la
rm -v $LFS/usr/lib/libsupc++.la


cd $LFS/sources
tar -xvf m4-1.4.19.tar.xz 
cd m4-1.4.19 
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess) 
make 
make DESTDIR=$LFS install 



cd $LFS/sources
tar -xvf ncurses-6.5.tar.gz 
cd ncurses-6.5 
mkdir build
cd build
  ../configure AWK=gawk
  make -C include
  make -C progs tic
cd ..
./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            AWK=gawk 
make
cd $LFS/sources/ncurses-6.5
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i $LFS/usr/include/curses.h 
make distclean 
CC="$LFS_TGT-gcc -m32"              \
CXX="$LFS_TGT-g++ -m32"             \
./configure --prefix=/usr           \
            --host=$LFS_TGT32       \
            --build=$(./config.guess)    \
            --libdir=/usr/lib32     \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-normal        \
            --with-cxx-shared       \
            --without-debug         \
            --without-ada           \
            --disable-stripping 
make 
make DESTDIR=$PWD/DESTDIR TIC_PATH=$(pwd)/build/progs/tic install
ln -sv libncursesw.so DESTDIR/usr/lib32/libncurses.so
cp -Rv DESTDIR/usr/lib32/* $LFS/usr/lib32
rm -rf DESTDIR 

cd $LFS/sources
tar -xvf bash-5.2.37.tar.gz 
cd bash-5.2.37 
./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc 
make 
make DESTDIR=$LFS install 
ln -sv bash $LFS/bin/sh 


cd $LFS/sources
tar -xvf coreutils-9.5.tar.xz 
cd coreutils-9.5 
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime 
make 
make DESTDIR=$LFS install 
mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8 

cd $LFS/sources
tar -xvf diffutils-3.10.tar.xz 
cd diffutils-3.10 
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess) 
make 
make DESTDIR=$LFS install 

cd $LFS/sources
tar -xvf file-5.46.tar.gz 
cd file-5.46 
mkdir build
pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make
popd 
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess) 
make FILE_COMPILE=$(pwd)/build/src/file 
make DESTDIR=$LFS install 
rm -v $LFS/usr/lib/libmagic.la 


cd $LFS/sources
tar -xvf findutils-4.10.0.tar.xz 
cd findutils-4.10.0
./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)
make 
make DESTDIR=$LFS install


cd $LFS/sources
tar -xvf gawk-5.3.1.tar.xz 
cd gawk-5.3.1 
sed -i 's/extras//' Makefile.in 
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess) 
make 
make DESTDIR=$LFS install 

cd $LFS/sources
tar -xvf grep-3.11.tar.xz 
cd grep-3.11 
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess) 
make 
make DESTDIR=$LFS install 

cd $LFS/sources
tar -xvf gzip-1.13.tar.xz 
cd gzip-1.13 
./configure --prefix=/usr --host=$LFS_TGT 
make 
make DESTDIR=$LFS install 

cd $LFS/sources
tar -xvf make-4.4.1.tar.gz 
cd make-4.4.1 


./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess) 
make 
make DESTDIR=$LFS install 

cd $LFS/sources
tar -xvf patch-2.7.6.tar.xz 
cd patch-2.7.6
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess) 
make 
make DESTDIR=$LFS install 


cd $LFS/sources
tar -xvf sed-4.9.tar.xz 
cd sed-4.9 
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess) 
make 
make DESTDIR=$LFS install 

cd $LFS/sources
tar -xvf tar-1.35.tar.xz 
cd tar-1.35 
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) 
make 
make DESTDIR=$LFS install 


cd $LFS/sources
tar -xvf xz-5.6.3.tar.xz
cd xz-5.6.3 


./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.6.3
make 
make DESTDIR=$LFS install 
rm -v $LFS/usr/lib/liblzma.la 


cd $LFS/sources
rm -rf binutils-2.43.1 
tar -xvf binutils-2.43.1.tar.xz 
cd binutils-2.43.1 
sed '6009s/$add_dir//' -i ltmain.sh 
mkdir -v build
cd       build 
../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no        \
    --disable-werror           \
    --enable-64-bit-bfd        \
    --enable-default-hash-style=gnu \
    --enable-multilib 
make 
make DESTDIR=$LFS install 
rm -v $LFS/usr/lib/libbfd.a
rm -v $LFS/usr/lib/libbfd.la
rm -v $LFS/usr/lib/libctf.a
rm -v $LFS/usr/lib/libctf.la
rm -v $LFS/usr/lib/libctf-nobfd.a
rm -v $LFS/usr/lib/libctf-nobfd.la
rm -v $LFS/usr/lib/libopcodes.a
rm -v $LFS/usr/lib/libopcodes.la
rm -v $LFS/usr/lib/libsframe.a
rm -v $LFS/usr/lib/libsframe.la 


cd $LFS/sources
rm -rf gcc-14.2.0 
tar -xvf gcc-14.2.0.tar.xz 
cd gcc-14.2.0 
tar -xf ../mpfr-4.2.1.tar.xz
mv -v mpfr-4.2.1 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc 
sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64 
sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' \
      -i gcc/config/i386/i386.h 
sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in 
mkdir -v build
cd       build 
mlist=m64,m32 
../configure                                       \
    --build=$(../config.guess)                     \
    --host=$LFS_TGT                                \
    --target=$LFS_TGT                              \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc      \
    --prefix=/usr                                  \
    --with-build-sysroot=$LFS                      \
    --enable-default-pie                           \
    --enable-default-ssp                           \
    --disable-nls                                  \
    --enable-multilib --with-multilib-list=$mlist  \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libsanitizer                         \
    --disable-libssp                               \
    --disable-libvtv                               \
    --enable-languages=c,c++ 

make 
make DESTDIR=$LFS install 
ln -sv gcc $LFS/usr/bin/cc 
echo "exit and"
echo "run chroot.sh"
exit 
