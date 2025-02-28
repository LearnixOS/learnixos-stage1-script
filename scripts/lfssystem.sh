#!/bin/sh

set -e

cd /sources 
tar -xvf man-pages-6.9.1.tar.xz
cd man-pages-6.9.1
rm -v man3/crypt*
make prefix=/usr install




cd /sources 
tar -xvf iana-etc-20241220.tar.gz
cd iana-etc-20241220
cp services protocols /etc




cd /sources 
tar -xvf glibc-2.40.tar.xz 
cd glibc-2.40
patch -Np1 -i ../glibc-2.40-fhs-1.patch
mkdir -v build
cd       build
echo "rootsbindir=/usr/sbin" > configparms
../configure --prefix=/usr                            \
             --disable-werror                         \
             --enable-kernel=5.4                      \
             --enable-stack-protector=strong          \
             --disable-nscd                           \
             libc_cv_slibdir=/usr/lib 
make 

touch /etc/ld.so.conf 
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile 
make install 
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd 
localedef -i C -f UTF-8 C.UTF-8
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f ISO-8859-1 en_GB
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_ES -f ISO-8859-15 es_ES@euro
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i is_IS -f ISO-8859-1 is_IS
localedef -i is_IS -f UTF-8 is_IS.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f ISO-8859-15 it_IT@euro
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i se_NO -f UTF-8 se_NO.UTF-8
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8 
localedef -i C -f UTF-8 C.UTF-8
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true 
cp /files/nsswitch.conf /etc/nsswitch.conf
tar -xf ../../tzdata2024b.tar.gz
ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}
for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done
cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO
ln -sfv /usr/share/zoneinfo/America/New_York /etc/localtime
cp /files/ld.so.conf /etc/ld.so.conf
mkdir -pv /etc/ld.so.conf.d 
rm -rf ./*
find .. -name "*.a" -delete
CC="gcc -m32" CXX="g++ -m32" \
../configure                             \
      --prefix=/usr                      \
      --host=i686-pc-linux-gnu           \
      --build=$(../scripts/config.guess) \
      --enable-kernel=5.4                 \
      --disable-nscd                     \
      --libdir=/usr/lib32                \
      --libexecdir=/usr/lib32            \
      libc_cv_slibdir=/usr/lib32

make
make DESTDIR=$PWD/DESTDIR install
cp -a DESTDIR/usr/lib32/* /usr/lib32/
install -vm644 DESTDIR/usr/include/gnu/{lib-names,stubs}-32.h \
               /usr/include/gnu/
echo "/usr/lib32" >> /etc/ld.so.conf




cd /sources 
tar -xvf zlib-1.3.1.tar.gz
cd zlib-1.3.1 
./configure --prefix=/usr 
make 
make install 
rm -fv /usr/lib/libz.a 
make distclean 
CFLAGS+=" -m32" CXXFLAGS+=" -m32" \
./configure --prefix=/usr \
    --libdir=/usr/lib32 
make 
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR 




cd /sources 
tar -xvf bzip2-1.0.8.tar.gz 
cd bzip2-1.0.8 
patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch 
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile 
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile 
make -f Makefile-libbz2_so
make clean 
make 
make PREFIX=/usr install 
cp -av libbz2.so.* /usr/lib
ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so 
cp -v bzip2-shared /usr/bin/bzip2
for i in /usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done 
rm -fv /usr/lib/libbz2.a 
make clean 
sed -e "s/^CC=.*/CC=gcc -m32/" -i Makefile{,-libbz2_so}
make -f Makefile-libbz2_so
make libbz2.a 
install -Dm755 libbz2.so.1.0.8 /usr/lib32/libbz2.so.1.0.8
ln -sf libbz2.so.1.0.8 /usr/lib32/libbz2.so
ln -sf libbz2.so.1.0.8 /usr/lib32/libbz2.so.1
ln -sf libbz2.so.1.0.8 /usr/lib32/libbz2.so.1.0
install -Dm644 libbz2.a /usr/lib32/libbz2.a 





cd /sources 
tar -xvf xz-5.6.3.tar.xz 
cd xz-5.6.3 
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.6.3 
make 
make install 
make distclean 
CC="gcc -m32" ./configure \
    --host=i686-pc-linux-gnu      \
    --prefix=/usr                 \
    --libdir=/usr/lib32           \
    --disable-static 
make 
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR 




