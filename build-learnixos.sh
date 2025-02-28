#!/bin/bash
# LearnixOS-stage1 frontend

# Configuration
export LFS=/mnt/lfs # ajust as needed

# Ensure script is run as root
# if [ "$(id -u)" -ne 0 ]; then
#     echo "This script must be run as root"
#     exit 1
# fi

# Function to handle errors
handle_error() {
    echo "Error: $1 failed at line $2"
    exit 1
}

trap 'handle_error $BASH_COMMAND $LINENO' ERR

# Stage 1: Preparation
echo "=== Starting LearnixOS Build ==="
echo "Running prep.sh..."
./scripts/prep.sh

# Stage 2: Build as lfs user
echo "=== Switching to lfs user ==="
su - lfs << EOF
set -e
echo "Running env.sh..."
./env.sh
echo "Running cross.sh..."
./cross.sh
cp -r files $LFS
cp -r scripts/* $LFS
EOF

# Stage 3: In-Chroot Operations
echo "=== Entering Chroot Environment ==="
chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin \
    /bin/bash --login << 'CHROOT_EOF'
set -e
echo "Running chroot.sh..."
./chroot.sh
echo "Running afterchroot.sh..."
bash /afterchroot.sh
echo "Running lfssystem.sh..."
bash /lfssystem.sh
echo "Running finishlfssystem.sh..."
bash /finishlfssystem.sh
CHROOT_EOF

echo "=== LearnixOS Build Completed Successfully ==="
