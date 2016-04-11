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

llvm_src=/usr/local/src/llvm
llvm_build=~/build/llvm/build
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
        exit 1
    fi
    return
}

if [ "$install" = "true" ]; then
    sudo apt-get install python2.7 -y
    checkfail $? "Install python2.7 failed"

    sudo apt-get install python3.5 -y
    checkfail $? "Install python3.5 failed"

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
        sudo svn co http://llvm.org/svn/llvm-project/llvm/trunk $llvm_src
        checkfail $? "llvm sync failed"

        cd $llvm_src/tools
        checkfail $? "$llvm_src/tools directory not found"

        sudo svn co http://llvm.org/svn/llvm-project/cfe/trunk clang
        checkfail $? "clang sync failed"

        cd $llvm_src/tools/clang/tools
        checkfail $? "Directory not found $llvm_src/tools/clang/tools"

        sudo svn co http://llvm.org/svn/llvm-project/clang-tools-extra/trunk extra
        checkfail $? "clang-tools-extra sync failed"

        cd $llvm_src/projects
        checkfail $? "$llvm_src/projects directory not found"

        sudo svn co http://llvm.org/svn/llvm-project/libcxx/trunk libcxx
        checkfail $? "libcxx sync failed"

        sudo svn co http://llvm.org/svn/llvm-project/libcxxabi/trunk libcxxabi
        checkfail $? "libcxxabi sync failed"

        sudo svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt
        checkfail $? "compiler-rt sync failed"
    else
        cd $llvm_src
        sudo svn update
        checkfail $? "llvm sync failed"

        cd $llvm_src/tools/clang
        checkfail $? "$llvm_src/tools/clang directory not found"

        sudo svn update
        checkfail $? "clang sync failed"

        cd $llvm_src/tools/clang/tools/extra
        checkfail $? "Directory not found $llvm_src/tools/clang/tools/extra"

        sudo svn update
        checkfail $? "clang-tools-extra sync failed"

        cd $llvm_src/projects/libcxx
        checkfail $? "$llvm_src/projects/libcxx directory not found"

        sudo svn update
        checkfail $? "libcxx sync failed"

        cd $llvm_src/projects/libcxxabi
        checkfail $? "$llvm_src/projects/libcxxabi directory not found"

        sudo svn update
        checkfail $? "libcxxabi sync failed"

        cd $llvm_src/projects/compiler-rt
        checkfail $? "$llvm_src/projects/compiler_rt directory not found"

        sudo svn update
        checkfail $? "compiler-rt sync failed"
    fi
fi

rm -r $llvm_build
mkdir -p $llvm_build
checkfail $? "Build directory creation failed"

cd $llvm_build
checkfail $? "Unable to cd $llvm_build"

cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release $llvm_src
checkfail $? "cmake failed"

make -j 4
checkfail $? "\"make\" failed"

sudo make install
checkfail $? "\"sudo make install\" failed"

cd $ret_dir

