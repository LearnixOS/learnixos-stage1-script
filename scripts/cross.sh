#!/bin/sh
set -e

#
# original author: saladtoes
# modified by: cowmonk
#

# --- Configuration ---
export LFS_SOURCES="$LFS/sources"
export LFS_TOOLS="$LFS/tools"
export LFS_TARGET_TRIPLE="$LFS_TGT"
export LFS_TARGET_TRIPLE32="$LFS_TGT32"
export LFS_TARGET_TRIPLEX32="$LFS_TGTX32"

# Define versions for packages - easier to update
export BINUTILS_VERSION="2.43.1"
export GCC_VERSION="14.2.0"
export MPFR_VERSION="4.2.1"
export GMP_VERSION="6.3.0"
export MPC_VERSION="1.3.1"
export LINUX_VERSION="6.12.7"
export GLIBC_VERSION="2.40"
export M4_VERSION="1.4.19"
export NCURSES_VERSION="6.5"
export BASH_VERSION="5.2.37"
export COREUTILS_VERSION="9.5"
export DIFFUTILS_VERSION="3.10"
export FILE_VERSION="5.46"
export FINDUTILS_VERSION="4.10.0"
export GAWK_VERSION="5.3.1"
export GREP_VERSION="3.11"
export GZIP_VERSION="1.13"
export MAKE_VERSION="4.4.1"
export PATCH_VERSION="2.7.6"
export SED_VERSION="4.9"
export TAR_VERSION="1.35"
export XZ_VERSION="5.6.3"


# --- Helper Functions ---
extract_source() {
    local package="$1"
    local version_var="${2}_VERSION"
    local version="${!version_var}" # Indirect expansion
    local file_ext="$3"
    local filename="$package-$version.$file_ext"

    echo "Extracting $package-$version..."
    if [ ! -f "$LFS_SOURCES/$filename" ]; then
        echo "Error: Source file $filename not found in $LFS_SOURCES"
        exit 1
    fi
    tar -xf "$LFS_SOURCES/$filename"
    cd "$package-$version" || exit 1 # Ensure cd is successful
}

build_package() {
    local package_name="$1"
    local configure_flags="$2"
    local install_dir="$4"

    echo "--- Building $package_name ---"
    mkdir -p build && cd build || exit 1
    ../configure $configure_flags || exit 1
    make || exit 1
    make DESTDIR="$install_dir" install || exit 1
    cd .. # Back to package source directory
    echo "--- $package_name build completed ---"
}


# --- Main Script Start ---
cd "$LFS_SOURCES" || exit 1 # Ensure we start in the sources directory


# --- BINUTILS - Pass 1 ---
extract_source "binutils" "BINUTILS" "tar.xz"
BINUTILS_CONFIG_FLAGS="--prefix=$LFS_TOOLS \
                     --with-sysroot=$LFS \
                     --target=$LFS_TARGET_TRIPLE \
                     --disable-nls \
                     --enable-gprofng=no \
                     --disable-werror \
                     --enable-default-hash-style=gnu \
                     --enable-multilib"
build_package "binutils" "$BINUTILS_CONFIG_FLAGS" "" "$LFS_TOOLS"
cd .. # Back to sources directory


# --- GCC - Pass 1 ---
extract_source "gcc" "GCC" "tar.xz"
extract_source "mpfr" "MPFR" "tar.xz"
mv -v "mpfr-$MPFR_VERSION" mpfr
extract_source "gmp" "GMP" "tar.xz"
mv -v "gmp-$GMP_VERSION" gmp
extract_source "mpc" "MPC" "tar.gz"
mv -v "mpc-$MPC_VERSION" mpc

# Patch for multilib configuration in GCC (adjust if needed)
sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64
sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' -i gcc/config/i386/i386.h

