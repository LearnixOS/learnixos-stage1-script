#/bin/sh
set -e 
export LFS=/lfs
su --preserve-environment -c "chown --from lfs -R $(whoami):$(whoami) $LFS/usr $LFS/lib $LFS/var $LFS/etc $LFS/bin $LFS/sbin $LFS/tools"
su --preserve-environment -c "chown --from lfs -R $(whoami):$(whoami) $LFS/lib64"
su --preserve-environment -c "chown -R $(whoami):$(whoami) $LFS/lib32"

mkdir -pv $LFS/dev
mkdir -pv $LFS/proc
mkdir -pv $LFS/sys
mkdir -pv $LFS/run
su --preserve-environment -c "mount -v --bind /dev $LFS/dev; mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts; mount -vt proc proc $LFS/proc; mount -vt sysfs sysfs $LFS/sys; mount -vt tmpfs tmpfs $LFS/run"
if [ -h $LFS/dev/shm ]; then
  install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
  su --preserve-environment -c "mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm"
fi
echo "run /chroot.sh"
su --preserve-environment -c "chroot '$LFS' /usr/bin/env -i   \
    HOME=/root                  \
    TERM='$TERM'                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    MAKEFLAGS='-j$(nproc)'      \
    TESTSUITEFLAGS='-j$(nproc)' \
    bash --login"
