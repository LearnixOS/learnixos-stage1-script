#!/bin/sh

cd /sources 
tar -xvf gettext-0.23.tar.xz
cd gettext-0.23 
./configure --disable-shared
make
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin


cd /sources 
tar -xvf bison-3.8.2.tar.xz
cd bison-3.8.2
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
make
make install

cd /sources 
tar -xvf perl-5.40.0.tar.xz
cd perl-5.40.0
sh Configure -des                                         \
             -D prefix=/usr                               \
             -D vendorprefix=/usr                         \
             -D useshrplib                                \
             -D privlib=/usr/lib/perl5/5.40/core_perl     \
             -D archlib=/usr/lib/perl5/5.40/core_perl     \
             -D sitelib=/usr/lib/perl5/5.40/site_perl     \
             -D sitearch=/usr/lib/perl5/5.40/site_perl    \
             -D vendorlib=/usr/lib/perl5/5.40/vendor_perl \
             -D vendorarch=/usr/lib/perl5/5.40/vendor_perl

make
make install

cd /sources 
tar -xvf Python-3.13.1.tar.xz
cd Python-3.13.1
./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip 
make 
make install

cd /sources 
tar -xvf texinfo-7.2.tar.xz
cd texinfo-7.2 
./configure --prefix=/usr 
make 
make install 

cd /sources 
tar -xvf util-linux-2.40.2.tar.xz 
cd util-linux-2.40.2 
mkdir -pv /var/lib/hwclock 
./configure --libdir=/usr/lib     \
            --runstatedir=/run    \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-static      \
            --disable-liblastlog2 \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.40.2 
make 
make install 


make distclean 
CC="gcc -m32" \
./configure --host=i686-pc-linux-gnu \
            --libdir=/usr/lib32      \
            --runstatedir=/run       \
            --docdir=/usr/share/doc/util-linux-2.40.2 \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-static      \
            --disable-liblastlog2 \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime 

make 
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR
