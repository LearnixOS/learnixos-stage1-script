#!/bin/sh
set -e 
cd /sources 
tar -xvf libtool-2.5.4.tar.xz
cd libtool-2.5.4
./configure --prefix=/usr 
make 
make install 
rm -fv /usr/lib/libltdl.a
make distclean 
CC="gcc -m32" ./configure \
    --host=i686-pc-linux-gnu \
    --prefix=/usr            \
    --libdir=/usr/lib32 
make 
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR 


cd /sources 
tar -xvf gdbm-1.24.tar.gz 
cd gdbm-1.24
./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat
make 
make install
make distclean 
CC="gcc -m32" CXX="g++ -m32" ./configure \
    --host=i686-pc-linux-gnu      \
    --prefix=/usr                 \
    --libdir=/usr/lib32           \
    --disable-static              \
    --enable-libgdbm-compat 
make 
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32/
rm -rf DESTDIR 

cd /sources 
tar -xvf gperf-3.1.tar.gz 
cd gperf-3.1
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1 
make 
make install 

cd /sources 
tar -xvf expat-2.6.4.tar.xz 
cd expat-2.6.4


./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.6.4
make
make install
install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.6.4
sed -e "/^am__append_1/ s/doc//" -i Makefile
make clean
CC="gcc -m32" ./configure \
    --prefix=/usr        \
    --disable-static     \
    --libdir=/usr/lib32  \
    --host=i686-pc-linux-gnu
make 
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR 


cd /sources 
tar -xvf inetutils-2.5.tar.xz 
cd inetutils-2.5
sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c
./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers 
make 
make install 
mv -v /usr/{,s}bin/ifconfig

cd /sources 
tar -xvf less-668.tar.gz
cd less-668
./configure --prefix=/usr --sysconfdir=/etc 
make 
make install 

cd /sources 
tar -xvf perl-5.40.0.tar.xz
cd perl-5.40.0

export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des                                          \
             -D prefix=/usr                                \
             -D vendorprefix=/usr                          \
             -D privlib=/usr/lib/perl5/5.40/core_perl      \
             -D archlib=/usr/lib/perl5/5.40/core_perl      \
             -D sitelib=/usr/lib/perl5/5.40/site_perl      \
             -D sitearch=/usr/lib/perl5/5.40/site_perl     \
             -D vendorlib=/usr/lib/perl5/5.40/vendor_perl  \
             -D vendorarch=/usr/lib/perl5/5.40/vendor_perl \
             -D man1dir=/usr/share/man/man1                \
             -D man3dir=/usr/share/man/man3                \
             -D pager="/usr/bin/less -isR"                 \
             -D useshrplib                                 \
             -D usethreads
make 


make install
unset BUILD_ZLIB BUILD_BZIP2

cd /sources 
tar -xvf XML-Parser-2.47.tar.gz 
cd XML-Parser-2.47
perl Makefile.PL
make 
make install 


cd /sources 
tar -xvf intltool-0.51.0.tar.gz 
cd intltool-0.51.0
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr 
make 


make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO


cd /sources 
tar -xvf autoconf-2.72.tar.xz 
cd autoconf-2.72
./configure --prefix=/usr 
make 
make install

cd /sources 
tar -xvf automake-1.17.tar.xz
cd automake-1.17 
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.17 
make 
make install

cd /sources 
tar -xvf openssl-3.4.0.tar.gz 
cd openssl-3.4.0
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
make 
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install 
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.4.0 
cp -vfr doc/* /usr/share/doc/openssl-3.4.0 
make distclean
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib32        \
         shared                \
         zlib-dynamic          \
         linux-x86 
make 
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR 

cd /sources 
tar -xvf kmod-33.tar.xz 
cd kmod-33
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --with-openssl    \
            --with-xz         \
            --with-zstd       \
            --with-zlib       \
            --disable-manpages
make 
make install

for target in depmod insmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /usr/sbin/$target
  rm -fv /usr/bin/$target
done 
sed -e "s/^CLEANFILES =.*/CLEANFILES =/" -i man/Makefile
make clean 
CC="gcc -m32" ./configure \
    --host=i686-pc-linux-gnu      \
    --prefix=/usr                 \
    --libdir=/usr/lib32           \
    --sysconfdir=/etc             \
    --with-openssl                \
    --with-xz                     \
    --with-zstd                   \
    --with-zlib                   \
    --disable-manpages            \
    --with-rootlibdir=/usr/lib32 