GCC_CONFIG_FLAGS="--target=$LFS_TARGET_TRIPLE \
                  --prefix=$LFS_TOOLS \
                  --with-glibc-version=2.40 \
                  --with-sysroot=$LFS \
                  --with-newlib \
                  --without-headers \
                  --enable-default-pie \
                  --enable-default-ssp \
                  --enable-initfini-array \
                  --disable-nls \
                  --disable-shared \
                  --enable-multilib --with-multilib-list=m64,m32 \
                  --disable-decimal-float \
                  --disable-threads \
                  --disable-libatomic \
                  --disable-libgomp \
                  --disable-libquadmath \
                  --disable-libssp \
                  --disable-libvtv \
                  --disable-libstdcxx \
                  --enable-languages=c,c++"
build_package "gcc-pass1" "$GCC_CONFIG_FLAGS" "" "$LFS_TOOLS"
cd .. # Back to sources directory

# Copy limits.h
mkdir -pv "$LFS_TOOLS/$LFS_TARGET_TRIPLE/libgcc/include"
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  "$LFS_TOOLS/$LFS_TARGET_TRIPLE/libgcc/include/limits.h"

# --- LINUX HEADERS ---
extract_source "linux" "LINUX" "tar.xz"
make mrproper
make headers_install INSTALL_HDR_PATH="$LFS/usr"
find "$LFS/usr/include" -type f ! -name '*.h' -delete


# --- GLIBC ---
extract_source "glibc" "GLIBC" "tar.xz"
ln -sfv "../lib/ld-linux-x86-64.so.2" "$LFS/lib64"
ln -sfv "../lib/ld-linux-x86-64.so.2" "$LFS/lib64/ld-lsb-x86-64.so.3"
patch -Np1 -i "../glibc-$GLIBC_VERSION-fhs-1.patch" # Assuming patch is in sources dir

GLIBC_CONFIG_FLAGS="--prefix=/usr \
                    --host=$LFS_TARGET_TRIPLE \
                    --build=$(../scripts/config.guess) \
                    --enable-kernel=5.4 \
                    --with-headers=$LFS/usr/include \
                    --disable-nscd \
                    libc_cv_slibdir=/usr/lib"
GLIBC_MAKE_FLAGS=""
GLIBC_INSTALL_DIR="$LFS"
build_package "glibc" "$GLIBC_CONFIG_FLAGS" "$GLIBC_MAKE_FLAGS" "$GLIBC_INSTALL_DIR"

sed '/RTLDLIST=/s@/usr@@g' -i "$LFS/usr/bin/ldd"

cd build && make clean && cd .. # Clean build directory of glibc before 32-bit build

GLIBC_CONFIG_FLAGS_32BIT="--prefix=/usr \
                          --host=$LFS_TARGET_TRIPLE32 \
                          --build=$(../scripts/config.guess) \
                          --enable-kernel=5.4 \
                          --with-headers=$LFS/usr/include \
                          --disable-nscd \
                          --libdir=/usr/lib32 \
                          --libexecdir=/usr/lib32 \
                          libc_cv_slibdir=/usr/lib32"
GLIBC_MAKE_FLAGS_32BIT="CC=\"$LFS_TARGET_TRIPLE-gcc -m32\" CXX=\"$LFS_TARGET_TRIPLE-g++ -m32\""
GLIBC_INSTALL_DIR_32BIT="$LFS/sources/glibc-$GLIBC_VERSION/build/DESTDIR"
build_package "glibc-32bit" "$GLIBC_CONFIG_FLAGS_32BIT" "$GLIBC_MAKE_FLAGS_32BIT" "$GLIBC_INSTALL_DIR_32BIT"

cp -a "$GLIBC_INSTALL_DIR_32BIT/usr/lib32" "$LFS/usr/"
install -vm644 "$GLIBC_INSTALL_DIR_32BIT/usr/include/gnu/lib-names-32.h" "$LFS/usr/include/gnu/"
install -vm644 "$GLIBC_INSTALL_DIR_32BIT/usr/include/gnu/stubs-32.h"     "$LFS/usr/include/gnu/"
ln -svf "../lib32/ld-linux.so.2" "$LFS/lib/ld-linux.so.2"
cd .. # Back to sources directory


