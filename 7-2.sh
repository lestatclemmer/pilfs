chown --from lfs -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools,sources}
case $(uname -m) in
  x86_64) chown --from lfs -R root:root $LFS/lib64 ;;
esac