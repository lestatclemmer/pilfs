## prep
```
passwd
date MMDDhhmmYYYY 101609302024
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/version-check.sh
bash version-check.sh
```

## 2.4
cfdisk /dev/mmcblk0 -> fill end free space -> write

```reboot```

## 2.5
```
mkfs.ext4 -m 1 -L MyLFS /dev/mmcblk0p3
vi /etc/fstab
#add below line and uncomment swapfile
/dev/mmcblk0p3  /mnt/lfs ext4   defaults      1     1
```

## 2.7
```
echo "export LFS=/mnt/lfs" >> .profile
export LFS=/mnt/lfs
mkdir -pv $LFS
mount -v -t ext4 /dev/mmcblk0p3 $LFS
dd if=/dev/zero of=/swapfile bs=1M count=512
mkswap /swapfile
swapon -v /swapfile
```

## 3.1
```
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
cd $LFS/sources
wget https://intestinate.com/pilfs/scripts/wget-list-sysv
wget --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/package-list-creator.sh
bash package-list-creator
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/package-list-checker.sh
bash package-list-checker | grep no
```
will likely have to do the below
```
wget https://github.com/libexpat/libexpat/releases/tag/R_2_5_0/expat-2.5.0.tar.xz
bash package-list-checker | grep no
```

prep build scripts, important to do before you switch to the lfs user
adding lfs permissions to the sources dir would technically make it possible to do these things as
the lfs user, but I'm unsure if this would mess with anything else...
edit ch5 and ch7-build.sh for RPi model, America/Chicago timezone, and Letter paper size
```chmod +x ch5-build.sh ch7-build.sh```

## 4.2
```
cd ~
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/4-2.sh
bash 4-2.sh
```

## 4.3
```
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/4-3.sh
bash 4-3.sh
```

## 4.4
```
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/4-4.sh
bash 4-4.sh
```

## build ch5 & ch6
```
cd $LFS/sources
./ch5-build.sh
```
#now wait.....

## 7.2
```
su -
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/7-2.sh
bash 7-2.sh
```

## 7.3
```
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/7-3.sh
bash 7-3.sh
```

## prep 7.5 & 7.6
```
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/7-5.sh
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/7-6.sh
mv 7-5.sh 7-6.sh $LFS
```

## 7.4
```
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/7-4.sh
bash 7-4.sh
```

## run 7.5 & 7.6
```bash 7-5.sh; bash 7-6.sh```

## build ch7 & ch8
```
cd sources
./ch7-build.sh
```
#now wait some more...

## final steps of the build script
choose your root password

decide whether you want to copy the supplied Braodcom libraries to /opt/vc
From what I could tell, these libraries are used for hardware acceleration for things like 
rendering graphics and video decoding. Since IMPISH doens't need anything like that, I chose not to copy these libraries.
I'm not sure if this was the correct decision...

decide whether you want to copy the supplied kernel modules to /lib/modules
I assumed that IMPISH didn't want to compile our own kernel, so I chose to copy these modules. I'm not sure if this was the correct decision...
HOWEVER, unpacking the firmware that contains these modules is only done automatically when you respond 'yes' to the previous question.
If you chose 'no' for the previous question as I did, choose 'no' for now and run the commands shown in the next section of this README.

decide if you want the boot partition mounted and the kernel & bootloader overwritten with the one you downloaded
I assumed that IMPISH does want this done, but I'm still not sure if this was the correct decision.
HOWEVER, this also relies on unpacking the firmware, which if you're following my steps, wasn't automatically done.
In this case, choose 'no' for now and run the commands shown in the section after the next of this README.

to run if you want to copy the supplied kernel modules but don't want to copy the supplied Broadcom libraries
assuming you're in /sources/:
```
tar -zxf master.tar.gz
cp -rv /sources/firmware-master/modules /lib
```

