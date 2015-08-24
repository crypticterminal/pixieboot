#!/usr/bin/env bash

DISTRO_NAME=ubuntu-14.04.3-desktop-live

config(){
	echo "label $DISTRO_NAME"
	echo "  menu label Ubuntu 14.04 Desktop^Live"
	echo "  kernel     $BASE_SYSTEMS_rel/$DISTRO_NAME/casper/vmlinuz.efi"
	echo "  append     boot=casper netboot=nfs nfsroot=$NFSHOST:$BASE_SYSTEMS/$DISTRO_NAME/ initrd=$BASE_SYSTEMS_rel/$DISTRO_NAME/casper/initrd.lz"
}

installation(){
	iso=$(mktemp)
	dir=$(mktemp -d)
	wget ${MIRROR}-releases/14.04.3/ubuntu-14.04.3-desktop-amd64.iso -O $iso
	mount $iso $dir
	cp -r $dir $BASE_SYSTEMS/$DISTRO_NAME
	umount $dir
	rmdir $dir
	rm $iso
}

if [[ ! -d $BASE_SYSTEMS/$DISTRO_NAME && -n "$1" && "x$1" == "xinstall" ]]; then
	installation
fi

if [[ -n "$1" && "x$1" == "xconfig" ]]; then
	config
fi