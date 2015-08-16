#!/usr/bin/env bash

function die(){
	warn $*
	exit 1
}
function warn(){
	echo $* >&2
}

export NFSPREFIX=$(dirname $(readlink -f $0))
export BASE_SYSTEMS_rel=systems
export MIRROR=http://mirrors.kernel.org/ubuntu

[[ -f config.sh ]] && source config.sh

[[ -z "$NFSHOST" ]] && die variable NFSHOST not defined

export BASE_SYSTEMS=$NFSPREFIX/$BASE_SYSTEMS_rel
export CONFIG=$NFSPREFIX/pxelinux.cfg/default

export RECIPES=./recipes/

# dnsmasq configuration
sed "s%NFSHOST%$NFSHOST%;s%NFSPREFIX%$NFSPREFIX%" $NFSPREFIX/config/dnsmasq >> /etc/dnsmasq.d/pxe
sed -i "s%#conf-dir=/etc/dnsmasq.d%conf-dir=/etc/dnsmasq.d%" /etc/dnsmasq.conf
service dnsmasq restart

# grab other files
cp /usr/lib/syslinux/pxelinux.0 /usr/lib/syslinux/menu.c32 $NFSPREFIX

mkdir -p $BASE_SYSTEMS
mkdir -p $(dirname $CONFIG)
# adapt file-settings
cat > $CONFIG <<-END
# DO NOT EDIT THIS FILE
# 
# this is autogenerated.
#
# look into $NFSPREFIX/setup/ and create there a new entry

END

# install all setups
for recipe in $RECIPES/*.sh; do
	if [[ -x $recipe ]]; then
		$recipe install &
		$recipe config >> $CONFIG
	fi
done
wait