make 
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR 

cd /sources 
tar -xvf elfutils-0.192.tar.bz2 
cd elfutils-0.192
./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy 
make 
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a 
make distclean 
CC="gcc -m32" CXX="g++ -m32" ./configure \
    --host=i686-pc-linux-gnu \
    --prefix=/usr            \
    --libdir=/usr/lib32      \
    --disable-debuginfod     \
    --enable-libdebuginfod=dummy 
make 
make DESTDIR=$PWD/DESTDIR -C libelf install
install -vDm644 config/libelf.pc DESTDIR/usr/lib32/pkgconfig/libelf.pc
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR 

cd /sources 
tar -xvf libffi-3.4.6.tar.gz
cd libffi-3.4.6 


./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native 
make 
make install 
make distclean 
CC="gcc -m32" CXX="g++ -m32" ./configure \
    --host=i686-pc-linux-gnu \
    --prefix=/usr            \
    --libdir=/usr/lib32      \
    --disable-static         \
    --with-gcc-arch=i686 
make 
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR 

cd /sources 
tar -xvf Python-3.13.1.tar.xz
cd Python-3.13.1
./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --enable-optimizations 
make 
make install 
cp /files/pip.conf /etc/pip.conf 
install -v -dm755 /usr/share/doc/python-3.13.1/html

tar --no-same-owner \
    -xvf ../python-3.13.1-docs-html.tar.bz2
