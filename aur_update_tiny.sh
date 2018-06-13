#!/bin/bash
IFS=$'\n'
l=$(pacman -Qm)
a="https://aur.archlinux.org"
u=$a"/rpc.php?type=multiinfo"
for p in $l;do
n=$(echo $p|cut -d' ' -f1)
u=$u'&arg[]='$n
done
d=$(wget -q -O - $u|sed -e's/.*\[//' -e's/\].*//')
for p in $l;do
n=$(echo $p|cut -d' ' -f1)
g=${n:${#n}-4}
v=$(echo $p|cut -d' ' -f2)
w=$(echo $d|sed -e "s/.*\"$n\",//" -e's/}.*//' -e's/.*\"Version\":\"//' -e's/\".*//')
[ "$w" != "$v" ] && [ "$g" != '-git' ] && wget -q $a$(echo $d|sed -e's/.*URLPath\":\"//' -e's/\".*//' -e's/\\//g')
done
