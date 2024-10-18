#!/bin/bash
#
# PiLFS Build Script for LFS Version r12.0
# Builds chapters 7.7 Gettext to 8.80 - Sysvinit
# https://intestinate.com/pilfs
#
# Optional parameters below:

RPI_MODEL=4                    # Which Raspberry Pi model are you building for - this selects the right GCC CPU patch.
                                # Put 64 to build for aarch64.
PARALLEL_JOBS=4                 # Number of parallel make jobs, 1 for RPi1 and 4 for RPi2 and up recommended.
LOCAL_TIMEZONE=America/Chicago    # Use this timezone from /usr/share/zoneinfo/ to set /etc/localtime. See "8.5.2 Configuring Glibc".
GROFF_PAPER_SIZE=Letter             # Use this default paper size for Groff. See "8.61 Groff".
INSTALL_OPTIONAL_DOCS=1         # Install optional documentation when given a choice?
INSTALL_ALL_LOCALES=0           # Install all glibc locales? By default only en_US.ISO-8859-1 and en_US.UTF-8 are installed.

# End of optional parameters

set -o nounset
set -o errexit

function timer {
    if [[ $# -eq 0 ]]; then
        echo $(date '+%s')
    else
        local stime=$1
        etime=$(date '+%s')
        if [[ -z "$stime" ]]; then stime=$etime; fi
        dt=$((etime - stime))
        ds=$((dt % 60))
        dm=$(((dt / 60) % 60))
        dh=$((dt / 3600))
        printf '%02d:%02d:%02d' $dh $dm $ds
    fi
}

echo -e "\nThis is your last chance to quit before we start building... continue?"
echo "(Note that if anything goes wrong during the build, the script will abort mission)"
select yn in "Yes" "No"; do
    case $yn in
        Yes) break;;
        No) exit;;
    esac
done

total_time=$(timer)

echo "# 8.39. Expat-2.5.0"
tar -Jxf expat-2.5.0.tar.xz
cd expat-2.5.0
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.5.0
make -j $PARALLEL_JOBS
make install
if [[ $INSTALL_OPTIONAL_DOCS = 1 ]] ; then
    install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.5.0
fi
cd /sources
rm -rf expat-2.5.0

echo "# 8.40. Inetutils-2.4"
tar -Jxf inetutils-2.4.tar.xz
cd inetutils-2.4
./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers
make -j $PARALLEL_JOBS
make install
mv -v /usr/{,s}bin/ifconfig
cd /sources
rm -rf inetutils-2.4

echo "# 8.41. Less-643"
tar -zxf less-643.tar.gz
cd less-643
./configure --prefix=/usr --sysconfdir=/etc
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf less-643

echo "# 8.42. Perl-5.38.0"
tar -Jxf perl-5.38.0.tar.xz
cd perl-5.38.0
export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des                                         \
             -Dprefix=/usr                                \
             -Dvendorprefix=/usr                          \
             -Dprivlib=/usr/lib/perl5/5.38/core_perl      \
             -Darchlib=/usr/lib/perl5/5.38/core_perl      \
             -Dsitelib=/usr/lib/perl5/5.38/site_perl      \
             -Dsitearch=/usr/lib/perl5/5.38/site_perl     \
             -Dvendorlib=/usr/lib/perl5/5.38/vendor_perl  \
             -Dvendorarch=/usr/lib/perl5/5.38/vendor_perl \
             -Dman1dir=/usr/share/man/man1                \
             -Dman3dir=/usr/share/man/man3                \
             -Dpager="/usr/bin/less -isR"                 \
             -Duseshrplib                                 \
             -Dusethreads
make -j $PARALLEL_JOBS
make install
unset BUILD_ZLIB BUILD_BZIP2
cd /sources
rm -rf perl-5.38.0

echo "# 8.43. XML::Parser-2.46"
tar -zxf XML-Parser-2.46.tar.gz
cd XML-Parser-2.46
perl Makefile.PL
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf XML-Parser-2.46

echo "# 8.44. Intltool-0.51.0"
tar -zxf intltool-0.51.0.tar.gz
cd intltool-0.51.0
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make -j $PARALLEL_JOBS
make install
if [[ $INSTALL_OPTIONAL_DOCS = 1 ]] ; then
    install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
