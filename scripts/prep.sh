#!/bin/bash

#
# original author: saladtoes
# modified by: cowmonk
#

set -eo pipefail
shopt -s nullglob

# Configuration
SOURCES_DIR="$LFS/sources"
WGET_LIST_URL="https://linuxfromscratch.org/~thomas/multilib-m32/wget-list-sysv"

# Error handling
trap 'echo "Error in $0 at line $LINENO"; exit 1' ERR

print_header() {
        printf "\n\e[1;34m%s\e[0m\n" "$1"
}

setup_directories() {
        print_header "Creating LFS directory structure"
        mkdir -pv "$LFS"/{sources,etc,var,usr/{bin,lib,sbin},tools,lib64,lib32,usr/lib32}

        local dir_links=("bin" "lib" "sbin")
        for dir in "${dir_links[@]}"; do
                ln -sfv "usr/$dir" "$LFS/$dir"
        done
        ln -sfv usr/lib32 "$LFS/lib32"

        chmod -v a+wt "$SOURCES_DIR"
}

setup_sources() {
        print_header "Downloading package sources"
        wget --input-file=<(wget -qO- "$WGET_LIST_URL") \
             --continue \
             --directory-prefix="$SOURCES_DIR"
}

setup_lfs_user() {
        print_header "Configuring LFS user"
        if ! id lfs &>/dev/null; then
                groupadd lfs
                useradd -s /bin/bash -g lfs -m lfs
                echo "Set password for lfs user:"
                passwd lfs
        fi

        local dirs_to_own=("usr" "lib" "var" "etc" "bin" "sbin" "tools" "lib64" "lib32")
        for dir in "${dirs_to_own[@]}"; do
                chown -v lfs:lfs "$LFS/$dir"
        done
}

copy_build_scripts() {
        print_header "Deploying build scripts"
        local scripts=(env.sh cross.sh chrootprep.sh chroot.sh)
        for script in "${scripts[@]}"; do
                install -v -o lfs -g lfs -m 755 ./scripts/"$script" "/home/lfs/$script"
        done
}

main() {
        echo "Initializing LFS system in: $LFS"
        mkdir -pv "$LFS"
        setup_directories
        setup_sources
        setup_lfs_user
        copy_build_scripts

        echo -e "\nPrep stage complete"
}

main "$@"
