dd if=/dev/zero of=/swapfile bs=1M count=512
mkswap /swapfile
swapon -v /swapfile
mkfs.ext4 -m 1 -L MyLFS /dev/mmcblk0p3
vi /etc/fstab