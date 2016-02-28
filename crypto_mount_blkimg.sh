#!/bin/bash

# Shell script to conveniently mount an crypted image based block device
# this is just to automate things and save a few repetitive commands all the time
# when working heavily with crypto devices

# made by oliverpelz dot gmail.com

# the parameters are <device> <imagefile on device> <unique mount name>
# e.g. /dev/sdd2 my_image.img myFirstImage123
# the uniqe name is for creating a mount dir and keeping record for the opposite script
# called XXX
if [ "$#" -lt 3 ]; then
   echo $"Usage: $(basename $0) device imagefile_on_device unique_mount_name"
   exit 1
fi

exit_on_error() {
# redirect all parameters to stderr and wxit with error
    echo "$*" >&2
    exit 1
}

DEVICE=$1
IMGFILE=$2
ID=$3

# some important constants, please no leading / here

# where to put all the temporary image disk file mount points
TEMPCRYPTOMOUNTBASEDIR=/mnt/tmpCryptoLUKS

# where to put all the decrypted luks opened disk images
CRYPTOMOUNTBASEDIR=/mnt/cryptoLUKS

if [ "$#" -lt 3 ]; then
   echo $"Usage: $(basename $0) device imagefile_on_device unique_mount_name"
   exit 1
fi

# bail out if input device does not exist
if [ ! -b "$DEVICE" ]
then
  echo "$DEVICE is NOT a block device."
fi

TMPIMGMOUNTDIR=$(mktemp -dp $TEMPCRYPTOMOUNTBASEDIR || exit_on_error "cannot create temp dir in $TEMPCRYPTOMOUNTBASEDIR")

# now mount the device to the new temporary mount point
mount $DEVICE $TMPIMGMOUNTDIR || exit_on_error "cannot mount device $DEVICE to $TMPIMGMOUNTDIR"

FREELOOPDEV=$(losetup -f)
losetup $FREELOOPDEV "$TMPIMGMOUNTDIR/$IMGFILE"

cryptsetup luksOpen $FREELOOPDEVDEV $ID

# finally mount the unencrypted mapper device
mkdir "$CRYPTOMOUNTBASEDIR/$ID" || exit_on_error "cannot create directory for mounting decrypted crypto image"
mount /dev/mapper/$ID $CRYPTOMOUNTBASEDIR/$ID

echo "decrypted and mounted crypto img to $CRYPTOMOUNTBASEDIR/$ID"
# finally success
exit 0

