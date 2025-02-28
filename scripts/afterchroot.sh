#!/bin/sh

#
# original author: saladtoes
# modified by: cowmonk
#


set -e

# --- Configuration (from cross.sh) ---
export LFS_SOURCES="/sources"
export LFS_TOOLS="/tools"
export LFS_TARGET_TRIPLE="$LFS_TGT"
export LFS_TARGET_TRIPLE32="$LFS_TGT32"
export LFS_TARGET_TRIPLEX32="$LFS_TGTX32"

# Define versions for packages - easier to update
export GETTEXT_VERSION="0.23"
export BISON_VERSION="3.8.2"
export PERL_VERSION="5.40.0"
export PYTHON_VERSION="3.13.1"
export TEXINFO_VERSION="7.2"
export UTIL_LINUX_VERSION="2.40.2"


# --- Helper Functions (from cross.sh) ---
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
        local make_flags="$3"
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

# --- gettext ---
extract_source "gettext" "GETTEXT" "tar.xz"
GETTEXT_CONFIG_FLAGS="--disable-shared"
GETTEXT_INSTALL_DIR="/"
build_package "gettext" "$GETTEXT_CONFIG_FLAGS" "" "$GETTEXT_INSTALL_DIR"
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
cd ..

# --- bison ---
extract_source "bison" "BISON" "tar.xz"
BISON_CONFIG_FLAGS="--prefix=/usr --docdir=/usr/share/doc/bison-$BISON_VERSION"
BISON_INSTALL_DIR="/"
build_package "bison" "$BISON_CONFIG_FLAGS" "" "$BISON_INSTALL_DIR"
cd ..

# --- perl ---
extract_source "perl" "PERL" "tar.xz"
PERL_CONFIG_FLAGS="-des \
             -D prefix=/usr \
             -D vendorprefix=/usr \
             -D useshrplib \
             -D privlib=/usr/lib/perl5/5.40/core_perl \
             -D archlib=/usr/lib/perl5/5.40/core_perl \
             -D sitelib=/usr/lib/perl5/5.40/site_perl \
             -D sitearch=/usr/lib/perl5/5.40/site_perl \
             -D vendorlib=/usr/lib/perl5/5.40/vendor_perl \
             -D vendorarch=/usr/lib/perl5/5.40/vendor_perl"
PERL_INSTALL_DIR="/"
build_package "perl" "$PERL_CONFIG_FLAGS" "" "$PERL_INSTALL_DIR"
cd ..

# --- python ---
extract_source "Python" "PYTHON" "tar.xz"
PYTHON_CONFIG_FLAGS="--prefix=/usr   \
            --enable-shared \
            --without-ensurepip"
PYTHON_INSTALL_DIR="/"
build_package "python" "$PYTHON_CONFIG_FLAGS" "" "$PYTHON_INSTALL_DIR"
cd ..

# --- texinfo ---
extract_source "texinfo" "TEXINFO" "tar.xz"
TEXINFO_CONFIG_FLAGS="--prefix=/usr"
TEXINFO_INSTALL_DIR="/"
build_package "texinfo" "$TEXINFO_CONFIG_FLAGS" "" "$TEXINFO_INSTALL_DIR"
cd ..

# --- util-linux ---
extract_source "util-linux" "UTIL_LINUX" "tar.xz"
UTIL_LINUX_CONFIG_FLAGS="--libdir=/usr/lib     \
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
            --docdir=/usr/share/doc/util-linux-$UTIL_LINUX_VERSION"
UTIL_LINUX_INSTALL_DIR="/"
mkdir -pv /var/lib/hwclock
build_package "util-linux" "$UTIL_LINUX_CONFIG_FLAGS" "" "$UTIL_LINUX_INSTALL_DIR"

cd "util-linux-$UTIL_LINUX_VERSION"
make distclean

UTIL_LINUX_CONFIG_FLAGS_32BIT="--host=i686-pc-linux-gnu \
            --libdir=/usr/lib32      \
            --runstatedir=/run       \
            --docdir=/usr/share/doc/util-linux-$UTIL_LINUX_VERSION \
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
            ADJTIME_PATH=/var/lib/hwclock/adjtime"
UTIL_LINUX_MAKE_FLAGS_32BIT='CC="gcc -m32"'
UTIL_LINUX_INSTALL_DIR_32BIT="$PWD/DESTDIR"
build_package "util-linux-32bit" "$UTIL_LINUX_CONFIG_FLAGS_32BIT" "$UTIL_LINUX_MAKE_FLAGS_32BIT" "$UTIL_LINUX_INSTALL_DIR_32BIT"

cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR
cd ..

echo "--- stage1-archive.sh completed ---"
exit 0
