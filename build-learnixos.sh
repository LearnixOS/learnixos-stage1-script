#!/bin/sh -e
# shellcheck disable=1090,1091

# Bootstrapper for LXOS
# See LICENSE file for copyright and license details

BOOTSTRAP_LXPKG="$PWD/lxos-root"

# List of packages to be installed
# Most of those are already dependencies
# of each other but it is not a bad idea
# to put them to the list anyway.

# The order here is very important. Packages earlier in this
# list are installed first, so we need to be sure that for
# each package, all of it's library dependencies are alreay
# installed before we try to build it.
PKGS="certs glibc linux-headers zlib m4 flex binutils slimtools busybox"

CFLAGS="-march=x86_64 -mtune=generic -pipe -O3"
CXXFLAGS="-march=x86_64 -mtune=generic -pipe -O3"
MAKEFLAGS="-j$(nproc)"
PKG_CONFIG_PATH=""
PKG_CONFIG_SYSROOT_DIR="$BOOTSTRAP_LXPKG"
PKG_CONFIG_LIBDIR="$BOOTSTRAP_LXPKG/usr/lib/pkgconfig:$BOOTSTRAP_LXPKG/usr/share/pkgconfig"

# Repository
REPO="https://github.com/learnixOS/repo.git"
HOST_REPO="/usr/src/lxpkg/repo"

# Final tarball name.
TARBALL="lxos-tarball-$(date +%Y.%m).tar.xz"

export BOOTSTRAP_LXPKG PKGS CFLAGS CXXFLAGS REPO HOST_REPO_PATH MAKEFLAGS LXOS_HOOK TARBALL

checkenv() {
        command -v lxpkg || die "'lxpkg' is needed for the bootstrapping process!"
        command -v b3sum || die "'b3sum' is needed for the bootstrapping process!"
        command -v gawk || die "'gawk' is neeeded for the bootstrapping process!"
        # FIXME: disable zstd support in binutils
        if command -v zstd; then
                die "'zstd' is picked up by 'binutils' with no way to disable and will lead to a build failure!"
        fi
}

