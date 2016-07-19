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

prep_src=~/src/devutils
ret_dir=$PWD
copy_rc_files=false
install_gcc=false
install_clang=false
prefer_clang=false
build_cmake=false
build_openssl=false
build_git=false
fullprep=false
install_tools=false
firewall_cfg=false

while [ $# -gt 0 ]; do
    case $1 in
        --firewall)
            firewall_cfg=true
            ;;
        --tools)
            install_tools=true
            ;;
        --full)
            install_tools=true
            copy_rc_files=true
            install_gcc=true
            install_clang=true
            build_cmake=true
            build_openssl=true
            build_git=true
            firewall_cfg=true
            ;;
        --rc)
            copy_rc_files=true
            ;;
        --clang)
            install_clang=true
            prefer_clang=true
            ;;
        --gcc)
            install_gcc=true
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

if [ "$copy_rc_files" = "true" ]; then
    cd ~
    checkfail $? "Cannot cd ~"

    for file in \
        .bashrc \
        .bash_aliases \
        .gdbinit \
        .inputrc \
        .nanorc \
        .vimrc;
    do
       if [ -f $file ]; then
           cp $file $file.old
           checkfail $? "Backing up $file failed"
       fi
       
       cp $prep_src/$file .
       checkfail $? "Copy file failed: $prep_src/$file"
    done
fi

if [ "$firewall_cfg" = "true" ]; then
    for ufw_s in \
        "ssh" \
        "netbios-ns" \
        "netbios-dgm" \
        "netbios-ssn" \
        "samba" \
        "in on any to ff01::1" \
        "in on any to 224.0.0.1" \
        "in on any to 224.0.0.254";
    do
        sudo ufw allow $ufw_s
        checkfail $? "ufw configure failed for: $ufw_s"
    done

    sudo ufw default deny
    checkfail $? "ufw configure failed"

    sudo ufw enable
    checkfail $? "ufw configure failed"
fi

if [ "$install_tools" = "true" ]; then
    which sshd
    if [ $? -gt 0 ]; then
        sudo apt install openssh-server -y
        checkfail $? "Could not install openssh-server"
    fi

    vim --version
    if [ $? -gt 0 ]; then
        sudo apt install vim -y
        checkfail $? "Could not install vim"
    fi

    winbindd --version
    if [ $? -gt 0 ]; then
        sudo apt install winbind libnss-winbind -y
        checkfail $? "Could not install winbind, libnss-winbind"
    fi

    source-highlight --version
    if [ $? -gt 0 ]; then
        sudo apt install source-highlight -y
        checkfail $? "Could not install source-highlight"
    fi

    htop --version
    if [ $? -gt 0 ]; then
        sudo apt install htop -y
        checkfail $? "Could not install htop"
    fi

    pkg-config --version
    if [ $? -gt 0 ]; then
        sudo apt install pkg-config -y
        checkfail $? "Could not install pkg-config"
    fi

    automake --version
    if [ $? -gt 0 ]; then
        sudo apt install automake -y
        checkfail $? "Could not install automake"
    fi

    autoconf --version
    if [ $? -gt 0 ]; then
        sudo apt install autoconf -y
        checkfail $? "Could not install autoconf"
    fi

    nodejs --version
    if [ $? -gt 0 ]; then
        # Node.js v5.x:
        sudo curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
        checkfail $? "Could not launch nodejs apt script"

        sudo apt install nodejs -y
        checkfail $? "Could not install nodejs"
    fi

    # gdb:
    gdb --version
    if [ $? -gt 0 ]; then
        sudo apt install gdb -y
        checkfail $? "gdb install failed"

        #sudo apt install gdb64 -y
        #checkfail $? "gdb64 install failed"
    fi
fi

if [ "$install_gcc" = "true" ]; then
    # gcc-5, g++-5:
    gcc-5 --version
    if [ $? -gt 0 ]; then
        sudo apt install gcc-5 g++-5 -y
        checkfail $? "Could not install gcc-5, g++-5"
    fi
fi

if [ "$install_clang" = "true" ]; then
    clang-3.9 --version
    if [ $? -gt 0 ]; then
        # LLVM: clang, clang++
        echo deb http://llvm.org/apt/xenial/ llvm-toolchain-xenial main | sudo tee /etc/apt/sources.list.d/llvm-toolchain.list
        checkfail $? "Could not create /etc/apt/sources.list.d/llvm-toolchain.list"

        wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|sudo apt-key add -
        checkfail $? "Could not install llvm-toolchain apt key"

        sudo apt update
        checkfail $? "Failed apt update"

        sudo apt install clang-3.9 lldb-3.9 -y --force-yes
        checkfail $? "Could not install clang-3.9, lldb-3.9"

        if [ "$prefer_clang" = "true" ]; then
            gcc --version
            if [ $? = 0 ]; then
                path_gcc=/usr/bin
                $path_gcc/gcc --version
                if [ $? -gt 0 ]; then
                    path_gcc=/usr/local/bin
                fi
                $path_gcc/gcc --version
                if [ $? = 0 ]; then
                   sudo update-alternatives --install /usr/bin/cc cc $path_gcc/gcc 10 --slave /usr/bin/c++ c++ $path_gcc/g++
                   checkfail $? "update-alternatives cc -> gcc failed"
                fi
            fi
        fi

        sudo update-alternatives --install /usr/bin/cc cc /usr/bin/clang-3.9 20 --slave /usr/bin/c++ c++ /usr/bin/clang++-3.9
        checkfail $? "update-alternatives cc -> clang-3.9 failed"

        # Remove the "--slave ..." command extension above to set individually:
        #sudo update-alternatives --install /usr/bin/g++  g++ /usr/bin/g++-5 10
        #checkfail $? "update-alternatives g++ g++-5 failed"

        #sudo update-alternatives --install /usr/bin/g++  g++ /usr/bin/clang++-3.9 20
        #checkfail $? "update-alternatives g++ clang++-3.9 failed"
    fi
fi

if [ "$build_cmake" = "true" ]; then
    sh $prep_src/build_cmake.sh --install
    checkfail $? "Build cmake failed"
fi

if [ "$build_openssl" = "true" ]; then
    sh $prep_src/build_openssl.sh --install
    checkfail $? "Build openssl failed"
fi

if [ "$build_git" = "true" ]; then
    sh $prep_src/build_git.sh --install
    checkfail $? "Build git failed"
fi

cd $ret_dir

