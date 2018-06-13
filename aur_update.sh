#!/bin/bash

# aur_update.sh
# checks AUR packages updates using AurJson (https://wiki.archlinux.org/index.php/AurJson)
# version: 0.6.1
# usage: aur_update.sh [PACKAGES...]
#
# Remi Salmon, 2015

IFS=$'\n'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
BLUE=$(tput setaf 4)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)

if [[ $# == 0 ]]; then
	pkglist=$(pacman -Qm)
else
	#args=$(for arg in $@; do echo $arg; done | sort)
	#pkglist=$(pacman -Qm $args)

	pkglist=$(pacman -Qm $@)
fi

jsonurl="https://aur.archlinux.org/rpc.php?type=multiinfo"

for pkg in $pkglist; do
	pkgname=$(echo $pkg | cut -d ' ' -f 1)

	jsonurl=$jsonurl"&arg[]="$pkgname
done

echo ${BOLD}${BLUE}"::"${NORMAL}${BOLD}" Downloading JSON data..."${NORMAL}

jsondata=$(wget -q -O - $jsonurl | sed -e 's/.*\[//' -e 's/\].*//')
#echo $jsondata > json.data
#exit
#jsondata=$(cat json.data)

if [[ ${#jsondata} == 0 ]]; then
	echo ${BOLD}${RED}"ERROR:"${NORMAL}" no connection to aur.archlinux.org"
	exit
fi

rm *.tar.gz 2>/dev/null

for pkg in $pkglist; do
	pkgname=$(echo $pkg | cut -d ' ' -f 1)
	
	if [[ "$jsondata" == *"$pkgname"* ]]; then

		pkgversion=$(echo $pkg | cut -d ' ' -f 2)

		pkgjsondata=$(echo $jsondata | sed -e "s/.*\"$pkgname\",//" -e 's/}.*//')

		pkgnewversion=$(echo $pkgjsondata | sed -e 's/.*\"Version\":\"//' -e 's/\".*//')

		pkgoutdated=$(echo $pkgjsondata | sed -e 's/.*\"OutOfDate\"://' -e 's/,.*//')

		#~if [ ${#pkgname} -gt 4 ]; then
			#~pkggit=${pkgname:${#pkgname}-4}
		#~else
			#~pkggit=''
		#fi
		pkggit=${pkgname:${#pkgname}-4}

		if [[ "$pkgnewversion" != "$pkgversion" ]] && [[ "$pkggit" != '-git' ]]; then
			echo " "${BOLD}$pkgname" "${GREEN}$pkgversion${NORMAL}" new version "${BOLD}${GREEN}$pkgnewversion${NORMAL}" available..."

			pkgurl="https://aur.archlinux.org"$(echo $pkgjsondata | sed -e 's/.*URLPath\":\"//' -e 's/\".*//' -e 's/\\//g')

			wget -q $pkgurl
		elif [[ "$pkgoutdated" != '0' ]]; then
			echo " "${BOLD}$pkgname${NORMAL}${RED}" flagged out-of-date!"${NORMAL}
		elif [[ "$pkggit" == '-git' ]]; then
			echo " "${BOLD}$pkgname${NORMAL}" update with makepkg"
		#else
			#echo " "${BOLD}$pkgname${NORMAL}" version "${BOLD}${GREEN}$pkgversion${NORMAL}" up to date"
		fi
	else
		echo " "${BOLD}$pkgname${NORMAL}" not in AUR..."
	fi
done
