#!/bin/bash

# aur_install.sh
# installs .tar.gz packages from the AUR (builds in ~/Builds/)
# version: 0.6
# usage: aur_process.sh PACKAGE.tar.gz
#
# Remi Salmon, 2015

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
BLUE=$(tput setaf 4)

if [[ $# == 0 ]]; then
	echo "${BOLD}ERROR:${NORMAL} usage: # aur_install.sh pkgname.tar.gz"
	exit
fi

pkg=$1

if [[ ! -f $pkg ]]; then
	echo "${BOLD}ERROR:${NORMAL} file '"$pkg"' does not exist!"
	exit 1
fi

pkgname=$(tar -tf $pkg | head -n 1 | sed 's/\///') #package name may differ

pkggit=${pkgname:${#pkgname}-4}

#if [ $pkgname == '' ]; then
#	echo "${BOLD}ERROR:${NORMAL} pkgname == ''"
#	exit
#fi

echo "${BOLD}${BLUE}::${NORMAL}${BOLD} Processing "$pkgname"...${NORMAL}"

echo " extracting "$pkg" ..."

tar -xzf $pkg

rm $pkg
rm -rf ~/Builds/$pkgname 2>/dev/null

mv $pkgname ~/Builds/

echo " installing "$pkgname"..."

cd ~/Builds/$pkgname/

makepkg -sri

echo -n "${BOLD}${BLUE}::${NORMAL}${BOLD} Remove ~/Builds/"$pkgname"? [Y/n] ${NORMAL}"

read key

if [[ "$pkggit" != '-git' && ("$key" == 'y' || "$key" == 'Y') ]]; then
	rm -rf ~/Builds/$pkgname 2>/dev/null
fi