# --- GCC - Pass 2 (libstdc++) ---
extract_source "gcc" "GCC" "tar.xz" # Re-extract GCC source
GCC_LIBSTDCXX_CONFIG_FLAGS="--host=$LFS_TARGET_TRIPLE \
                              --build=$(../config.guess) \
                              --prefix=/usr \
                              --enable-multilib \
                              --disable-nls \
                              --disable-libstdcxx-pch \
                              --with-gxx-include-dir=$LFS_TOOLS/$LFS_TARGET_TRIPLE/include/c++/$GCC_VERSION"
build_package "gcc-libstdc++" "$GCC_LIBSTDCXX_CONFIG_FLAGS" "" "$LFS"
rm -v "$LFS/usr/lib/libstdc++exp.la"
rm -v "$LFS/usr/lib/libstdc++fs.la"
rm -v "$LFS/usr/lib/libsupc++.la"
cd .. # Back to sources directory


# --- M4 ---
extract_source "m4" "M4" "tar.xz"
M4_CONFIG_FLAGS="--prefix=/usr --host=$LFS_TARGET_TRIPLE --build=$(build-aux/config.guess)"
build_package "m4" "$M4_CONFIG_FLAGS" "" "$LFS"
cd ..


# --- NCURSES ---
extract_source "ncurses" "NCURSES" "tar.gz"
mkdir build-ncurses && cd build-ncurses
../configure --prefix=/usr --host=$LFS_TARGET_TRIPLE --build=$(pwd)/../config.guess AWK=gawk
make -C include
make -C progs tic
cd ..
NCURSES_CONFIG_FLAGS="--prefix=/usr \
                      --host=$LFS_TARGET_TRIPLE \
                      --build=$(./config.guess) \
                      --mandir=/usr/share/man \
                      --with-manpage-format=normal \
                      --with-shared \
                      --without-normal \
                      --with-cxx-shared \
                      --without-debug \
                      --without-ada \
                      --disable-stripping \
                      AWK=gawk"
build_package "ncurses" "$NCURSES_CONFIG_FLAGS" "" "$LFS"
cd "ncurses-$NCURSES_VERSION" || exit 1 # Re-enter ncurses source dir after build function cd
ln -sv libncursesw.so "$LFS/usr/lib/libncurses.so"
sed -e 's/^#if.*XOPEN.*$/#if 1/' -i "$LFS/usr/include/curses.h"
make distclean

NCURSES_CONFIG_FLAGS_32BIT="--prefix=/usr \
                            --host=$LFS_TARGET_TRIPLE32 \
                            --build=$(./config.guess) \
                            --libdir=/usr/lib32 \
                            --mandir=/usr/share/man \
                            --with-shared \
                            --without-normal \
                            --with-cxx-shared \
                            --without-debug \
                            --without-ada \
                            --disable-stripping"
NCURSES_MAKE_FLAGS_32BIT="CC=\"$LFS_TARGET_TRIPLE-gcc -m32\" CXX=\"$LFS_TARGET_TRIPLE-g++ -m32\""
NCURSES_INSTALL_DIR_32BIT="$PWD/DESTDIR"
build_package "ncurses-32bit" "$NCURSES_CONFIG_FLAGS_32BIT" "$NCURSES_MAKE_FLAGS_32BIT" "$NCURSES_INSTALL_DIR_32BIT"

ln -sv libncursesw.so "$NCURSES_INSTALL_DIR_32BIT/usr/lib32/libncurses.so"
cp -Rv "$NCURSES_INSTALL_DIR_32BIT/usr/lib32/" "$LFS/usr/lib32"
rm -rf "$NCURSES_INSTALL_DIR_32BIT"
cd .. # Back to sources directory


# --- BASH ---
extract_source "bash" "BASH" "tar.gz"
BASH_CONFIG_FLAGS="--prefix=/usr \
                   --build=$(sh support/config.guess) \
                   --host=$LFS_TARGET_TRIPLE \
                   --without-bash-malloc"
build_package "bash" "$BASH_CONFIG_FLAGS" "" "$LFS"
ln -sv bash "$LFS/bin/sh"
cd .. # Back to sources directory


# --- COREUTILS ---
extract_source "coreutils" "COREUTILS" "tar.xz"
COREUTILS_CONFIG_FLAGS="--prefix=/usr \
                        --host=$LFS_TARGET_TRIPLE \
                        --build=$(build-aux/config.guess) \
                        --enable-install-program=hostname \
                        --enable-no-install-program=kill,uptime"