fi
cd /sources
rm -rf intltool-0.51.0

echo "# 8.45. Autoconf-2.71"
tar -Jxf autoconf-2.71.tar.xz
cd autoconf-2.71
sed -e 's/SECONDS|/&SHLVL|/'               \
    -e '/BASH_ARGV=/a\        /^SHLVL=/ d' \
    -i.orig tests/local.at
./configure --prefix=/usr
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf autoconf-2.71

echo "# 8.46. Automake-1.16.5"
tar -Jxf automake-1.16.5.tar.xz
cd automake-1.16.5
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.5
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf automake-1.16.5

echo "# 8.47. OpenSSL-3.1.2"
tar -zxf openssl-3.1.2.tar.gz
cd openssl-3.1.2
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
make -j $PARALLEL_JOBS
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.1.2
if [[ $INSTALL_OPTIONAL_DOCS = 1 ]] ; then
    cp -vfr doc/* /usr/share/doc/openssl-3.1.2
fi
cd /sources
rm -rf openssl-3.1.2

echo "# 8.48. kmod-30"
tar -Jxf kmod-30.tar.xz
cd kmod-30
./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --with-openssl         \
            --with-xz              \
            --with-zstd            \
            --with-zlib
make -j $PARALLEL_JOBS
make install
for target in depmod insmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /usr/sbin/$target
done
ln -sfv kmod /usr/bin/lsmod
cd /sources
rm -rf kmod-30

echo "8.49. Libelf from Elfutils-0.189"
tar -jxf elfutils-0.189.tar.bz2
cd elfutils-0.189
./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy
make -j $PARALLEL_JOBS
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a
cd /sources
rm -rf elfutils-0.189

echo "# 8.50. libffi-3.4.4"
tar -zxf libffi-3.4.4.tar.gz
cd libffi-3.4.4
./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native
make -j $PARALLEL_JOBS
make install 
cd /sources
rm -rf libffi-3.4.4

echo "# 8.51. Python-3.11.4"
tar -Jxf Python-3.11.4.tar.xz
cd Python-3.11.4
./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --with-system-ffi    \
            --enable-optimizations
make -j $PARALLEL_JOBS
make install 
cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF
if [[ $INSTALL_OPTIONAL_DOCS = 1 ]] ; then
    install -v -dm755 /usr/share/doc/python-3.11.4/html
    tar --strip-components=1 --no-same-owner --no-same-permissions -C /usr/share/doc/python-3.11.4/html -jxf ../python-3.11.4-docs-html.tar.bz2
fi
cd /sources
rm -rf Python-3.11.4

echo "# 8.52. Flit-Core-3.9.0"
tar -zxf flit_core-3.9.0.tar.gz
cd flit_core-3.9.0
pip3 wheel -w dist --no-build-isolation --no-deps $PWD
pip3 install --no-index --no-user --find-links dist flit_core
cd /sources
rm -rf flit_core-3.9.0

echo "# 8.53. Wheel-0.41.1"
tar -zxf wheel-0.41.1.tar.gz
cd wheel-0.41.1
pip3 wheel -w dist --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links=dist wheel
cd /sources
rm -rf wheel-0.41.1

echo "# 8.54. Ninja-1.11.1"
tar -zxf ninja-1.11.1.tar.gz
cd ninja-1.11.1
sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc
python3 configure.py --bootstrap
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion /usr/share/zsh/site-functions/_ninja
cd /sources
rm -rf ninja-1.11.1

echo "# 8.55. Meson-1.2.1"
tar -zxf meson-1.2.1.tar.gz
cd meson-1.2.1
pip3 wheel -w dist --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson
cd /sources
rm -rf meson-1.2.1

echo "# 8.56. Coreutils-9.3"
tar -Jxf coreutils-9.3.tar.xz
cd coreutils-9.3
patch -Np1 -i ../coreutils-9.3-i18n-1.patch
autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime
make -j $PARALLEL_JOBS
make install
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
cd /sources
rm -rf coreutils-9.3

echo "# 8.57. Check-0.15.2"
tar -zxf check-0.15.2.tar.gz
cd check-0.15.2
./configure --prefix=/usr --disable-static
make -j $PARALLEL_JOBS
make docdir=/usr/share/doc/check-0.15.2 install
cd /sources
rm -rf check-0.15.2

echo "# 8.58. Diffutils-3.10"
tar -Jxf diffutils-3.10.tar.xz
cd diffutils-3.10
./configure --prefix=/usr
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf diffutils-3.10

echo "# 8.59. Gawk-5.2.2"
tar -Jxf gawk-5.2.2.tar.xz
cd gawk-5.2.2
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make -j $PARALLEL_JOBS
make LN='ln -f' install
ln -sv gawk.1 /usr/share/man/man1/awk.1
if [[ $INSTALL_OPTIONAL_DOCS = 1 ]] ; then
    mkdir -pv /usr/share/doc/gawk-5.2.2
    cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.2.2
fi
cd /sources
rm -rf gawk-5.2.2

echo "# 8.60. Findutils-4.9.0"
tar -Jxf findutils-4.9.0.tar.xz
cd findutils-4.9.0
if [[ "$RPI_MODEL" == "64" ]] ; then
    ./configure --prefix=/usr --localstatedir=/var/lib/locate
else
    TIME_T_32_BIT_OK=yes ./configure --prefix=/usr --localstatedir=/var/lib/locate
fi
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf findutils-4.9.0

echo "# 8.61. Groff-1.23.0"
tar -zxf groff-1.23.0.tar.gz
cd groff-1.23.0
PAGE=$GROFF_PAPER_SIZE ./configure --prefix=/usr
make -j 1
make install
cd /sources
rm -rf groff-1.23.0

# 8.62. GRUB-2.06
# We don't use GRUB on ARM

echo "# 8.63. Gzip-1.12"
tar -Jxf gzip-1.12.tar.xz
cd gzip-1.12
./configure --prefix=/usr
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf gzip-1.12

echo "# 8.64. IPRoute2-6.4.0"
tar -Jxf iproute2-6.4.0.tar.xz
cd iproute2-6.4.0
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
make -j $PARALLEL_JOBS NETNS_RUN_DIR=/run/netns
make SBINDIR=/usr/sbin install
if [[ $INSTALL_OPTIONAL_DOCS = 1 ]] ; then
    mkdir -pv             /usr/share/doc/iproute2-6.4.0
    cp -v COPYING README* /usr/share/doc/iproute2-6.4.0
fi
cd /sources
rm -rf iproute2-6.4.0

echo "# 8.65. Kbd-2.6.1"
tar -Jxf kbd-2.6.1.tar.xz
cd kbd-2.6.1
patch -Np1 -i ../kbd-2.6.1-backspace-1.patch
sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make -j $PARALLEL_JOBS
make install
if [[ $INSTALL_OPTIONAL_DOCS = 1 ]] ; then
    cp -R -v docs/doc -T /usr/share/doc/kbd-2.6.1
fi
cd /sources
rm -rf kbd-2.6.1

echo "# 8.66. Libpipeline-1.5.7"
tar -zxf libpipeline-1.5.7.tar.gz
cd libpipeline-1.5.7
./configure --prefix=/usr
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf libpipeline-1.5.7

echo "# 8.67. Make-4.4.1"
tar -zxf make-4.4.1.tar.gz
cd make-4.4.1
./configure --prefix=/usr
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf make-4.4.1

echo "# 8.68. Patch-2.7.6"
tar -Jxf patch-2.7.6.tar.xz
cd patch-2.7.6
./configure --prefix=/usr
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf patch-2.7.6

echo "# 8.69. Tar-1.35"
tar -Jxf tar-1.35.tar.xz
cd tar-1.35
FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr
make -j $PARALLEL_JOBS
make install
if [[ $INSTALL_OPTIONAL_DOCS = 1 ]] ; then
    make -C doc install-html docdir=/usr/share/doc/tar-1.35
fi
cd /sources
rm -rf tar-1.35

echo "# 8.70. Texinfo-7.0.3"
tar -Jxf texinfo-7.0.3.tar.xz
cd texinfo-7.0.3
./configure --prefix=/usr
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf texinfo-7.0.3

echo "# 8.71. Vim-9.0.1677"
tar -zxf vim-9.0.1677.tar.gz
cd vim-9.0.1677
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr
make -j $PARALLEL_JOBS
make install
ln -sv vim /usr/bin/vi
for L in /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done
ln -sv ../vim/vim90/doc /usr/share/doc/vim-9.0.1677
cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1 

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF
cd /sources
rm -rf vim-9.0.1677

echo "# 8.72. MarkupSafe-2.1.3"
tar -zxf MarkupSafe-2.1.3.tar.gz
cd MarkupSafe-2.1.3
pip3 wheel -w dist --no-build-isolation --no-deps $PWD
pip3 install --no-index --no-user --find-links dist Markupsafe
cd /sources
rm -rf MarkupSafe-2.1.3

echo "# 8.73. Jinja2-3.1.2"
tar -zxf Jinja2-3.1.2.tar.gz
cd Jinja2-3.1.2
pip3 wheel -w dist --no-build-isolation --no-deps $PWD
pip3 install --no-index --no-user --find-links dist Jinja2
cd /sources
rm -rf Jinja2-3.1.2

echo "# 8.74. Udev from Systemd-254"
tar -zxf systemd-254.tar.gz
cd systemd-254
sed -i -e 's/GROUP="render"/GROUP="video"/' \
       -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in
sed '/systemd-sysctl/s/^/#/' -i rules.d/99-systemd.rules.in
mkdir -p build
cd build
meson setup \
      --prefix=/usr                 \
      --buildtype=release           \
      -Dmode=release                \
      -Ddev-kvm-mode=0660           \
      -Dlink-udev-shared=false      \
      ..
ninja udevadm systemd-hwdb \
      $(grep -o -E "^build (src/libudev|src/udev|rules.d|hwdb.d)[^:]*" \
        build.ninja | awk '{ print $2 }')                              \
      $(realpath libudev.so --relative-to .)
rm rules.d/90-vconsole.rules
install -vm755 -d {/usr/lib,/etc}/udev/{hwdb,rules}.d
install -vm755 -d /usr/{lib,share}/pkgconfig
install -vm755 udevadm                     /usr/bin/
install -vm755 systemd-hwdb                /usr/bin/udev-hwdb
ln      -svfn  ../bin/udevadm              /usr/sbin/udevd
cp      -av    libudev.so{,*[0-9]}         /usr/lib/
install -vm644 ../src/libudev/libudev.h    /usr/include/
install -vm644 src/libudev/*.pc            /usr/lib/pkgconfig/
install -vm644 src/udev/*.pc               /usr/share/pkgconfig/
install -vm644 ../src/udev/udev.conf       /etc/udev/
install -vm644 rules.d/* ../rules.d/{*.rules,README} /usr/lib/udev/rules.d/
install -vm644 hwdb.d/*  ../hwdb.d/{*.hwdb,README}   /usr/lib/udev/hwdb.d/
install -vm755 $(find src/udev -type f | grep -F -v ".") /usr/lib/udev
tar -Jxf ../../udev-lfs-20230818.tar.xz
make -f udev-lfs-20230818/Makefile.lfs install
tar -Jxf ../../systemd-man-pages-254.tar.xz                           \
    --no-same-owner --strip-components=1                              \
    -C /usr/share/man --wildcards '*/udev*' '*/libudev*'              \
                                  '*/systemd-'{hwdb,udevd.service}.8
