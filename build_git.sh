#! bash
# Prerequisite: Build openssl first (build_openssl.sh)
# build_git.sh - A script for building git
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

git_src=/usr/src/git
build_dir=~/build
bin_dir=$build_dir/git
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
    
    for pkg in \
        zlib1g \
        zlib1g-dev \
        libcurl4-nss-dev \
        libcurl4-openssl-dev \
        libcurl4-gnutls-dev \
        libexpat1-dev;
    do
        sudo apt-get install $pkg -y
        checkfail $? "Package install failed for: $pkg"
    done
fi

if [ "$sync" = "true" ]; then
    ls -d $git_src    
    if [ $? -gt 0 ]; then
        sudo git clone https://github.com/git/git.git $git_src
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

make NO_GETTEXT=YesPlease NO_OPENSSL=YesPlease NO_TCLTK=YesPlease -I/usr/local/include prefix=/usr/local -j 4
checkfail $? "Build failed"

sudo make install NO_GETTEXT=YesPlease NO_OPENSSL=YesPlease NO_TCLTK=YesPlease -I/usr/local/include prefix=/usr/local -j 4
checkfail $? "Install failed"

cd $curr_dir