to run if you want the boot partition mounted and the kernel & bootloader overwritten with the one you downloaded but you don't want to copy the supplied Broadcom libraries
```
cd ~
mount /dev/mmcblk0p1 /boot
cp -rv /sources/firmware-master/boot /
umount /boot
```

## 8.85
```rm -rf /tmp/{*,.*}```  
this didn't actually do anything for me as the only thing in my tmp folder was another folder...not sure if that's cos I rebooted after running ch7-build.sh or what...
```
find /usr/lib /usr/libexec -name \*.la -delete
find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf
```
I ran this as well as the below line because I knew that the pilfs guide instructed to change the "gnu" bit to "gnueabihf", unsure if this still accomplishes what it should
```
find /usr -depth -name $(uname -m)-lfs-linux-gnueabihf\* | xargs rm -rf
userdel -r tester
```
this resulted in "userdel: tester mail spool (/var/mail/tester) not found, don't know what that's all about but I suspect this is fine

## 9.2
```
cd sources
tar -Jxf lfs-bootscripts-20230728.tar.xz
cd lfs-bootscripts-20230728
make install
```

## 9.4
```bash /usr/lib/udev/init-net-rules.sh```

## note:
at this point William told me that I should strip the system of all debug symbols, so I decided to follow the steps outlined in 7.13 to create a backup of the
LFS system
I had to resize the partitions because the 2nd partition, PiLFs, was too small to hold my backup of the 3rd partition, MyLFS. Needless to say this was a fairly annoying learning experience that I don't want to write about here

## creating an LFS backup
```
exit
mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
umount $LFS/dev/pts
umount $LFS/{sys,proc,run,dev}
cd $LFS
tar -cJpf $HOME/lfs-ch9-4-snapshot-12.2.tar.xz .
```
renamed the file to more accurately describe what this backup is

## returning to 8.84 to strip the system of all debug symbols
```wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/8-84.sh```
```mv 8-84.sh $LFS```
I then ran 7-3.sh (without the first mkdir line) and 7-4.sh to enter the chroot environment
```bash 8-84.sh```
### it should be noted that I had to replace certain packages in the 8-84.sh script to match the packages downloaded for PiLFS, since these packages don't necessarily match the packages given in the LFS guide

## 9.5.1
I'm skipping this because I want to set up DHCP later, which is outlined in the BLFS guide

## 9.5.2
```
cat > /etc/resolv.conf << "EOF"
`# Begin /etc/resolv.conf`

search umn.edu
nameserver 8.8.8.8
nameserver 8.8.4.4

`# End /etc/resolv.conf`
EOF
```
I'm really not sure if I should have used "search umn.edu" as the domain, but I guess we will see how it goes

## 9.5.3
```echo "impish" > /etc/hostname```
chose impish as the hostname

## 9.5.4
```
cat > /etc/hosts << "EOF"
# Begin /etc/hosts

127.0.0.1 localhost.localdomain localhost
127.0.1.1 impish.localdomain impish
::1       localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters

# End /etc/hosts
EOF
```
this is what was in the pilfs /etc/hosts file but with "impish" replacing "pilfs"

## 9.6.2
```
exit
wget https://raw.githubusercontent.com/lestatclemmer/pilfs/refs/heads/main/9-6-2.sh
mv 9-6-2.sh $LFS
bash 7-4.sh
bash 9-6-2.sh
```

## Rest of 9.6
I adjusted the contents of ```/etc/sysconfig/rc.site``` to suit my desires for the IMPISH-LFS build  
The important changes being:  
-UTC=1  
-HEADLESS=yes  
-VERBOSE_FSCK=yes #unsure if needed, chose cos PiLFS system had set to yes



## notes:
consider adding the "create a backup" process outlined in 7.13 to the ch7-build.sh script, might not be possible to do without leaving the chroot environment

9.3 has info on device and module handling, such as what to do if certain errors occur

9.4 has info on network devices and other devices, might have to run the first bash script again if you add any new NICs, unsure tho

9.5.4 likely needs to be revisited in the future if I'm having issue connecting to the internet