sed 's/systemd\(\\\?-\)/udev\1/' /usr/share/man/man8/systemd-hwdb.8   \
                               > /usr/share/man/man8/udev-hwdb.8
sed 's|lib.*udevd|sbin/udevd|'                                        \
    /usr/share/man/man8/systemd-udevd.service.8                       \
  > /usr/share/man/man8/udevd.8
rm  /usr/share/man/man8/systemd-*.8
udev-hwdb update
cd /sources
rm -rf systemd-254

echo "# 8.75. Man-DB-2.11.2"
tar -Jxf man-db-2.11.2.tar.xz
cd man-db-2.11.2
./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.11.2 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap             \
            --with-systemdtmpfilesdir=            \
            --with-systemdsystemunitdir=
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf man-db-2.11.2

echo "# 8.76. Procps-ng-4.0.3"
tar -Jxf procps-ng-4.0.3.tar.xz
cd procps-ng-4.0.3
./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.3 \
            --disable-static                        \
            --disable-kill
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf procps-ng-4.0.3

echo "# 8.78. Util-linux-2.39.1"
tar -Jxf util-linux-2.39.1.tar.xz
cd util-linux-2.39.1
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --bindir=/usr/bin    \
            --libdir=/usr/lib    \
            --runstatedir=/run   \
            --sbindir=/usr/sbin  \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            --without-systemd    \
            --without-systemdsystemunitdir \
            --docdir=/usr/share/doc/util-linux-2.39.1
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf util-linux-2.39.1

