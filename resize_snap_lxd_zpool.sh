#! bash

# $1 : Name of the pool
# $2 : New size in GB

imgpath=/var/snap/lxd/common/lxd/disks/$1.img

# make sure zfs autoexpand is enabled (only needed once)
sudo zpool set autoexpand=on $1

sudo truncate -s $2G $imgpath

# Make zfs realize the fact that partition has been changed and make zpool
# use the new partition which is actually the same one
sudo zpool online -e $1 $imgpath $imgpath
