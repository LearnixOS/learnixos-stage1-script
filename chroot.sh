#/bin/sh 

mkdir -pv /boot
mkdir -pv /home
mkdir -pv /mnt
mkdir -pv /opt
mkdir -pv /srv
mkdir -pv /etc/opt
mkdir -pv /etc/sysconfig
mkdir -pv /lib/firmware
mkdir -pv /media/floppy
mkdir -pv /media/cdrom
mkdir -pv /usr/include
mkdir -pv /usr/local/include
mkdir -pv /usr/src
mkdir -pv /usr/local/src
mkdir -pv /usr/lib/locale
mkdir -pv /usr/local/bin
mkdir -pv /usr/local/lib
mkdir -pv /usr/local/sbin
mkdir -pv /usr/local/share/color
mkdir -pv /usr/local/share/dict
mkdir -pv /usr/local/share/doc
mkdir -pv /usr/local/share/info
mkdir -pv /usr/local/share/locale
mkdir -pv /usr/local/share/man
mkdir -pv /usr/share/color
mkdir -pv /usr/share/dict
mkdir -pv /usr/share/doc
mkdir -pv /usr/share/info
mkdir -pv /usr/share/locale
mkdir -pv /usr/share/man
mkdir -pv /usr/share/misc
mkdir -pv /usr/share/terminfo
mkdir -pv /usr/share/zoneinfo
mkdir -pv /usr/local/share/misc
mkdir -pv /usr/local/share/terminfo
mkdir -pv /usr/local/share/zoneinfo}
mkdir -pv /usr/local/share/man/man1
mkdir -pv /usr/local/share/man/man2
mkdir -pv /usr/local/share/man/man3
mkdir -pv /usr/local/share/man/man4
mkdir -pv /usr/local/share/man/man5
mkdir -pv /usr/local/share/man/man6
mkdir -pv /usr/local/share/man/man7
mkdir -pv /usr/local/share/man/man8
mkdir -pv /usr/share/man/man1
mkdir -pv /usr/share/man/man2
mkdir -pv /usr/share/man/man3
mkdir -pv /usr/share/man/man4
mkdir -pv /usr/share/man/man5
mkdir -pv /usr/share/man/man6
mkdir -pv /usr/share/man/man7
mkdir -pv /usr/share/man/man8
mkdir -pv /var/cache
mkdir -pv /var/local
mkdir -pv /var/log
mkdir -pv /var/mail
mkdir -pv /var/opt
mkdir -pv /var/spool
mkdir -pv /var/lib/color
mkdir -pv /var/lib/misc
mkdir -pv /var/lib/locate

ln -sfv /run /var/run
ln -sfv /run/lock /var/lock

install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp 

ln -sv /proc/self/mounts /etc/mtab 
cp /files/passwd /etc/passwd 
cp /files/group /etc/group
cp /files/hosts /etc/hosts
localedef -i C -f UTF-8 C.UTF-8 
echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
echo "tester:x:101:" >> /etc/group
install -o tester -d /home/tester 
touch /var/log/btmp
touch /var/log/lastlog
touch /var/log/faillog
touch /var/log/wtmp
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp 
echo "run /afterchroot.sh"
exec /usr/bin/bash --login 