cd /sources 
tar -xvf lz4-1.10.0.tar.gz 
cd lz4-1.10.0 
make BUILD_STATIC=no PREFIX=/usr 
make BUILD_STATIC=no PREFIX=/usr install 
make clean 
CC="gcc -m32" make BUILD_STATIC=no 
make BUILD_STATIC=no PREFIX=/usr LIBDIR=/usr/lib32 DESTDIR=$(pwd)/m32 install &&
cp -a m32/usr/lib32/* /usr/lib32/




cd /sources 
tar -xvf zstd-1.5.6.tar.gz
cd zstd-1.5.6
make prefix=/usr
make prefix=/usr install 
rm -v /usr/lib/libzstd.a 
make clean 
CC="gcc -m32" make prefix=/usr 
make prefix=/usr DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib/* /usr/lib32/
sed -e "/^libdir/s/lib$/lib32/" -i /usr/lib32/pkgconfig/libzstd.pc
rm -rf DESTDIR 


cd /sources 
tar -xvf file-5.46.tar.gz
cd file-5.46 
./configure --prefix=/usr
make 
make install 
make distclean 
CC="gcc -m32" ./configure \
    --prefix=/usr         \
    --libdir=/usr/lib32   \
    --host=i686-pc-linux-gnu 
make 
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR 


cd /sources
tar -xvf readline-8.2.13.tar.gz 
cd readline-8.2.13 
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install 
sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf 
./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.2.13 
make SHLIB_LIBS="-lncursesw" 
make install 
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.2.13 
make distclean 
CC="gcc -m32" ./configure \
    --host=i686-pc-linux-gnu      \
    --prefix=/usr                 \
    --libdir=/usr/lib32           \
    --disable-static              \
    --with-curses 
make SHLIB_LIBS="-lncursesw" 
make SHLIB_LIBS="-lncursesw" DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR 


cd /sources 
tar -xvf m4-1.4.19.tar.xz 
cd m4-1.4.19 
./configure --prefix=/usr 
make 
make install 

cd /sources 
tar -xvf bc-7.0.3.tar.xz 
cd bc-7.0.3
CC=gcc ./configure --prefix=/usr -G -O3 -r
make 
make install 

cd /sources 
tar -xvf flex-2.6.4.tar.gz 
cd flex-2.6.4

./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static 
make 
make install 
ln -sv flex   /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1 

cd /sources 
tar -xvf tcl8.6.15-src.tar.gz
cd tcl8.6.15
SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --disable-rpath 
make

sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.9|/usr/lib/tdbc1.1.9|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.9/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/tdbc1.1.9/library|/usr/lib/tcl8.6|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.9|/usr/include|"            \
    -i pkgs/tdbc1.1.9/tdbcConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/itcl4.3.0|/usr/lib/itcl4.3.0|" \
    -e "s|$SRCDIR/pkgs/itcl4.3.0/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.3.0|/usr/include|"            \
    -i pkgs/itcl4.3.0/itclConfig.sh

unset SRCDIR 
make install 
chmod -v u+w /usr/lib/libtcl8.6.so 
make install-private-headers 
ln -sfv tclsh8.6 /usr/bin/tclsh 
mv /usr/share/man/man3/{Thread,Tcl_Thread}.3 
cd ..
tar -xf ../tcl8.6.15-html.tar.gz --strip-components=1
mkdir -v -p /usr/share/doc/tcl-8.6.15
cp -v -r  ./html/* /usr/share/doc/tcl-8.6.15 

cd /sources 
tar -xvf expect5.45.4.tar.gz 
cd expect5.45.4
python3 -c 'from pty import spawn; spawn(["echo", "ok"])'
patch -Np1 -i ../expect-5.45.4-gcc14-1.patch 
./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --disable-rpath         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include 
make 
make install
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib 

cd /sources 
tar -xvf dejagnu-1.6.3.tar.gz 
cd dejagnu-1.6.3
mkdir -v build
cd       build 
../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi 
make install
install -v -dm755  /usr/share/doc/dejagnu-1.6.3
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3 


cd /sources 
tar -xvf pkgconf-2.3.0.tar.xz 
cd pkgconf-2.3.0
./configure --prefix=/usr              \
            --disable-static           \
            --docdir=/usr/share/doc/pkgconf-2.3.0 
make 
make install 
ln -sv pkgconf   /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1 

cd /sources 
rm -rf binutils-2.43.1
tar -xvf binutils-2.43.1.tar.xz 
cd binutils-2.43.1
patch -Np1 -i ../binutils-2.43.1-upstream_fix-1.patch 
mkdir -v build
cd       build 
../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib  \
             --enable-default-hash-style=gnu \
             --enable-multilib 
make tooldir=/usr 
make tooldir=/usr install 
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a 

cd /sources 
tar -xvf gmp-6.3.0.tar.xz 
cd gmp-6.3.0


./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0 
make
make html 
make install
make install-html 
make distclean 
cp -v configfsf.guess config.guess
cp -v configfsf.sub   config.sub 
ABI="32" \
CFLAGS="-m32 -O2 -pedantic -fomit-frame-pointer -mtune=generic -march=i686" \
CXXFLAGS="$CFLAGS" \
PKG_CONFIG_PATH="/usr/lib32/pkgconfig" \
./configure                      \
    --host=i686-pc-linux-gnu     \
    --prefix=/usr                \
    --disable-static             \
    --enable-cxx                 \
    --libdir=/usr/lib32          \
    --includedir=/usr/include/m32/gmp 
sed -i 's/$(exec_prefix)\/include/$\(includedir\)/' Makefile
make 
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
cp -Rv DESTDIR/usr/include/m32/* /usr/include/m32/
rm -rf DESTDIR 

cd /sources 
tar -xvf mpfr-4.2.1.tar.xz
cd mpfr-4.2.1


./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.1 


make
make html 
make install
make install-html 


cd /sources 
tar -xvf mpc-1.3.1.tar.gz
cd mpc-1.3.1
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1 
make
make html 
make install
make install-html 

cd /sources 
tar -xvf isl-0.27.tar.xz 
cd isl-0.27
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/isl-0.27 
make 
make install
install -vd /usr/share/doc/isl-0.27
install -m644 doc/{CodingStyle,manual.pdf,SubmittingPatches,user.pod} \
        /usr/share/doc/isl-0.27 
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/libisl*gdb.py /usr/share/gdb/auto-load/usr/lib 

cd /sources 
tar -xvf attr-2.5.2.tar.gz
cd attr-2.5.2
./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2
make 
make install 
make distclean 


CC="gcc -m32" ./configure \
    --prefix=/usr         \
    --disable-static      \
    --sysconfdir=/etc     \
    --libdir=/usr/lib32   \
    --host=i686-pc-linux-gnu 
make 
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR

cd /sources 
tar -xvf acl-2.3.2.tar.xz 
cd acl-2.3.2
./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/acl-2.3.2 
make 
make install 
make distclean 
CC="gcc -m32" ./configure \
    --prefix=/usr         \
    --disable-static      \
    --libdir=/usr/lib32   \
    --libexecdir=/usr/lib32   \
    --host=i686-pc-linux-gnu 
make 
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR 

cd /sources 
tar -xvf libcap-2.73.tar.xz
cd libcap-2.73
sed -i '/install -m.*STA/d' libcap/Makefile 
make prefix=/usr lib=lib 
make prefix=/usr lib=lib install 
make distclean 
make CC="gcc -m32 -march=i686" 
make CC="gcc -m32 -march=i686" lib=lib32 prefix=$PWD/DESTDIR/usr -C libcap install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
sed -e "s|^libdir=.*|libdir=/usr/lib32|" -i /usr/lib32/pkgconfig/lib{cap,psx}.pc
chmod -v 755 /usr/lib32/libcap.so.2.73
rm -rf DESTDIR 


cd /sources 
tar -xvf libxcrypt-4.4.37.tar.xz 
cd libxcrypt-4.4.37
./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens 
make 
make install 
make distclean 
CC="gcc -m32" \
./configure --prefix=/usr                \
            --host=i686-pc-linux-gnu     \
            --libdir=/usr/lib32          \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=glibc  \
            --disable-static             \
            --disable-failure-tokens 
make 
cp -av .libs/libcrypt.so* /usr/lib32/ &&
make install-pkgconfigDATA &&
ln -svf libxcrypt.pc /usr/lib32/pkgconfig/libcrypt.pc 

cd /sources 
tar -xvf shadow-4.17.1.tar.xz
cd shadow-4.17.1


sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs 
touch /usr/bin/passwd
./configure --sysconfdir=/etc   \
            --disable-static    \
            --with-{b,yes}crypt \
            --without-libbsd    \
            --with-group-name-max-length=32 
make 


make exec_prefix=/usr install
make -C man install-man 
pwconv 
grpconv 
mkdir -p /etc/default
useradd -D --gid 999 
sed -i '/MAIL/s/yes/no/' /etc/default/useradd 
passwd root

cd /sources 
rm -rf gcc-14.2.0
tar -xvf gcc-14.2.0.tar.xz
cd gcc-14.2.0
sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64 
sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' \
      -i gcc/config/i386/i386.h 
mkdir -v build
cd       build 
mlist=m64,m32
../configure --prefix=/usr               \
             LD=ld                       \
             --enable-languages=c,c++    \
             --enable-default-pie        \
             --enable-default-ssp        \
             --enable-host-pie           \
             --enable-multilib           \
             --with-multilib-list=$mlist \
             --disable-bootstrap         \
             --disable-fixincludes       \
             --with-system-zlib 
make 
make install 
chown -v -R root:root \
    /usr/lib/gcc/$(gcc -dumpmachine)/14.2.0/include{,-fixed} 
ln -svr /usr/bin/cpp /usr/lib 
ln -sv gcc.1 /usr/share/man/man1/cc.1 
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/14.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/ 

cd /sources 
rm -rf acl-2.3.2/ attr-2.5.2/ bash-5.2.37/ expect5.45.4/      gzip-1.13/          mpc-1.3.1/        tar-1.35/ attr-2.5.2/       file-5.46/         iana-etc-20241220/  mpfr-4.2.1/       tcl8.6.15/ bash-5.2.37/      findutils-4.10.0/  isl-0.27/           ncurses-6.5/      texinfo-7.2/ bc-7.0.3/         flex-2.6.4/        libcap-2.73/        patch-2.7.6/      util-linux-2.40.2/ binutils-2.43.1/  gawk-5.3.1/        libxcrypt-4.4.37/   perl-5.40.0/      xz-5.6.3/ bison-3.8.2/      gcc-14.2.0/        linux-6.12.7/       pkgconf-2.3.0/    zlib-1.3.1/ bzip2-1.0.8/      gettext-0.23/      lz4-1.10.0/         Python-3.13.1/    zstd-1.5.6/ coreutils-9.5/    glibc-2.40/        m4-1.4.19/          readline-8.2.13/ dejagnu-1.6.3/    gmp-6.3.0/         make-4.4.1/         sed-4.9/ diffutils-3.10/   grep-3.11/         man-pages-6.9.1/    shadow-4.17.1/

cd /sources 
tar -xvf ncurses-6.5.tar.gz 
cd ncurses-6.5
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig 
make 
make DESTDIR=$PWD/dest install
install -vm755 dest/usr/lib/libncursesw.so.6.5 /usr/lib
rm -v  dest/usr/lib/libncursesw.so.6.5
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i dest/usr/include/curses.h
cp -av dest/* /    
for lib in ncurses form panel menu ; do
    ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
done 
ln -sfv libncursesw.so /usr/lib/libcurses.so 
cp -v -R doc -T /usr/share/doc/ncurses-6.5 
make distclean 
CC="gcc -m32" CXX="g++ -m32" \
./configure --prefix=/usr           \
            --host=i686-pc-linux-gnu \
            --libdir=/usr/lib32     \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib32/pkgconfig 
make 
make DESTDIR=$PWD/DESTDIR install
mkdir -p DESTDIR/usr/lib32/pkgconfig
for lib in ncurses form panel menu ; do
    rm -vf                    DESTDIR/usr/lib32/lib${lib}.so
    echo "INPUT(-l${lib}w)" > DESTDIR/usr/lib32/lib${lib}.so
    ln -svf ${lib}w.pc        DESTDIR/usr/lib32/pkgconfig/$lib.pc
done
rm -vf                     DESTDIR/usr/lib32/libcursesw.so
echo "INPUT(-lncursesw)" > DESTDIR/usr/lib32/libcursesw.so
ln -sfv libncurses.so      DESTDIR/usr/lib32/libcurses.so
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR 

cd /sources 
tar -xvf sed-4.9.tar.xz
cd sed-4.9
./configure --prefix=/usr 
make
make html 
make install
install -d -m755           /usr/share/doc/sed-4.9
install -m644 doc/sed.html /usr/share/doc/sed-4.9

cd /sources
tar -xvf psmisc-23.7.tar.xz 
cd psmisc-23.7
./configure --prefix=/usr 
make 
make install 

cd /sources 
tar -xvf gettext-0.23.tar.xz
cd gettext-0.23
sed -e '/^structured/s/xmlError \*/typeof(xmlCtxtGetLastError(NULL)) /' \
    -i gettext-tools/src/its.c
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.23 
make 
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so 

cd /sources 
tar -xvf bison-3.8.2.tar.xz
cd bison-3.8.2 
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2 
make 
make install

cd /sources 
tar -xvf grep-3.11.tar.xz
cd grep-3.11
sed -i "s/echo/#echo/" src/egrep.sh 
./configure --prefix=/usr 
make 
make install 

cd /sources 
tar -xvf bash-5.2.37.tar.gz
cd bash-5.2.37
./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.2.37 
make 
make install 
echo "run /finishlfssystem.sh"
exec /usr/bin/bash 

