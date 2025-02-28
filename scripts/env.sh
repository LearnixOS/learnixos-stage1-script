#!/bin/sh

# Setup the user environment profile for bash login
cat > ~/.bash_profile << "EOF"
# Ensure a clean environment and execute bash
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

# Setup bashrc for runtime shell configuration
cat > ~/.bashrc << "EOF"
# Setting umask to allow files to be created with 755 permissions
umask 022

# Defining LFS environment variables
LFS=/lfs
LC_ALL=POSIX
LFS_TGT=x86_64-lfs-linux-gnu
LFS_TGT32=i686-lfs-linux-gnu
LFS_TGTX32=x86_64-lfs-linux-gnux32

# Update the PATH with /bin and /usr/bin
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi

# Adding the tools' bin directory to the PATH
PATH=$LFS/tools/bin:$PATH

# Configuration site for package configuration
CONFIG_SITE=$LFS/usr/share/config.site

# Export all necessary environment variables for the build process
export LFS LC_ALL LFS_TGT LFS_TGT32 LFS_TGTX32 PATH CONFIG_SITE
EOF

# Additional configuration for Make with parallel jobs based on available cores
cat >> ~/.bashrc << "EOF"
# Set the MAKEFLAGS to optimize for the number of CPU cores available
export MAKEFLAGS=-j$(nproc)
EOF

# Inform that cross.sh will be executed next
echo "Cross-compilation setup complete, running cross.sh now..."

# Source the updated profile to make changes effective
source ~/.bash_profile