cp -R --no-preserve=mode python-3.13.1-docs-html/* \
    /usr/share/doc/python-3.13.1/html


cd /sources 
tar -xvf flit_core-3.10.1.tar.gz 
cd flit_core-3.10.1
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD 
pip3 install --no-index --no-user --find-links dist flit_core 

cd /sources 
tar -xvf wheel-0.45.1.tar.gz
cd wheel-0.45.1 
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD 
pip3 install --no-index --find-links=dist wheel

cd /sources 
tar -xvf setuptools-75.6.0.tar.gz
cd setuptools-75.6.0
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist setuptools

cd /sources
tar -xvf ninja-1.12.1.tar.gz
cd ninja-1.12.1
export NINJAJOBS=8
sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc
python3 configure.py --bootstrap
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

cd /sources
tar -xvf meson-1.6.1.tar.gz
cd meson-1.6.1
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

cd /sources
tar -xvf coreutils-9.5.tar.xz
cd coreutils-9.5
patch -Np1 -i ../coreutils-9.5-i18n-2.patch
autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime
make
make install
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8

cd /sources
tar -xvf check-0.15.2.tar.gz
cd check-0.15.2
./configure --prefix=/usr --disable-static
make
make docdir=/usr/share/doc/check-0.15.2 install

cd /sources
tar -xvf diffutils-3.10.tar.xz
cd diffutils-3.10
./configure --prefix=/usr
make
make install

cd /sources
tar -xvf gawk-5.3.1.tar.xz
cd gawk-5.3.1
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make
rm -f /usr/bin/gawk-5.3.1
make install
ln -sv gawk.1 /usr/share/man/man1/awk.1
install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/gawk-5.3.1


cd /sources
tar -xvf findutils-4.10.tar.xz
cd findutils-4.10
./configure --prefix=/usr --localstatedir=/var/lib/locate
make
make install

cd /sources
tar -xvf groff-1.23.0.tar.gz
cd groff-1.23.0
PAGE=A4 ./configure --prefix=/usr
make
make install

cd /sources
tar -xvf gzip-1.13.tar.xz 
cd gzip-1.13 
./configure --prefix=/usr 
make 
make install

cd /sources 
tar -xvf iproute2-6.12.0.tar.xz
cd iproute2-6.12.0


sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
make NETNS_RUN_DIR=/run/netns
make SBINDIR=/usr/sbin install
install -vDm644 COPYING README* -t /usr/share/doc/iproute2-6.12.0

cd /sources 
tar -xvf kbd-2.7.1.tar.xz
cd kbd-2.7.1
patch -Np1 -i ../kbd-2.7.1-backspace-1.patch
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make
make install
cp -R -v docs/doc -T /usr/share/doc/kbd-2.7.1

cd /sources 
tar -xvf libpipeline-1.5.8.tar.gz
cd libpipeline-1.5.8
./configure --prefix=/usr
make
make install

cd /sources 
tar -xvf make-4.4.1.tar.gz
cd make-4.4.1 
./configure --prefix=/usr
make 
make install

cd /sources 
tar -xvf patch-2.7.6.tar.xz
cd patch-2.7.6
./configure --prefix=/usr
make
make install

cd /sources 
tar -xvf tar-1.35.tar.xz
cd tar-1.35
FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
make
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.35

cd /sources 
tar -xvf texinfo-7.2.tar.xz
cd texinfo-7.2 
./configure --prefix=/usr
make
make install
make TEXMF=/usr/share/texmf install-tex
pushd /usr/share/info
  rm -v dir
  for f in *
    do install-info $f dir 2>/dev/null
  done
popd


cd /sources 
tar -xvf vim-9.1.1016.tar.gz
cd vim-9.1.1016 
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr
make
make install
ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done
ln -sv ../vim/vim91/doc /usr/share/doc/vim-9.1.1016
cp /files/vimrc /etc/vimrc

cd /sources 
tar -xvf markupsafe-3.0.2.tar.gz
cd markupsafe-3.0.2
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --no-user --find-links dist Markupsafe

cd /sources 
tar -xvf jinja2-3.1.5.tar.gz
cd jinja2-3.1.5
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --no-user --find-links dist Jinja2

cd /sources 
tar -xvf systemd-257.tar.gz
cd systemd-257 
sed -e 's/GROUP="render"/GROUP="video"/' -e 's/GROUP="sgx", //' -i rules.d/50-udev-default.rules.in
sed -i '/systemd-sysctl/s/^/#/' rules.d/99-systemd.rules.in 
sed -e '/NETWORK_DIRS/s/systemd/udev/' -i src/libsystemd/sd-network/network-util.h
mkdir -p build
cd       build
meson setup ..                  \
      --prefix=/usr             \
      --buildtype=release       \
      -D mode=release           \
      -D dev-kvm-mode=0660      \
      -D link-udev-shared=false \
      -D logind=false           \
      -D vconsole=false
export udev_helpers=$(grep "'name' :" ../src/udev/meson.build | awk '{print $3}' | tr -d ",'" | grep -v 'udevadm')
ninja udevadm systemd-hwdb $(ninja -n | grep -Eo '(src/(lib)?udev|rules.d|hwdb.d)/[^ ]*')  $(realpath libudev.so --relative-to .) $udev_helpers

install -vm755 -d {/usr/lib,/etc}/udev/{hwdb.d,rules.d,network}
install -vm755 -d /usr/{lib,share}/pkgconfig
install -vm755 udevadm                             /usr/bin/
install -vm755 systemd-hwdb                        /usr/bin/udev-hwdb
ln      -svfn  ../bin/udevadm                      /usr/sbin/udevd
cp      -av    libudev.so{,*[0-9]}                 /usr/lib/
install -vm644 ../src/libudev/libudev.h            /usr/include/
install -vm644 src/libudev/*.pc                    /usr/lib/pkgconfig/
install -vm644 src/udev/*.pc                       /usr/share/pkgconfig/
install -vm644 ../src/udev/udev.conf               /etc/udev/
install -vm644 rules.d/* ../rules.d/README         /usr/lib/udev/rules.d/
install -vm644 $(find ../rules.d/*.rules \
                      -not -name '*power-switch*') /usr/lib/udev/rules.d/
install -vm644 hwdb.d/*  ../hwdb.d/{*.hwdb,README} /usr/lib/udev/hwdb.d/
install -vm755 $udev_helpers                       /usr/lib/udev
install -vm644 ../network/99-default.link          /usr/lib/udev/network


tar -xvf ../../udev-lfs-20230818.tar.xz
make -f udev-lfs-20230818/Makefile.lfs install
tar -xf ../../systemd-man-pages-257.tar.xz                            \
    --no-same-owner --strip-components=1                              \
    -C /usr/share/man --wildcards '*/udev*' '*/libudev*'              \
                                  '*/systemd.link.5'                  \
                                  '*/systemd-'{hwdb,udevd.service}.8