echo "# 8.78. E2fsprogs-1.47.0"
tar -zxf e2fsprogs-1.47.0.tar.gz
cd e2fsprogs-1.47.0
mkdir -v build
cd build
../configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
make -j $PARALLEL_JOBS
make install
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
if [[ $INSTALL_OPTIONAL_DOCS = 1 ]] ; then
    gunzip -v /usr/share/info/libext2fs.info.gz
    install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
    makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
    install -v -m644 doc/com_err.info /usr/share/info
    install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
fi
cd /sources
rm -rf e2fsprogs-1.47.0

echo "# 8.79. Sysklogd-1.5.1"
tar -zxf sysklogd-1.5.1.tar.gz
cd sysklogd-1.5.1
sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
sed -i 's/union wait/int/' syslogd.c
make -j $PARALLEL_JOBS
make BINDIR=/sbin install
cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF
cd /sources
rm -rf sysklogd-1.5.1

echo "# 8.80. Sysvinit-3.07"
tar -Jxf sysvinit-3.07.tar.xz
cd sysvinit-3.07
patch -Np1 -i ../sysvinit-3.07-consolidated-1.patch
make -j $PARALLEL_JOBS
make install
cd /sources
rm -rf sysvinit-3.07

echo -e "--------------------------------------------------------------------"
echo -e "\nYou made it! Now there are just a few things left to take care of..."
printf 'Total script time: %s\n' $(timer $total_time)
echo -e "\nYou have not set a root password yet. Go ahead, I'll wait here.\n"
passwd root

