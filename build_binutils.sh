#! bash
# Elisha Kendagor
# Local script for building binutils-gdb

gdb_src=/src/binutils-gdb
build_dir=~/build
build_binutils_dir=$build_dir/binutils-gdb
curr_dir=$PWD
install=false
sync=false
rename=false

while [ $# -gt 0 ]; do
    case $1 in
        -i | --install)
            install=true
            sync=true
            ;;
        -s | --sync)
            sync=true
            ;;
        -r | --rename)
            rename=true
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
    
    # sudo apt apt install gnat-12 -y
    # checkfail $? "Ada compiler gnat failed to install"
fi

if [ "$sync" = "true" ]; then
    ls -d $gdb_src    
    if [ $? -gt 0 ]; then
        git clone git://sourceware.org/git/binutils-gdb.git $gdb_src
        checkfail $? "Sync failed"
    else
        cd $gdb_src
        git pull
        checkfail $? "Sync failed"
    fi
fi

rm -rf $build_binutils_dir
mkdir -p $build_binutils_dir
checkfail $? "Build directory creation failed"

cd $build_dir
checkfail $? "Unable to cd $build_dir"

cp --recursive --symbolic-link $gdb_src .
checkfail $? "Unable to copy src links to $build_dir"

cd $build_binutils_dir
checkfail $? "Unable to cd $build_binutils_dir"

#./configure
./configure  --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib
checkfail $? "configure failed"

make -j $(nproc)
checkfail $? "make failed"

echo Installing binutils-gdb binaries. \
     Note: sometimes if you see a missing library error, \
     you can resolve the issue by running 'sudo ldconfig' \
     to update the shared library cache.

sudo make install
if [ $1 -gt 0 ]; then
    sudo ldconfig
    sudo make install
fi
checkfail $? "make install failed"

if [ "$rename" = "true" ]; then
    echo Renaming /usr/local/bin/gdb to /usr/local/bin/gdb-dev
    sudo mv /usr/local/bin/gdb /usr/local/bin/gdb-dev

    echo  Renaming ld to ld-dev
    sudo mv /usr/local/bin/ld /usr/local/bin/ld-dev

    echo Renaming /usr/local/bin/as to /usr/local/bin/as-dev 
    sudo mv /usr/local/bin/ld.gold /usr/local/bin/ld-dev.gold

    echo Renaming /usr/local/bin/ld.bfd to /usr/local/bin/ld-dev.bfd
    sudo mv /usr/local/bin/ld.bfd /usr/local/bin/ld-dev.bfd

    echo Renaming /usr/local/bin/as /usr/local/bin/as-dev
    sudo mv /usr/local/bin/as /usr/local/bin/as-dev

    echo Helpful commands to utilize renamed binaries:
    echo ---------------------------------------------------------------------------------------
    echo sudo update-alternatives --install /usr/bin/ld ld /usr/bin/x86_64-linux-gnu-ld 20 \
    --slave /usr/bin/ld.gold ld.gold /usr/bin/x86_64-linux-gnu-ld.gold \
    --slave /usr/bin/as as /usr/bin/x86_64-linux-gnu-as
    echo ---------------------------------------------------------------------------------------
    echo sudo update-alternatives --install /usr/bin/ld ld /usr/local/bin/ld-dev 40 \
    --slave /usr/bin/ld.gold ld.gold /usr/local/bin/ld-dev.gold \
    --slave /usr/bin/as as /usr/local/bin/as-dev
    echo ---------------------------------------------------------------------------------------
fi

sudo ldconfig
checkfail $? "\'ldconfig\' failed"

cd $curr_dir