sed 's|systemd/network|udev/network|'                                 \
    /usr/share/man/man5/systemd.link.5                                \
  > /usr/share/man/man5/udev.link.5

sed 's/systemd\(\\\?-\)/udev\1/' /usr/share/man/man8/systemd-hwdb.8   \
                               > /usr/share/man/man8/udev-hwdb.8

sed 's|lib.*udevd|sbin/udevd|'                                        \
    /usr/share/man/man8/systemd-udevd.service.8                       \
  > /usr/share/man/man8/udevd.8

rm /usr/share/man/man*/systemd*
unset udev_helpers
rm -rf *
PKG_CONFIG_PATH="/usr/lib32/pkgconfig" \
CC="gcc -m32 -march=i686"              \
CXX="g++ -m32 -march=i686"             \
LANG=en_US.UTF-8                       \
meson setup \
      --prefix=/usr                 \
      --buildtype=release           \
      -Dmode=release                \
      -Ddev-kvm-mode=0660           \
      -Dlink-udev-shared=false      \
      -Dlogind=false                \
      -Dvconsole=false              \
      ..
ninja \
      $(grep -o -E "^build (src/libudev|src/udev)[^:]*" \
        build.ninja | awk '{ print $2 }')                              \
      $(realpath libudev.so --relative-to .)


mkdir -pv /usr/lib32/pkgconfig &&
cp -av libudev.so{,*[0-9]} /usr/lib32/ &&
sed -e "s;/usr/lib;&32;g" src/libudev/libudev.pc > /usr/lib32/pkgconfig/libudev.pc
udev-hwdb update


cd /sources 
tar -xvf man-db-2.13.0.tar.xz
cd man-db-2.13.0

./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.13.0 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap             \
            --with-systemdtmpfilesdir=            \
            --with-systemdsystemunitdir=

make 
make install

cd /sources 
tar -xvf procps-ng-4.0.5.tar.xz
cd procps-ng-4.0.5
./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.5 \
            --disable-static                        \
            --disable-kill
make
make install

cd /sources 
tar -xvf util-linux-2.40.4.tar.xz
cd util-linux-2.40.4
./configure --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            --without-systemd     \
            --without-systemdsystemunitdir        \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.40.4

make
make install

make distclean
mv /usr/bin/ncursesw6-config{,.tmp}
CC="gcc -m32" \
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --host=i686-pc-linux-gnu \
            --libdir=/usr/lib32      \
            --runstatedir=/run       \
            --sbindir=/usr/sbin      \
            --docdir=/usr/share/doc/util-linux-2.40.4 \
            --disable-chfn-chsh      \
            --disable-login          \
            --disable-nologin        \
            --disable-su             \
            --disable-setpriv        \
            --disable-runuser        \
            --disable-pylibmount     \
            --disable-liblastlog2    \
            --disable-static         \
            --without-python         \
            --without-systemd        \
            --without-systemdsystemunitdir
mv /usr/bin/ncursesw6-config{.tmp,}
make 
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR

cd /sources 
tar -xvf e2fsprogs-1.47.1.tar.gz 
cd e2fsprogs-1.47.1
mkdir -v build
cd       build
../configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
make 
make install
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
sed 's/metadata_csum_seed,//' -i /etc/mke2fs.conf

cd /sources 
tar -xvf sysklogd-2.7.0.tar.gz
cd sysklogd-2.7.0


