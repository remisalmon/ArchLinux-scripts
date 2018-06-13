#!/bin/bash

mirrorlist_url='https://www.archlinux.org/mirrorlist/?country=US&protocol=http&ip_version=4'

wget -q -O - $mirrorlist_url >mirrorlist_tmp

sed -e 's/^#//' mirrorlist_tmp >mirrorlist_tmpbis

rm mirrorlist_tmp

rankmirrors -n 6 mirrorlist_tmpbis >mirrorlist

rm mirrorlist_tmpbis

cat mirrorlist
