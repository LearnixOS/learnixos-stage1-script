#!/bin/sh 
#get sources
export LFS=/lfs
mkdir -v $LFS
cp ./* $LFS -R
mkdir -v $LFS/sources 
chmod -v a+wt $LFS/sources
wget https://linuxfromscratch.org/~thomas/multilib-m32/wget-list-sysv
wget --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources

# make base dirs
mkdir -pv $LFS/etc $LFS/var $LFS/usr/bin $LFS/usr/lib $LFS/usr/sbin
for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done
mkdir -pv $LFS/lib64
mkdir -pv $LFS/usr/lib32
ln -sv usr/lib32 $LFS/lib32
mkdir -pv $LFS/tools
echo "root"
su -c "groupadd lfs; useradd -s /bin/bash -g lfs -m -k /dev/null lfs"
echo "root"
su -c "passwd lfs"
echo "root"
su -c "LFS=lfs; chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}"
echo "root"
su -c "LFS=lfs; chown -v lfs $LFS/lib64"
echo "root"
su -c "LFS=lfs; chown -v lfs $LFS/lib32"

#lfs user environment
echo "run env.sh"
echo "root"
su -c "cp env.sh /home/lfs/env.sh -v"
su -c "cp cross.sh /home/lfs/cross.sh -v"
su -c "cp chrootprep.sh /home/lfs/chrootprep.sh -v"
su -c "cp chroot.sh /home/lfs/chroot.sh -v"
echo "lfs"
su - lfs 