build_package "coreutils" "$COREUTILS_CONFIG_FLAGS" "" "$LFS"
mv -v "$LFS/usr/bin/chroot" "$LFS/usr/sbin"
mkdir -pv "$LFS/usr/share/man/man8"
mv -v "$LFS/usr/share/man/man1/chroot.1" "$LFS/usr/share/man/man8/chroot.8"
sed -i 's/"1"/"8"/' "$LFS/usr/share/man/man8/chroot.8"
cd .. # Back to sources directory


# --- DIFFUTILS ---
extract_source "diffutils" "DIFFUTILS" "tar.xz"
DIFFUTILS_CONFIG_FLAGS="--prefix=/usr --host=$LFS_TARGET_TRIPLE --build=$(./build-aux/config.guess)"
build_package "diffutils" "$DIFFUTILS_CONFIG_FLAGS" "" "$LFS"
cd .. # Back to sources directory


# --- FILE ---
extract_source "file" "FILE" "tar.gz"
mkdir build-file && cd build-file
../configure --disable-bzlib --disable-libseccomp --disable-xzlib --disable-zlib
make
cd ..
FILE_CONFIG_FLAGS="--prefix=/usr --host=$LFS_TARGET_TRIPLE --build=$(./config.guess)"
FILE_MAKE_FLAGS="FILE_COMPILE=$(pwd)/build-file/src/file"
build_package "file" "$FILE_CONFIG_FLAGS" "$FILE_MAKE_FLAGS" "$LFS"
rm -v "$LFS/usr/lib/libmagic.la"
cd .. # Back to sources directory


# --- FINDUTILS ---
extract_source "findutils" "FINDUTILS" "tar.xz"
FINDUTILS_CONFIG_FLAGS="--prefix=/usr \
                        --localstatedir=/var/lib/locate \
                        --host=$LFS_TARGET_TRIPLE \
                        --build=$(build-aux/config.guess)"
build_package "findutils" "$FINDUTILS_CONFIG_FLAGS" "" "$LFS"
cd .. # Back to sources directory


# --- GAWK ---
extract_source "gawk" "GAWK" "tar.xz"
sed -i 's/extras//' Makefile.in # Apply sed patch directly
GAWK_CONFIG_FLAGS="--prefix=/usr --host=$LFS_TARGET_TRIPLE --build=$(build-aux/config.guess)"
build_package "gawk" "$GAWK_CONFIG_FLAGS" "" "$LFS"
cd .. # Back to sources directory


# --- GREP ---
extract_source "grep" "GREP" "tar.xz"
GREP_CONFIG_FLAGS="--prefix=/usr --host=$LFS_TARGET_TRIPLE --build=$(./build-aux/config.guess)"
build_package "grep" "$GREP_CONFIG_FLAGS" "" "$LFS"
cd .. # Back to sources directory


# --- GZIP ---
extract_source "gzip" "GZIP" "tar.xz"
GZIP_CONFIG_FLAGS="--prefix=/usr --host=$LFS_TARGET_TRIPLE"
build_package "gzip" "$GZIP_CONFIG_FLAGS" "" "$LFS"
cd .. # Back to sources directory


# --- MAKE ---
extract_source "make" "MAKE" "tar.gz"
MAKE_CONFIG_FLAGS="--prefix=/usr --without-guile --host=$LFS_TARGET_TRIPLE --build=$(build-aux/config.guess)"
build_package "make" "$MAKE_CONFIG_FLAGS" "" "$LFS"
cd .. # Back to sources directory


# --- PATCH ---
extract_source "patch" "PATCH" "tar.xz"
PATCH_CONFIG_FLAGS="--prefix=/usr --host=$LFS_TARGET_TRIPLE --build=$(build-aux/config.guess)"
build_package "patch" "$PATCH_CONFIG_FLAGS" "" "$LFS"
cd .. # Back to sources directory