baselayout() {
        curl -fLO https://github.com/LearnixOS/learnixos-stage1-script/releases/download/ignore/baselayout.tar.xz

        tar xf baselayout.tar.xz

        mkdir -m 755 -p \
                "$BOOTSTRAP_LXPKG/boot" \
                "$BOOTSTRAP_LXPKG/dev" \
                "$BOOTSTRAP_LXPKG/etc" \
                "$BOOTSTRAP_LXPKG/home" \
                "$BOOTSTRAP_LXPKG/mnt" \
                "$BOOTSTRAP_LXPKG/opt" \
                "$BOOTSTRAP_LXPKG/run" \
                "$BOOTSTRAP_LXPKG/usr/bin" \
                "$BOOTSTRAP_LXPKG/usr/include" \
                "$BOOTSTRAP_LXPKG/usr/lib" \
                "$BOOTSTRAP_LXPKG/usr/share" \
                "$BOOTSTRAP_LXPKG/usr/share/man" \
                "$BOOTSTRAP_LXPKG/usr/share/man/man1" \
                "$BOOTSTRAP_LXPKG/usr/share/man/man2" \
                "$BOOTSTRAP_LXPKG/usr/share/man/man3" \
                "$BOOTSTRAP_LXPKG/usr/share/man/man4" \
                "$BOOTSTRAP_LXPKG/usr/share/man/man5" \
                "$BOOTSTRAP_LXPKG/usr/share/man/man6" \
                "$BOOTSTRAP_LXPKG/usr/share/man/man7" \
                "$BOOTSTRAP_LXPKG/usr/share/man/man8" \
                "$BOOTSTRAP_LXPKG/var/cache" \
                "$BOOTSTRAP_LXPKG/var/local" \
                "$BOOTSTRAP_LXPKG/var/opt" \
                "$BOOTSTRAP_LXPKG/var/log" \
                "$BOOTSTRAP_LXPKG/var/log/old" \
                "$BOOTSTRAP_LXPKG/var/lib" \
                "$BOOTSTRAP_LXPKG/var/lib/misc" \
                "$BOOTSTRAP_LXPKG/var/empty" \
                "$BOOTSTRAP_LXPKG/var/service" \
                "$BOOTSTRAP_LXPKG/var/spool"
        mkdir -m 555 -p \
                "$BOOTSTRAP_LXPKG/proc" \
                "$BOOTSTRAP_LXPKG/sys"

        mkdir -m 0750 -p \
                "$BOOTSTRAP_LXPKG/root"

        mkdir -m 1777 -p \
                "$BOOTSTRAP_LXPKG/tmp" \
                "$BOOTSTRAP_LXPKG/var/tmp" \
                "$BOOTSTRAP_LXPKG/var/spool/mail"

        ln -sf $BOOTSTRAP_LXPKG/usr/bin "$BOOTSTRAP_LXPKG/bin"
        ln -sf $BOOTSTRAP_LXPKG/usr/bin "$BOOTSTRAP_LXPKG/sbin"
        ln -sf $BOOTSTRAP_LXPKG/bin     "$BOOTSTRAP_LXPKG/usr/sbin"
        ln -sf $BOOTSTRAP_LXPKG/usr/lib "$BOOTSTRAP_LXPKG/lib"
        ln -sf $BOOTSTRAP_LXPKG/usr/lib "$BOOTSTRAP_LXPKG/lib64"

        ln -sf $BOOTSTRAP_LXPKG/lib               "$BOOTSTRAP_LXPKG/usr/lib64"
        ln -sf $BOOTSTRAP_LXPKG/spool/mail        "$BOOTSTRAP_LXPKG/var/mail"
        ln -sf $BOOTSTRAP_LXPKG/run               "$BOOTSTRAP_LXPKG/var/run"
        ln -sf $BOOTSTRAP_LXPKG/run/lock          "$BOOTSTRAP_LXPKG/var/lock"
        ln -sf $BOOTSTRAP_LXPKG/proc/self/mounts  "$BOOTSTRAP_LXPKG/etc/mtab"

        cp -f ./files/* "$BOOTSTRAP_LXPKG/etc"

        chmod 600 \
                "$BOOTSTRAP_LXPKG/etc/crypttab" \
                "$BOOTSTRAP_LXPKG/etc/shadow"
}

postinstall() {
        # custom commands to run after install

        true
}


# Functions
msg() { printf '\033[1;35m-> \033[m%s\n' "$@" ;}
die() { printf '\033[1;31m!> ERROR: \033[m%s\n' "$@" >&2; exit 1 ;}

msg "Checking to see if the environment can bootstrap successfully..."
checkenv

# Let's get current working directory
BASEDIR="$PWD"

# Check whether absolutely required variables are set.
[ "$PKGS" ]             || die "You must set PKGS variable to continue the bootstrapper"
[ "$BOOTSTRAP_LXPKG" ]  || die "You must specify fakeroot location 'BOOTSTRAP_LXPKG' in order to continue the bootstrapper"
[ "$TARBALL" ]          || die "You must specify the TARBALL variable to continue the bootstrapper"

# Print variables from the configuration file
# shellcheck disable=2154
cat <<EOF
Here are the configuration values:

BOOTSTRAP_LXPKG  = $BOOTSTRAP_LXPKG

Build Options
CFLAGS    = $CFLAGS
CXXFLAGS  = $CXXFLAGS
MAKEFLAGS = $MAKEFLAGS

Repository and package options

REPO            = $REPO
REPO_MULTILIB   = FALSE (not implemented yet)
REPO_NVIDIA     = FALSE (not implemented yet)
PKGS            = $PKGS

Tarball will be written as:
$BASEDIR/$TARBALL

EOF

# If there is NOCONFIRM, skip the prompt.
[ "$NOCONFIRM" ] || {
    printf '\033[1;33m?> \033[mDo you want to start the bootstrapper? (Y/n)\n'
    read -r ans
    case "$ans" in [Yy]*|'') ;; *) die "User exited" ; esac
}

# Script starts here

msg "Starting Script..."
# Save the time that we started the bootstrapper.
awk 'BEGIN { srand(); print srand() }' > "$BASEDIR/starttime"

mkdir -p "$BOOTSTRAP_LXPKG/usr/src/lxpkg"

msg "Downloading Copy of base-LXOS repo to LXOS-stage1"

if [ ! -d $BOOTSTRAP_LXPKG/usr/src/lxpkg/repo ]; then
        git clone https://github.com/LearnixOS/repo $BOOTSTRAP_LXPKG/usr/src/lxpkg/repo
fi

msg "Finished Repo Download"

msg "Creating baselayout"
baselayout

msg "Starting build from the PKGS variable"

# shellcheck disable=2154
for pkg in $PKGS; do
    # Check if the package is already installed and skip.
    [ "$(lxpkg list "$pkg")" = "$pkg $ver-$rel" ] && continue

    # Build and install every package explicitly.
    # While not ideal, this keeps forked packages, as well as
    # ones built with potentially different CFLAGS from polluting
    # the tarball.
    LXPKG_PROMPT=0 lxpkg build "$pkg"
    LXPKG_PROMPT=0 lxpkg install "$pkg"
done

# You can check out about post-installation
# from the configuration file
msg "Installation Complete, starting 'postinstall' procedure if there is one"
postinstall

msg "Generating rootfs to $BASEDIR"
(
    cd "$BOOTSTRAP_LXPKG" || die "Could not change directory to $BOOTSTRAP_LXPKG"
    tar -cJf "$BASEDIR/$TARBALL" .
)

msg "Generating Checksums"
b3sum "$BASEDIR/$TARBALL" > "$BASEDIR/$TARBALL.b3sum"

msg "Done!"

read -r stime < "$BASEDIR/starttime"
rm "${BASEDIR:?}/starttime"
etime=$(awk 'BEGIN { srand(); print srand() }')
elapsed_sec=$((etime - stime))
elapsed_min=$((elapsed_sec / 60))
elapsed_hrs=$((elapsed_min / 60))
elapsed_sec=$((elapsed_sec % 60))
elapsed_min=$((elapsed_min % 60))
msg "Took ${elapsed_hrs}h.${elapsed_min}m.${elapsed_sec}s"
