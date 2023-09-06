#! bash
# build_gcc.sh - A script for building gnu gcc compiler tools
#
# Copyright (c) 2016 Elisha Kendagor kosistudio@live.com
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

gcc_src=/usr/local/src/gcc
gcc_build=~/build/gcc
ret_dir=$PWD
install=false
sync=false
ld_conf_src=/etc/ld.so.conf.d/x86_64-linux-gnu.conf
prefix_override=false

while [ $# -gt 0 ]; do
    case $1 in
        -i | --install)
            install=true
            sync=true
            ;;
        -s | --sync)
            sync=true
            ;;
        -p | --prefix)
            prefix_override=true
            ;;
    esac
    shift
done

checkfail() {
    if [ $1 -gt 0 ]; then
        echo $2
        exit 1
    fi
    return
}

if [ "$install" = "true" ]; then
    bison --version
    if [ $? -gt 0 ]; then
        sudo apt install bison -y
        checkfail $? "Install svn failed"
    fi

    perl --version
    if [ $? -gt 0 ]; then
        sudo apt install perl -y
        checkfail $? "Install perl failed"
    fi

    make --version
    if [ $? -gt 0 ]; then
        sudo apt install make -y
        checkfail $? "Install make failed"
    fi

    sudo apt install binutils -y
    checkfail $? "Install binutils failed"

    bzip2 --version
    if [ $? -gt 0 ]; then
        sudo apt install bzip2 -y
        checkfail $? "Install bzip2 failed"
    fi

    gzip --version
    if [ $? -gt 0 ]; then
        sudo apt install gzip -y
        checkfail $? "Install gzip failed"
    fi

    tar --version
    if [ $? -gt 0 ]; then
        sudo apt install tar -y
        checkfail $? "Install tar failed"
    fi

    gawk --version
    if [ $? -gt 0 ]; then
        sudo apt install gawk -y
        checkfail $? "Install gawk failed"
    fi

    gettext --version
    if [ $? -gt 0 ]; then
        sudo apt install gettext -y
        checkfail $? "Install gettext failed"
    fi

    sudo apt install libc6-dev -y
    checkfail $? "Install libc6-dev failed"

    sudo apt install libgmp-dev -y
    checkfail $? "Install libgmp-dev failed"

    sudo apt install libmpfr-dev -y
    checkfail $? "Install libmpfr-dev failed"

    sudo apt install libmpc-dev -y
    checkfail $? "Install libmpc-dev failed"

    sudo apt install libisl-dev -y
    checkfail $? "Install libisl-dev failed"

    flex --version
    if [ $? -gt 0 ]; then
        sudo apt install flex -y
        checkfail $? "Install flex failed"
    fi
fi

if [ "$sync" = "true" ]; then
    ls -d $gcc_src
    if [ $? -gt 0 ]; then
        sudo git clone https://gcc.gnu.org/git/gcc.git $gcc_src
        checkfail $? "git clone failed"
    else
        cd $gcc_src
        sudo git pull
        checkfail $? "git pull failed"
    fi
fi

ls -d $gcc_src
checkfail $? "gcc source not found: $gcc_src"

if [ -f $gcc_build ]; then
    sudo rm -r $gcc_build
    checkfail $? "Failed to delete $gcc_build"
fi
mkdir -p $gcc_build
checkfail $? "Could not create $gcc_build"

cd $gcc_build
checkfail $? "Could not cd $gcc_build"

if [ "$prefix_override" = "true" ]; then
    new_prefix="--prefix=/usr/bin"
fi

# $gcc_src/configure $new_prefix \
#     --enable-languages=c,c++ \
#     --enable-shared \
#     --enable-host-shared \
#     --with-gmp \
#     --with-mpfr \
#     --with-mpc \
#     --with-isl \
#     --enable-multilib \
#     --disable-werror \
#     --disable-bootstrap

$gcc_src/configure $new_prefix \
    --enable-languages=c,c++ \
    --enable-shared \
    --enable-host-shared \
    --with-gmp \
    --with-mpfr \
    --with-mpc \
    --with-isl \
    --disable-werror \
    --disable-bootstrap \
    --disable-multilib


checkfail $? "\'configure\' failed"

# make -j $(nproc) bootstrap-lean
make -j $(nproc)
checkfail $? "\'make\' failed"

sudo make install
checkfail $? "\'make install\' failed"

# grep --regexp="^# Multiarch support$" $ld_conf_src
# checkfail $? "ldconfig cfg file doesn\'t have the expected first line"

# grep --regexp="^/usr/local/lib64$" $ld_conf_src
# if [ $? -gt 0 ]; then
#     sudo sed -i "/^# Multiarch support$/a/usr/local/lib64" $ld_conf_src
# fi

sudo ldconfig
checkfail $? "\'ldconfig\' failed"

sudo mv /usr/local/bin/gcc /usr/local/bin/gcc-dev
sudo mv /usr/local/bin/g++ /usr/local/bin/g++-dev
sudo mv /usr/local/bin/c++ /usr/local/bin/c++-dev
sudo mv /usr/local/bin/cpp /usr/local/bin/cpp-dev

echo -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
echo --- build complete. Optional step:
echo     sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 40 --slave /usr/bin/c++ c++ /usr/bin/g++ --slave /usr/bin/cpp cpp /usr/bin/gcc-cpp
echo     sudo update-alternatives --install /usr/bin/cc cc /usr/local/bin/gcc-dev 60 --slave /usr/bin/c++ c++ /usr/local/bin/g++-dev --slave /usr/bin/cpp cpp /usr/local/bin/cpp-dev
echo -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
echo Typical output after build in case you missed it:
echo ----------------------------------------------------------------------
echo Libraries have been installed in:
echo   /usr/local/lib/../lib64
echo
echo If you ever happen to want to link against installed libraries
echo in a given directory, LIBDIR, you must either use libtool, and
echo specify the full pathname of the library, or use the `-LLIBDIR'
echo flag during linking and do at least one of the following:
echo   - add LIBDIR to the `LD_LIBRARY_PATH' environment variable
echo      during execution
echo   - add LIBDIR to the `LD_RUN_PATH' environment variable
echo     during linking
echo   - use the `-Wl,-rpath -Wl,LIBDIR' linker flag
echo   - have your system administrator add LIBDIR to `/etc/ld.so.conf'
echo
echo See any operating system documentation about shared libraries for
echo more information, such as the ld(1) and ld.so(8) manual pages.
echo ----------------------------------------------------------------------


cd $ret_dir

