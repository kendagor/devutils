#! bash
# NASM build script
# You may need to install these packages first:
#   autoconf
#   asciidoc
#   xmlto

nasm_src=/usr/local/src/nasm
nasm_doc=~/Documents/tech
ret_dir=$PWD
clean_depot=true

cd $nasm_src
if [ $? -gt 0 ]; then
    echo couldn\'t locate nasm src: $nasm_src
    exit 1
fi

if [ -f ./configure ]; then
    clean_depot=false
fi

if [ $clean_depot -eq true ]; then
    sh autogen.sh
    if [ $? -gt 0 ]; then
        echo \'autogen\' failed
        exit 1
    fi
fi

sh configure
if [ $? -gt 0 ]; then
    echo \'configure\' failed
    exit 1
fi

make everything -j 8
if [ $? -gt 0 ]; then
    echo \'make everything\' failed
    exit 1
fi

make install_everything
if [ $? -gt 0 ]; then
    echo \'make install everything\' failed
    exit 1
fi

cp ./doc/nasmdoc.pdf $nasm_doc

cd $ret_dir
