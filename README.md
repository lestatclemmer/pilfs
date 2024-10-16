#prep
passwd
date MMDDhhmmYYYY 101609302024
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/version-check.sh --no-check-certificate
bash version-check.sh

#2.4
cfdisk /dev/mmcblk0 -> fill end free space -> write
reboot

#2.5
mkfs.ext4 -m 1 -L MyLFS /dev/mmcblk0p3
vi /etc/fstab
#add below line and uncomment swapfile
/dev/mmcblk0p3  /mnt/lfs ext4   defaults      1     1

#2.7
echo "export $LFS=/mnt/lfs" >> .profile
export LFS=/mnt/lfs
mkdir -pv $LFS
mount -v -t ext4 /dev/mmcblk0p3 $LFS
dd if=/dev/zero of=/swapfile bs=1M count=512
mkswap /swapfile
swapon -v /swapfile

#3.1
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
cd $LFS/sources
wget https://intestinate.com/pilfs/scripts/wget-list-sysv --no-check-certificate
wget --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources --no-check-certificate
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/package-list-creator.sh --no-check-certificate
bash package-list-creator
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/package-list-checker.sh --no-check-certificate
bash package-list-checker | tee checked.txt
vi checked.txt
#will likely have to do the below
wget https://github.com/libexpat/libexpat/releases/tag/R_2_5_0/expat-2.5.0.tar.xz --no-check-certificate
bash package-list-checker | tee checked.txt
vi checked.txt

#4.2
cd ~
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/4-2.sh --no-check-certificate
bash 4-2.sh

#4.3
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/4-3.sh --no-check-certificate
bash 4-3.sh

!!!IMPORTANT?
edit ch5 and ch7-build.sh for RPi model, America/Chicago timezone, and Letter paper size
chmod +x ch5-build.sh ch7-build.sh

#4.4
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/4-4.sh --no-check-certificate
bash 4-4.sh