echo -e "\nNow about the firmware..."
echo "You probably want to copy the supplied Broadcom libraries to /opt/vc?"
select yn in "Yes" "No"; do
    case $yn in
        Yes) tar -zxf master.tar.gz
             cp -rv /sources/firmware-master/hardfp/opt/vc /opt
             echo "/opt/vc/lib" >> /etc/ld.so.conf.d/broadcom.conf
             ldconfig
             if [[ "$RPI_MODEL" == "4" || "$RPI_MODEL" == "64" ]] ; then
                 tar -zxf v.2024.01.05-2712.tar.gz
                 cd rpi-eeprom-v.2024.01.05-2712
                 cp -v rpi-eeprom-update-default /etc/default/rpi-eeprom-update
                 cp -v rpi-eeprom-config rpi-eeprom-update rpi-eeprom-digest /opt/vc/bin
                 mkdir -pv /lib/firmware/raspberrypi
                 cp -rv firmware /lib/firmware/raspberrypi/bootloader
                 cd /sources
                 rm -rf rpi-eeprom-v.2024.01.05-2712
             fi
             break
             ;;
        No) break;;
    esac
done

echo -e "\nIf you're not going to compile your own kernel you probably want to copy the kernel modules from the firmware package to /lib/modules?"
select yn in "Yes" "No"; do
    case $yn in
        Yes) cp -rv /sources/firmware-master/modules /lib; break;;
        No) break;;
    esac
done

echo -e "\nLast question, if you want I can mount the boot partition and overwrite the kernel and bootloader with the one you downloaded?"
select yn in "Yes" "No"; do
    case $yn in
        Yes) mount /dev/mmcblk0p1 /boot && cp -rv /sources/firmware-master/boot / && umount /boot; break;;
        No) break;;
    esac
done

echo -e "\nThere, all done! Now continue reading from \"8.81. About Debugging Symbols\" to make your system bootable."
echo "And don't forget to check out https://intestinate.com/pilfs/beyond.html when you're done with your build!"
