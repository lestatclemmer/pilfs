cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point    type     options             dump  fsck
#                                                                order

/dev/mmcblk0p1 /boot          vfat     defaults            0     0
/dev/mmcblk0p2 /home          ext4     defaults,noatime    0     1
/dev/mmcblk0p3 /              ext4     defaults,noatime    0     2
#/swapfile     swap           swap     pri=1               0     0
proc           /proc          proc     nosuid,noexec,nodev 0     0
sysfs          /sys           sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts       devpts   gid=5,mode=620      0     0
tmpfs          /run           tmpfs    defaults            0     0
devtmpfs       /dev           devtmpfs mode=0755,nosuid    0     0
tmpfs          /dev/shm       tmpfs    nosuid,nodev        0     0

# End /etc/fstab
EOF