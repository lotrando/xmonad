#!/bin/sh

# Realist's .xinitrc file

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap

sysresources=/etc/X11/xinit/Xresources
sysmodmap=/etc/X11/xinit/Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then

    xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then

    xrdb -merge "$userresources"

fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -n "`/etc/X11/chooser.sh`" ]; then
 command="`/etc/X11/chooser.sh`"
else
 failsafe="yes"
fi

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?* ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

gentoo-pipewire-launcher &
xrandr --output DVI-D-1 --mode 1920x1080 --rate 71.91 --output HDMI-1 --mode 1920x1080 --rate 71.91 --left-of DVI-D-1
xsetroot -solid black -cursor_name left_ptr &
picom &
nitrogen --restore
setxkbmap us,cz -option grp:shifts_toggle &
numlockx on &
urxvtd -q &
trayer-srg --iconspacing 5 --tint 0x031321 --edge top --align right --widthtype request --padding 5 --SetDockType true --transparent true --SetPartialStrut true --expand true --monitor 1 --alpha 55 --height 22 &
exec xmonad
