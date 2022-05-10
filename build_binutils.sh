#! bash
# Elisha Kendagor
# Local script for building binutils-gdb

gdb_src=/usr/local/src/binutils-gdb
build_dir=~/build
build_binutils_dir=$build_dir/binutils-gdb
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
    
    # sudo apt apt install gnat-12 -y
    # checkfail $? "Ada compiler gnat failed to install"
fi

if [ "$sync" = "true" ]; then
    ls -d $gdb_src    
    if [ $? -gt 0 ]; then
        sudo git clone git://sourceware.org/git/binutils-gdb.git $gdb_src
        checkfail $? "Sync failed"
    else
        cd $gdb_src
        sudo git pull
        checkfail $? "Sync failed"
    fi
fi

rm -r $build_binutils_dir
mkdir -p $build_binutils_dir
checkfail $? "Build directory creation failed"

cd $build_dir
checkfail $? "Unable to cd $build_dir"

cp --recursive --symbolic-link $gdb_src .
checkfail $? "Unable to copy src links to $build_dir"

cd $build_binutils_dir
checkfail $? "Unable to cd $build_binutils_dir"

./configure
checkfail $? "configure failed"

make -j 4
checkfail $? "make failed"

sudo make install
checkfail $? "make install failed"

cd $curr_dir

