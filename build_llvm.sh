#! bash
# build_llvm.sh - A script for building the llvm toolkit
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

llvm_src_dir=/usr/local/src
llvm_src=/usr/local/src/llvm-project
llvm_build=~/build/llvm
ret_dir=$PWD
install=false
sync=false
alt=false

while [ $# -gt 0 ]; do
    case $1 in
        -i | --install)
            install=true
            sync=true
            ;;
        -s | --sync)
            sync=true
            ;;
        -n | --alt)
            alt=true
            ;;
    esac
    shift
done

checkfail() {
    if [ $1 -gt 0 ]; then
        echo $2
        cd $ret_dir
        exit 1
    fi
    return
}

if [ "$install" = "true" ]; then
    sudo apt-get install python3 -y
    checkfail $? "Install python3 failed"

    make --version
    if [ $? -gt 0 ]; then
        sudo apt-get install make -y
        checkfail $? "Install make failed"
    fi

    cmake --version
    if [ $? -gt 0 ]; then
        sudo apt-get install cmake -y
        checkfail $? "Install cmake failed"
    fi

    automake --version
    if [ $? -gt 0 ]; then
        sudo apt-get install automake -y
        checkfail $? "Install automake failed"
    fi
fi

if [ "$sync" = "true" ]; then
    ls -d $llvm_src
    if [ $? -gt 0 ]; then
        cd $llvm_src_dir
        sudo git clone https://github.com/llvm/llvm-project.git
        checkfail $? "llvm sync failed"
    else
        cd $llvm_src
        sudo git pull
        checkfail $? "llvm sync failed"
    fi
fi

rm -r $llvm_build
mkdir -p $llvm_build
checkfail $? "Build directory creation failed"

cd $llvm_build
checkfail $? "Unable to cd $llvm_build"

cmake -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld;lldb" \
      -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind;openmp" \
      -G "Unix Makefiles" \
      -DCMAKE_BUILD_TYPE=Release $llvm_src/llvm
checkfail $? "cmake failed"

make -j $(nproc)
checkfail $? "\"make\" failed"

sudo make install
checkfail $? "\"sudo make install\" failed"

sudo ldconfig

sudo mv /usr/local/bin/clang /usr/local/bin/clang-dev
sudo mv /usr/local/bin/clang++ /usr/local/bin/clang++-dev

if [ "$alt" = true ]; then
    path_gcc=$(which gcc)
    if [ $? = 0 ]; then
        path_cpp=$(which g++)
        if [ $? = 0 ]; then
            sudo update-alternatives --install /usr/bin/gcc  gcc $path_gcc 10 --slave /usr/bin/g++ g++ $path_cpp
            checkfail $? "update-alternatives gcc, g++ failed. Paths: $path_gcc; $path_cpp"
        fi
    fi
    
    sudo update-alternatives --install /usr/bin/gcc  gcc /usr/local/bin/clang 20 --slave /usr/bin/g++ g++ /usr/local/bin/clang++
    checkfail $? "update-alternatives gcc clang failed"
fi

cd $ret_dir

