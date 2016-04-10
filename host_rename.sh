#! bash
# host_rename.sh - Rename host
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

new_name=$1
old_name=$(hostname)

usage() {
    echo "usage: $0 <new_name>"
    exit 1
}

[ "$1" ] || usage

checkfail() {
    if [ $1 -gt 0 ]; then
        echo $2
        exit 1
    fi
    return
}

sed --version
checkfail $? "Couldn't execute sed"

for file in \
    /etc/hostname \
    /etc/hosts \
    /etc/ssh/ssh_host_rsa_key.pub \
    /etc/ssh/ssh_host_dsa_key.pub \
    /etc/ssh/ssh_host_ed25519_key.pub \
    /etc/ssh/ssh_host_ecdsa_key.pub;
do
    if [ -f $file ]; then
        sed -i.old -e "s:$old_name:$new_name:g" $file
        checkfail $? "Patching failed: $file"
    fi
done

# Recreate the self-signed certificate created by the ssl-cert package using the hostname currently configured on your computer
make-ssl-cert generate-default-snakeoil --force-overwrite

echo "You need to restart your system"

