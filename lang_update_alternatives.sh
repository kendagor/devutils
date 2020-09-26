#! bash

checkfail() {
    if [ $1 -gt 0 ]; then
        echo $2
        exit 1
    fi
    return
}

if [ -f /usr/local/bin/gcc ]; then
    sudo mv /usr/local/bin/gcc /usr/local/bin/gcc-dev
    checkfail $? "Rename /usr/local/bin/gcc failed"
fi

if [ -f /usr/local/bin/g++ ]; then
    sudo mv /usr/local/bin/g++ /usr/local/bin/g++-dev
    checkfail $? "Rename /usr/local/bin/g++ failed"
fi

if [ -f /usr/local/bin/clang ]; then
    sudo mv /usr/local/bin/clang /usr/local/bin/clang-dev
    checkfail $? "Rename /usr/local/bin/clang failed"
fi

# clang++ is typically a link to clang:
if [ -f /usr/local/bin/clang++ ]; then
    sudo unlink /usr/local/bin/clang++
    checkfail $? "Unlink /usr/local/bin/clang++ failed"

    sudo ln -s /usr/local/bin/clang-dev /usr/local/bin/clang++-dev
    checkfail $? "Link /usr/local/bin/clang++ failed"
fi

update_alternatives() {
    if [ -f $3 ]; then
        sudo update-alternatives --install /usr/bin/$1 $2 $3 $4
        checkfail $? "Failed: sudo update-alternatives --install /usr/bin/$1 $2 $3 $4"
        return
    fi
    echo "update-alternatives skipped because '$3' doesn't exist"
}

update_alternatives /usr/bin/gcc gcc /usr/bin/gcc-9 10
update_alternatives /usr/bin/gcc gcc /usr/bin/gcc-10 20
update_alternatives /usr/bin/gcc gcc /usr/local/bin/gcc-dev 30

update_alternatives /usr/bin/g++ g++ /usr/bin/g++-9 10
update_alternatives /usr/bin/g++ g++ /usr/bin/g++-10 20
update_alternatives /usr/bin/g++ g++ /usr/local/bin/g++-dev 30

update_alternatives /usr/bin/clang clang /usr/lib/llvm-10/bin/clang 10
update_alternatives /usr/bin/clang clang /usr/local/bin/clang-dev 20

update_alternatives /usr/bin/clang++ clang++ /usr/lib/llvm-10/bin/clang++ 10
update_alternatives /usr/bin/clang++ clang++ /usr/local/bin/clang++-dev 20

update_alternatives /usr/bin/cc cc /usr/bin/clang 10
update_alternatives /usr/bin/cc cc /usr/bin/gcc 20

update_alternatives /usr/bin/c++ c++ /usr/bin/clang++ 10
update_alternatives /usr/bin/c++ c++ /usr/bin/g++ 20

