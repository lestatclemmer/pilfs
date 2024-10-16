echo "export $LFS=/mnt/lfs" >> .profile
$LFS=/mnt/lfs
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
cd $LFS/sources
wget https://intestinate.com/pilfs/scripts/wget-list-sysv --no-check-certificate
wget --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources --no-check-certificate