# --- SED ---
extract_source "sed" "SED" "tar.xz"
SED_CONFIG_FLAGS="--prefix=/usr --host=$LFS_TARGET_TRIPLE --build=$(./build-aux/config.guess)"
build_package "sed" "$SED_CONFIG_FLAGS" "" "$LFS"
cd .. # Back to sources directory


# --- TAR ---
extract_source "tar" "TAR" "tar.xz"
TAR_CONFIG_FLAGS="--prefix=/usr --host=$LFS_TARGET_TRIPLE --build=$(build-aux/config.guess)"
build_package "tar" "$TAR_CONFIG_FLAGS" "" "$LFS"
cd .. # Back to sources directory


# --- XZ ---
extract_source "xz" "XZ" "tar.xz"
XZ_CONFIG_FLAGS="--prefix=/usr \
                 --host=$LFS_TARGET_TRIPLE \
                 --build=$(build-aux/config.guess) \
                 --disable-static \
                 --docdir=/usr/share/doc/xz-$XZ_VERSION"
build_package "xz" "$XZ_CONFIG_FLAGS" "" "$LFS"
rm -v "$LFS/usr/lib/liblzma.la"
cd .. # Back to sources directory


# --- BINUTILS - Pass 2 ---
extract_source "binutils" "BINUTILS" "tar.xz" # Re-extract binutils source
sed '6009s/$add_dir//' -i ltmain.sh # Apply sed patch directly

BINUTILS_CONFIG_FLAGS_SHARED="--prefix=/usr \
                             --build=$(../config.guess) \
                             --host=$LFS_TARGET_TRIPLE \
                             --disable-nls \
                             --enable-shared \
                             --enable-gprofng=no \
                             --disable-werror \
                             --enable-64-bit-bfd \
                             --enable-default-hash-style=gnu \
                             --enable-multilib"
build_package "binutils-shared" "$BINUTILS_CONFIG_FLAGS_SHARED" "" "$LFS"
rm -v "$LFS/usr/lib/libbfd.a"
rm -v "$LFS/usr/lib/libbfd.la"
rm -v "$LFS/usr/lib/libctf.a"
rm -v "$LFS/usr/lib/libctf.la"
rm -v "$LFS/usr/lib/libctf-nobfd.a"
rm -v "$LFS/usr/lib/libctf-nobfd.la"
rm -v "$LFS/usr/lib/libopcodes.a"
rm -v "$LFS/usr/lib/libopcodes.la"
rm -v "$LFS/usr/lib/libsframe.a"
rm -v "$LFS/usr/lib/libsframe.la"
cd .. # Back to sources directory


# --- GCC - Pass 2 (Final) ---
extract_source "gcc" "GCC" "tar.xz" # Re-extract GCC source
extract_source "mpfr" "MPFR" "tar.xz"
mv -v "mpfr-$MPFR_VERSION" mpfr
extract_source "gmp" "GMP" "tar.xz"
mv -v "gmp-$GMP_VERSION" gmp
extract_source "mpc" "MPC" "tar.gz"
mv -v "mpc-$MPC_VERSION" mpc

# Re-apply patches for GCC
sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64
sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' -i gcc/config/i386/i386.h
sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

GCC_CONFIG_FLAGS_FINAL="--build=$(../config.guess) \
                        --host=$LFS_TARGET_TRIPLE \
                        --target=$LFS_TARGET_TRIPLE \
                        LDFLAGS_FOR_TARGET=\"-L\$PWD/\$LFS_TARGET_TRIPLE/libgcc\" \
                        --prefix=/usr \
                        --with-build-sysroot=$LFS \
                        --enable-default-pie \
                        --enable-default-ssp \
                        --disable-nls \
                        --enable-multilib --with-multilib-list=m64,m32 \
                        --disable-libatomic \
                        --disable-libgomp \
                        --disable-libquadmath \
                        --disable-libsanitizer \
                        --disable-libssp \
                        --disable-libvtv \
                        --enable-languages=c,c++"
build_package "gcc-final" "$GCC_CONFIG_FLAGS_FINAL" "" "$LFS"
ln -sv gcc "$LFS/usr/bin/cc"

echo "--- Cross-compilation completed ---"
echo "--- Exiting cross.sh and runing chroot.sh ---"
exit 0