./configure --prefix=/usr      \
            --sysconfdir=/etc  \
            --runstatedir=/run \
            --without-logger   \
            --docdir=/usr/share/doc/sysklogd-2.7.0
make
make install

cd /sources 
tar -xvf sysvinit-3.13.tar.xz
patch -Np1 -i ../sysvinit-3.13-consolidated-1.patch
make
make install


save_usrlib="$(cd /usr/lib; ls ld-linux*[^g])
             libc.so.6
             libthread_db.so.1
             libquadmath.so.0.0.0
             libstdc++.so.6.0.33
             libitm.so.1.0.0
             libatomic.so.1.2.0"

cd /usr/lib
for LIB in $save_usrlib; do
    objcopy --only-keep-debug --compress-debug-sections=zlib $LIB $LIB.dbg
    cp $LIB /tmp/$LIB
    strip --strip-unneeded /tmp/$LIB
    objcopy --add-gnu-debuglink=$LIB.dbg /tmp/$LIB
    install -vm755 /tmp/$LIB /usr/lib
    rm /tmp/$LIB
done

cd /usr/lib32
for LIB in $save_usrlib; do
    objcopy --only-keep-debug $LIB $LIB.dbg
    cp $LIB /tmp/$LIB
    strip --strip-unneeded /tmp/$LIB
    objcopy --add-gnu-debuglink=$LIB.dbg /tmp/$LIB
    install -vm755 /tmp/$LIB /usr/lib32
    rm /tmp/$LIB
done


online_usrbin="bash find strip"
online_usrlib="libbfd-2.43.1.so
               libsframe.so.1.0.0
               libhistory.so.8.2
               libncursesw.so.6.5
               libm.so.6
               libreadline.so.8.2
               libz.so.1.3.1
               libzstd.so.1.5.6
               $(cd /usr/lib; find libnss*.so* -type f)"

for BIN in $online_usrbin; do
    cp /usr/bin/$BIN /tmp/$BIN
    strip --strip-unneeded /tmp/$BIN
    install -vm755 /tmp/$BIN /usr/bin
    rm /tmp/$BIN
done

for LIB in $online_usrlib; do
    cp /usr/lib/$LIB /tmp/$LIB
    strip --strip-unneeded /tmp/$LIB
    install -vm755 /tmp/$LIB /usr/lib
    rm /tmp/$LIB
done
for LIB in $online_usrlib; do
    cp /usr/lib32/$LIB /tmp/$LIB
    strip --strip-unneeded /tmp/$LIB
    install -vm755 /tmp/$LIB /usr/lib32
    rm /tmp/$LIB
done

for i in $(find /usr/lib -type f -name \*.so* ! -name \*dbg) \
         $(find /usr/lib -type f -name \*.a)                 \
         $(find /usr/{bin,sbin,libexec} -type f); do
    case "$online_usrbin $online_usrlib $save_usrlib" in
        *$(basename $i)* )
            ;;
        * ) strip --strip-unneeded $i
            ;;
    esac
done
for i in $(find /usr/lib32 -type f -name \*.so* ! -name \*dbg) \
         $(find /usr/lib32 -type f -name \*.a); do
    case "$online_usrbin $online_usrlib $save_usrlib" in
        *$(basename $i)* )
            ;;
        * ) strip --strip-unneeded $i
            ;;
    esac
done

unset BIN LIB save_usrlib online_usrbin online_usrlib


rm -rf /tmp/{*,.*}
find /usr/lib /usr/libexec -name \*.la -delete
find /usr/lib32 -name \*.la -delete
find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf
userdel -r tester

cd /sources 
tar -xvf lfs-bootscripts-20240825.tar.xz
cd lfs-bootscripts-20240825
make install

cd /sources
cp /files/inittab /etc/inittab 
cp /files/clock /etc/sysconfig/clock
cp /files/console /etc/sysconfig/console
cp /files/profile /etc/profile 
cp /files/inputrc /etc/inputrc
cp /files/shells /etc/shells
echo versionidk > /etc/lxos-release
cp /files/lsb-release /etc/lsb-release
cp /files/os-release /etc/os-release
