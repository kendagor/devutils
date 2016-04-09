#!bash

# prep_host.sh - A script for common mundane tasks preping an ubuntu dev box
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

prep_src=/usr/local/src/devutils/linux
ret_dir=$PWD
copy_rc_files=false
prefer_clang=false
build_cmake=false
build_openssl=false
build_git=false
fullprep=false;

while [ $# -gt 0 ]; do
    case $1 in
        --full)
            copy_rc_files=false
            prefer_clang=true
            build_cmake=true
            build_openssl=true
            build_git=true
            ;;
        --rc)
            copy_rc_files=false
            ;;
        --clang)
            prefer_clang=true
            ;;
        --build)
            build_cmake=true
            build_openssl=true
            build_git=true
            ;;
        --cmake)
            build_cmake=true
            ;;
        --openssl)
            build_openssl=true
            ;;
        --git)
            build_git=true
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

cd ~
checkfail $? "Cannot cd ~"

if [ "$copy_rc_files" = "true" ]; then
    cp $prep_src/.bashrc .
    checkfail $? "Could not copy .bashrc"

    cp $prep_src/.bash_aliases .
    checkfail $? "Could not copy .bash_aliases"

    cp $prep_src/.gdbinit .
    checkfail $? "Could not copy .gdbinit"

    cp $prep_src/.inputrc .
    checkfail $? "Could not copy .inputrc"

    cp $prep_src/.nanorc .
    checkfail $? "Could not copy .nanorc"

    cp $prep_src/.vimrc .
    checkfail $? "Could not copy .vimrc"
fi

which sshd
if [ $? -gt 0 ]; then
    sudo apt-get install openssh-server -y
    checkfail $? "Could not install openssh-server"
fi

which ssh
if [ $? -gt 0 ]; then
    sudo ufw allow ssh
    checkfail $? "ufw configure failed"
fi

sudo ufw allow netbios-ns
checkfail $? "ufw configure failed"

sudo ufw allow netbios-dgm
checkfail $? "ufw configure failed"

sudo ufw allow netbios-ssn
checkfail $? "ufw configure failed"

sudo ufw default deny
checkfail $? "ufw configure failed"

sudo ufw enable
checkfail $? "ufw configure failed"

vim --version
if [ $? -gt 0 ]; then
    sudo apt-get install vim -y
    checkfail $? "Could not install vim"
fi

winbindd --version
if [ $? -gt 0 ]; then
    sudo apt-get install winbind libnss-winbind -y
    checkfail $? "Could not install winbind, libnss-winbind"
fi

source-highlight --version
if [ $? -gt 0 ]; then
    sudo apt-get install source-highlight -y
    checkfail $? "Could not install source-highlight"
fi

htop --version
if [ $? -gt 0 ]; then
    sudo apt-get install htop -y
    checkfail $? "Could not install htop"
fi

pkg-config --version
if [ $? -gt 0 ]; then
    sudo apt-get install pkg-config -y
    checkfail $? "Could not install pkg-config"
fi

automake --version
if [ $? -gt 0 ]; then
    sudo apt-get install automake -y
    checkfail $? "Could not install automake"
fi

autoconf --version
if [ $? -gt 0 ]; then
    sudo apt-get install autoconf -y
    checkfail $? "Could not install autoconf"
fi

nodejs --version
if [ $? -gt 0 ]; then
    # Node.js v5.x:
    sudo curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
    checkfail $? "Could not launch nodejs apt script"

    sudo apt-get install nodejs -y
    checkfail $? "Could not install nodejs"
fi

if [ "$prefer_clang" = "false" ]; then
    # gcc-5, g++-5:
    gcc-5 --version
    if [ $? -gt 0 ]; then
        sudo apt-get install gcc-5 g++-5 -y
        checkfail $? "Could not install gcc-5, g++-5"
    fi
fi

# gdb:
gdb --version
if [ $? -gt 0 ]; then
    sudo apt-get install gdb -y
    checkfail $? "gdb install failed"

    sudo apt-get install gdb64 -y
    checkfail $? "gdb64 install failed"
fi

if [ "$prefer_clang" = "true" ]; then
    clang-3.9 --version
    if [ $? -gt 0 ]; then
        # LLVM: clang, clang++
        echo deb http://llvm.org/apt/wily/ llvm-toolchain-wily main | sudo tee /etc/apt/sources.list.d/llvm-toolchain.list
        checkfail $? "Could not create /etc/apt/sources.list.d/llvm-toolchain.list"

        wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|sudo apt-key add -
        checkfail $? "Could not install llvm-toolchain apt key"

        sudo apt-get update
        checkfail $? "Failed apt-get update"

        sudo apt-get install clang-3.9 lldb-3.9 -y --force-yes
        checkfail $? "Could not install clang-3.9, lldb-3.9"

        gcc-5 --version
        if [ $? = 0 ]; then
            path_gcc5=/usr/bin/gcc-5
            $path_gcc5 --version
            if [ $? -gt 0 ]; then
                path_gcc5=/usr/local/bin/gcc-5
            fi
            $path_gcc5 --version
            if [ $? = 0 ]; then
                sudo update-alternatives --install /usr/bin/gcc  gcc /usr/bin/gcc-5 10 --slave /usr/bin/g++-5 g++ /usr/bin/g++-5
                checkfail $? "update-alternatives gcc gcc-5 failed"
            fi
        fi

        sudo update-alternatives --install /usr/bin/gcc  gcc /usr/bin/clang-3.9 20 --slave /usr/bin/g++ g++ /usr/bin/clang++-3.9
        checkfail $? "update-alternatives gcc clang-3.9 failed"

        # Remove the "--slave ..." command extension above to set individually:
        #sudo update-alternatives --install /usr/bin/g++  g++ /usr/bin/g++-5 10
        #checkfail $? "update-alternatives g++ g++-5 failed"

        #sudo update-alternatives --install /usr/bin/g++  g++ /usr/bin/clang++-3.9 20
        #checkfail $? "update-alternatives g++ clang++-3.9 failed"
    fi
fi

if [ "$build_cmake" = "true" ]; then
    sh $prep_src/build_cmake.sh
    checkfail $? "Build cmake failed"
fi

if [ "$build_openssl" = "true" ]; then
    sh $prep_src/build_openssl.sh
    checkfail $? "Build openssl failed"
fi

if [ "$build_git" = "true" ]; then
    sh $prep_src/build_git.sh
    checkfail $? "Build git failed"
fi

cd $ret_dir

