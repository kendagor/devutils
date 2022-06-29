#! bash
# build_cryptopp.sh - A script for building libcrypto++
#
# Copyright (c) 2017 Elisha Kendagor kosistudio@live.com
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

git_src=/usr/local/src/cryptopp
build_dir=~/build
bin_dir=$build_dir/cryptopp
curr_dir=$PWD
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
        exit 1
    fi
    return
}

if [ "$install" = "true" ]; then
    cc --version
    checkfail $? "Please install your prefered c compiler"
fi

if [ "$sync" = "true" ]; then
    ls -d $git_src    
    if [ $? -gt 0 ]; then
        sudo git clone https://github.com/weidai11/cryptocpp.git $git_src
        checkfail $? "Sync failed"
    else
        cd $git_src
        sudo git pull
        checkfail $? "Sync failed"
    fi
fi

rm -r $bin_dir
mkdir -p $build_dir
checkfail $? "Build directory creation failed"

cd $build_dir
checkfail $? "Unable to cd $build_dir"

cp --recursive --symbolic-link $git_src .
checkfail $? "Unable to copy src links to $bin_dir"

cd $bin_dir
checkfail $? "Unable to cd $bin_dir"

make -j $(nproc)
checkfail $? "Build failed"

sudo make install
checkfail $? "Install failed"

cd $curr_dir

