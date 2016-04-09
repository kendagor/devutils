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

while [ $# -gt 0 ]; do
    case $1 in
        -i | --install)
            install=true
            sync=true
            ;;
        -s | --sync)
            sync=true
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
    svn --version
    if [ $? -gt 0 ]; then
        sudo apt-get install subversion -y
        checkfail $? "Install svn failed"
    fi

    make --version
    if [ $? -gt 0 ]; then
        sudo apt-get install make -y
        checkfail $? "Install make failed"
    fi

    sudo apt-get install binutils -y
    checkfail $? "Install binutils failed"

    bzip2 --version
    if [ $? -gt 0 ]; then
        sudo apt-get install bzip2 -y
        checkfail $? "Install bzip2 failed"
    fi

    gzip --version
    if [ $? -gt 0 ]; then
        sudo apt-get install gzip -y
        checkfail $? "Install gzip failed"
    fi

    tar --version
    if [ $? -gt 0 ]; then
        sudo apt-get install tar -y
        checkfail $? "Install tar failed"
    fi

    gawk --version
    if [ $? -gt 0 ]; then
        sudo apt-get install gawk -y
        checkfail $? "Install gawk failed"
    fi

    sudo apt-get install libc6-dev -y
    checkfail $? "Install libc6-dev failed"

    sudo apt-get install libgmp-dev -y
    checkfail $? "Install libgmp-dev failed"

    sudo apt-get install libmpfr-dev -y
    checkfail $? "Install libmpfr-dev failed"

    sudo apt-get install libmpc-dev -y
    checkfail $? "Install libmpc-dev failed"

    sudo apt-get install libisl-dev -y
    checkfail $? "Install libisl-dev failed"

    flex --version
    if [ $? -gt 0 ]; then
        sudo apt-get install flex -y
        checkfail $? "Install flex failed"
    fi
fi

if [ "$sync" = "true" ]; then
    ls -d $gcc_src
    if [ $? -gt 0 ]; then
        sudo svn checkout svn://gcc.gnu.org/svn/gcc/trunk $gcc_src
        checkfail $? "sudo svn checkout failed"
    else
        sudo svn update $gcc_src
        checkfail $? "sudo svn update failed"
    fi
fi

ls -d $gcc_src
checkfail $? "gcc source not found: $gcc_src"

rm -r $gcc_build
mkdir -p $gcc_build
checkfail $? "Could not create $gcc_build"

cd $gcc_build
checkfail $? "Could not cd $gcc_build"

$gcc_src/configure \
    --enable-languages=c,c++ \
    --with-gmp \
    --with-mpfr \
    --with-mpc \
    --with-isl \
    --disable-werror \
    --disable-multilib \
    --disable-bootstrap

checkfail $? "\'configure\' failed"

# make -j 4 bootstrap-lean
make -j 4
checkfail $? "\'make\' failed"

sudo make install
checkfail $? "\'make install\' failed"

grep --regexp="^# Multiarch support$" $ld_conf_src
checkfail $? "ldconfig cfg file doesn\'t have the expected first line"

grep --regexp="^/usr/local/lib64$" $ld_conf_src
if [ $? -gt 0 ]; then
    sudo sed -i "/^# Multiarch support$/a/usr/local/lib64" $ld_conf_src
fi

sudo ldconfig
checkfail $? "\'ldconfig\' failed"

cd $ret_dir

