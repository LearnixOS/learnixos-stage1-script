#!/bin/sh

set -e

# --- Configuration ---
# Define directories to be created within the chroot environment
export CHROOT_ROOT_DIR="/" # Root directory of the chroot environment

# System directories required for basic OS functionality
declare -a system_dirs=(
    "boot"
    "opt"
    "srv"
    "etc/opt"
    "etc/sysconfig"
    "lib/firmware"
    "media/floppy"
    "media/cdrom"
    "mnt"
    "proc" # Usually mounted by the system, but good to have the dir
    "sys"  # Usually mounted by the system, but good to have the dir
    "run"
    "dev"  # Usually populated by the system, but good to have the dir
)

# User-related directories
declare -a user_dirs=(
    "home"
    "root" # Root user's home directory - ensure permissions later
)

# /usr directories - system programs, libraries, etc.
declare -a usr_dirs=(
    "usr/include"
    "usr/src"
    "usr/lib/locale"
    "usr/share/color"
    "usr/share/dict"
    "usr/share/doc"
    "usr/share/info"
    "usr/share/locale"
    "usr/share/man"
    "usr/share/misc"
    "usr/share/terminfo"
    "usr/share/zoneinfo"
)

# /usr/local directories - locally installed software (outside system package manager)
declare -a usr_local_dirs=(
    "usr/local/include"
    "usr/local/src"
    "usr/local/bin"
    "usr/local/lib"
    "usr/local/sbin"
    "usr/local/share/color"
    "usr/local/share/dict"
    "usr/local/share/doc"
    "usr/local/share/info"
    "usr/local/share/locale"
    "usr/local/share/man"
    "usr/local/share/misc"
    "usr/local/share/terminfo"
    "usr/local/share/zoneinfo"
)

# /usr/share/man and /usr/local/share/man subdirectories for man pages
declare -a man_page_dirs=(
    "man1" "man2" "man3" "man4" "man5" "man6" "man7" "man8"
)

# /var directories - variable data like logs, caches, etc.
declare -a var_dirs=(
    "var/cache"
    "var/local"
    "var/log"
    "var/mail"
    "var/opt"
    "var/spool"
    "var/tmp" # Already handled with permissions below, but for completeness
    "var/lib/color"
    "var/lib/misc"
    "var/lib/locate"
    "var/run" # Symlinked to /run below, but listed for conceptual clarity
    "var/lock" # Symlinked to /run/lock below, but listed for conceptual clarity
)


# --- Directory Creation ---
echo "Creating essential directories..."

# Create system directories
for dir in "${system_dirs[@]}"; do
    mkdir -pv "${CHROOT_ROOT_DIR}/${dir}"
done

# Create user directories
for dir in "${user_dirs[@]}"; do
    mkdir -pv "${CHROOT_ROOT_DIR}/${dir}"
done

# Create /usr directories
for dir in "${usr_dirs[@]}"; do
    mkdir -pv "${CHROOT_ROOT_DIR}/${dir}"
done

# Create /usr/local directories
for dir in "${usr_local_dirs[@]}"; do
    mkdir -pv "${CHROOT_ROOT_DIR}/${dir}"
done

# Create man page subdirectories in /usr/share/man and /usr/local/share/man
for man_dir in "${man_page_dirs[@]}"; do
    mkdir -pv "${CHROOT_ROOT_DIR}/usr/share/man/${man_dir}"
    mkdir -pv "${CHROOT_ROOT_DIR}/usr/local/share/man/${man_dir}"
done

# Create /var directories
for dir in "${var_dirs[@]}"; do
    mkdir -pv "${CHROOT_ROOT_DIR}/${dir}"
done

# Set specific permissions for /root, /tmp, and /var/tmp
echo "Setting directory permissions..."
install -dv -m 0750 "${CHROOT_ROOT_DIR}/root"
install -dv -m 1777 "${CHROOT_ROOT_DIR}/tmp" "${CHROOT_ROOT_DIR}/var/tmp"


# --- Symbolic Links ---
echo "Creating symbolic links..."
ln -sfv /run "${CHROOT_ROOT_DIR}/var/run"
ln -sfv /run/lock "${CHROOT_ROOT_DIR}/var/lock"
ln -sfv /proc/self/mounts "${CHROOT_ROOT_DIR}/etc/mtab"


# --- Essential Files Copy ---
echo "Copying essential files..."
cp /files/passwd "${CHROOT_ROOT_DIR}/etc/passwd"
cp /files/group "${CHROOT_ROOT_DIR}/etc/group"
cp /files/hosts "${CHROOT_ROOT_DIR}/etc/hosts"


# --- Locale Configuration ---
echo "Setting up locale..."
localedef -i C -f UTF-8 C.UTF-8


# --- Add 'tester' User and Group ---
echo "Adding 'tester' user and group..."
echo "tester:x:101:101::/home/tester:/bin/bash" >> "${CHROOT_ROOT_DIR}/etc/passwd"
echo "tester:x:101:" >> "${CHROOT_ROOT_DIR}/etc/group"
install -o tester -d "${CHROOT_ROOT_DIR}/home/tester"


# --- Log Files Setup ---
echo "Setting up log files and permissions..."
touch "${CHROOT_ROOT_DIR}/var/log/btmp"
touch "${CHROOT_ROOT_DIR}/var/log/lastlog"
touch "${CHROOT_ROOT_DIR}/var/log/faillog"
touch "${CHROOT_ROOT_DIR}/var/log/wtmp"
chgrp -v utmp "${CHROOT_ROOT_DIR}/var/log/lastlog"
chmod -v 664  "${CHROOT_ROOT_DIR}/var/log/lastlog"
chmod -v 600  "${CHROOT_ROOT_DIR}/var/log/btmp"


# --- Final Message and Execute Bash ---
echo "Chroot environment setup complete."
echo "Executing login bash shell inside chroot..."
