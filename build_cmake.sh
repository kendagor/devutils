#! bash

# build_cmake.sh - A script for building cmake
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

cmake_src=/usr/local/src/cmake
cmake_build=~/build/cmake
ret_dir=$PWD
install=false
sync=false

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
        exit $1
    fi
    return
}

if [ "$install" = "true" ]; then
    cc --version
    checkfail $? "Please install your preferred c, c++ compilers"

    sudo apt install libssl-dev -y
    checkfail $? "Failed to install libssl-dev"
fi

if [ "$sync" = "true" ]; then
    ls -d $cmake_src
    if [ $? -gt 0 ]; then
        sudo git clone https://github.com/Kitware/CMake.git $cmake_src
        checkfail $? "Clone failed"
    else
        cd $cmake_src
        sudo git pull
        checkfail $? "Sync failed"
    fi
fi

if [ -f $cmake_build ]; then
    rm -r $cmake_build
fi
mkdir -p $cmake_build
checkfail $? "Failed: mkdir $cmake_build"

cd $cmake_build
checkfail $? "Couldn\'t locate the build directory: $cmake_build"

$cmake_src/bootstrap --parallel=8
checkfail $? "bootstrap failed"

make -j $(nproc)
checkfail $? "make failed"

sudo make install
checkfail $? "make install failed"

cd $ret_dir

