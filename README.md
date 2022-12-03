# Gentoo Xmonad Web Developer Desktop by Realist

## Keybinding of Xmonad
```
  -- Xmonad Restarts - (Win+Shift+r)
  -- Xmonad Quit - (Win+Shift+q)
  -- Kill the currently focused window - (Win+Shift+c)
  -- Kill all windows on current workspace - (Win+Shift+a)

  -- Rofi Drun - (Win+Shift+Enter)
  -- Rofi Powermenu - (Win+Shift+p)
  -- Rofi Apps - (Win+Shift+Backspace)

  -- Run URxvt - (Win+<Enter>)
  -- Run Firefox - (Win+Alt+f)
  -- Run Sublime - (Win+Alt+e)
  -- Run Pcmanfm - (Win+Alt+t)
  -- Run Btop - (Win+Alt+h)
  -- Run Pulsemixer (Win+Alt+m)

  -- Switch to next layout - ("M-<Tab>")
  -- Toggles noborder/full - ("M-<Space>")
  -- Toggles noborder - ("M-S-n")

  -- Shrink horiz window width - ("M-h")
  -- Expand horiz window width - ("M-l")
  -- Shrink vert window width - ("M-M1-j")
  -- Exoand vert window width - ("M-M1-k")

  -- Switch focus to next monitor - ("M-.")
  -- Switch focus to prev monitor - ("M-,")
  -- Shifts focused window to next Workspace - ("M-S-<Right>")
  -- Shifts focused window to prev Workspace - ("M-S-<Left>")

  -- Toggles my 'floats' layout - ("M-f")
  -- Push floating window back to tile - ("M-t")
  -- Push ALL floating windows to tile - ("M-S-t")

  -- Decrease window spacing - ("M-d")
  -- Increase window spacing - ("M-i")
  -- Decrease screen spacing - ("M-S-d")
  -- Increase screen spacing - ("M-S-i")

  -- Move focus to the master window - ("M-m")
  -- Move focus to the next window - ("M-j")
  -- Move focus to the prev window - ("M-k")

  -- Swap the focused window and the master window - ("M-S-m")
  -- Swap focused window with next window - ("M-S-j")
  -- Swap focused window with prev window - ("M-S-k")
  
  -- Moves focused window to master, others maintain order - ("M-<Backspace>")
  -- Rotate all windows except master and keep focus in place - ("M-S-<Tab>")

  -- Rotate all the windows in the current stack - ("M-C-<Tab>")
  -- Search prompt Google - (Win+S and g)
```

## Grub background by Realist
<img src="grub-screen.png" alt="grub" />

## Final desktop screenshot
<img src="xmonad-screen.png" alt="xmonad-screen" />

## Create install environment

### Prepare disk
```
parted -s /dev/sda mklabel gpt
```
```
parted -a optimal ${TARGET_DISK} << END
unit mib
mkpart primary fat32 1 150
name 1 UEFI
set 1 bios_grub on
mkpart primary 150 -1
name 2 ROOT
p
quit
END
```

### Create Filesystems
```
mkfs.fat -n UEFI -F32 /dev/sda1 && mkfs.f2fs -l ROOT -O extra_attr,inode_checksum,sb_checksum -f /dev/sda2
```
```
mkdir -p /mnt/gentoo && mount -t f2fs /dev/sda2 /mnt/gentoo
```
```
mkdir -p /mnt/gentoo/boot && mount /dev/sda1 /mnt/gentoo/boot
```

### Download stage3 and config portage
```
cd /mnt/gentoo
```
```
wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20221127T170156Z/stage3-amd64-openrc-20221127T170156Z.tar.xz
```
```
tar xpf stage3-amd64-openrc-20221127T170156Z.tar.xz --xattrs-include='*.*' --numeric-owner
```
```
mkdir -p /mnt/gentoo/var/db/repos/gentoo && mkdir -p /mnt/gentoo/etc/portage/repos.conf
```
```
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/
```
```
cp /etc/resolv.conf /mnt/gentoo/etc/
```
### Mounting important system FS
```
mount -t proc none /mnt/gentoo/proc && mount -t sysfs none /mnt/gentoo/sys
```
```
mount --rbind /sys /mnt/gentoo/sys && mount --make-rslave /mnt/gentoo/sys
```
```
mount --rbind /dev /mnt/gentoo/dev && mount --make-rslave /mnt/gentoo/dev
```
```
mount --rbind /run /mnt/gentoo/run && mount --make-rslave /mnt/gentoo/run
```
```
test -L /dev/shm && rm /dev/shm && mkdir /dev/shm
```
```
mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm && chmod 1777 /dev/shm
```

### Chroot to prepared system
```
chroot /mnt/gentoo /bin/bash && env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```
### Sync and config portage
```
emerge-webrsync
```
```
cd /etc/portage/
```
```
rm make.conf && rm -R package.use && rm -R package.accept_keywords && rm -R package.mask
```

### Edit file - /etc/portage/make.conf 
```
nano make.conf
```
```
# RXMD - Realist Xmonad Minimal Desktop
# make.conf file (c) 2022 -> /etc/portage/make.conf

USE="alsa dbus elogind jpeg pulseaudio pipewire png nls X"

COMMON_FLAGS="-O2 -pipe -fomit-frame-pointer"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
MAKE_OPTS="-j6"

GENTOO_MIRRORS="https://mirror.dkm.cz/gentoo/"
PORTAGE_BINHOST="http://78.45.232.18:55/xmonad"
PORTDIR="/var/db/repos/gentoo"
DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/binpkgs"
PORTAGE_NICENESS=19
PORTAGE_IONICE_COMMAND="ionice -c 3 -p \${PID}"
EMERGE_DEFAULT_OPTS="-v --ask-enter-invalid --jobs=4 --load-average=4"
FEATURES="pkgdir-index-trusted binpkg-logs buildpkg cgroup collision-protect downgrade-backup parallel-fetch sign"

ACCEPT_KEYWORDS="amd64"
ACCEPT_LICENSE="-* @FREE"
GRUB_PLATFORMS="pc efi-64"

LC_ALL=C
LC_MESSAGES=C
L10N="cs"

INPUT_DEVICES="libinput"
VIDEO_CARDS="nouveau vmware"
```
### Edit file - /etc/portage/package.accept_keywords
```
nano package.accept_keywords 
```
```
# RXMD - Realist Xmonad Minimal Desktop
# package.accept_keywords file -> /etc/portage/package.accept_keywords

# ADMIN-APP
app-admin/haskell-updater ~amd64

# APP-EDITORS
app-editors/sublime-text ~amd64
app-editors/vscode ~amd64

# DEV-PHP
dev-php/ca-bundle ~amd64
dev-php/composer ~amd64
dev-php/json-schema ~amd64
dev-php/jsonlint ~amd64
dev-php/metadata-minifier ~amd64
dev-php/phar-utils ~amd64
dev-php/php ~amd64
dev-php/psr-log ~amd64
dev-php/semver ~amd64
dev-php/spdx-licenses ~amd64
dev-php/symfony-config ~amd64
dev-php/symfony-console ~amd64
dev-php/symfony-dependency-injection ~amd64
dev-php/symfony-event-dispatcher ~amd64
dev-php/symfony-filesystem ~amd64
dev-php/symfony-finder ~amd64
dev-php/symfony-process ~amd64
dev-php/xdebug-handler ~amd64

# DEV-PYTHON
dev-python/python-lhafile ~amd64

# SYS-KERNEL
sys-kernel/zen-sources ~amd64

# APP-SHELLS
app-shells/oh-my-zsh ~amd64
app-shells/zsh-autosuggestions ~amd64
app-shells/zsh-syntax-highlighting ~amd64

# DEV-HASKELL
dev-haskell/adjunctions ~amd64
dev-haskell/aeson ~amd64
dev-haskell/alex ~amd64
dev-haskell/alsa-core ~amd64
dev-haskell/alsa-mixer ~amd64
dev-haskell/ansi-terminal ~amd64
dev-haskell/ansi-wl-pprint ~amd64
dev-haskell/appar ~amd64
dev-haskell/asn1-encoding ~amd64
dev-haskell/asn1-parse ~amd64
dev-haskell/asn1-types ~amd64
dev-haskell/assoc ~amd64
dev-haskell/async ~amd64
dev-haskell/attoparsec ~amd64
dev-haskell/auto-update ~amd64
dev-haskell/base-compat ~amd64
dev-haskell/base-compat-batteries ~amd64
dev-haskell/base-orphans ~amd64
dev-haskell/base64-bytestring ~amd64
dev-haskell/basement ~amd64
dev-haskell/bifunctors ~amd64
dev-haskell/binary ~amd64
dev-haskell/blaze-builder ~amd64
dev-haskell/blaze-html ~amd64
dev-haskell/blaze-markup ~amd64
dev-haskell/broadcast-chan ~amd64
dev-haskell/bsb-http-chunked ~amd64
dev-haskell/byte-order ~amd64
dev-haskell/byteorder ~amd64
dev-haskell/bytestring-builder ~amd64
dev-haskell/bytestring-to-vector ~amd64
dev-haskell/c2hs ~amd64
dev-haskell/cabal ~amd64
dev-haskell/cabal-doctest ~amd64
dev-haskell/call-stack ~amd64
dev-haskell/case-insensitive ~amd64
dev-haskell/cereal ~amd64
dev-haskell/colour ~amd64
dev-haskell/comonad ~amd64
dev-haskell/conduit ~amd64
dev-haskell/conduit-extra ~amd64
dev-haskell/configfile ~amd64
dev-haskell/connection ~amd64
dev-haskell/contravariant ~amd64
dev-haskell/cookie ~amd64
dev-haskell/cryptonite ~amd64
dev-haskell/data-default ~amd64
dev-haskell/data-default-class ~amd64
dev-haskell/data-default-instances-containers ~amd64
dev-haskell/data-default-instances-dlist  ~amd64
dev-haskell/data-default-instances-old-locale ~amd64
dev-haskell/data-fix ~amd64
dev-haskell/dbus ~amd64
dev-haskell/dbus-hslogger ~amd64
dev-haskell/distributive ~amd64
dev-haskell/dlist ~amd64
dev-haskell/dyre ~amd64
dev-haskell/easy-file ~amd64
dev-haskell/either ~amd64
dev-haskell/enclosed-exceptions ~amd64
dev-haskell/exceptions ~amd64
dev-haskell/executable-path ~amd64
dev-haskell/extensible-exceptions ~amd64
dev-haskell/fail ~amd64
dev-haskell/fast-logger ~amd64
dev-haskell/free ~amd64
dev-haskell/generic-deriving ~amd64
dev-haskell/ghc-paths ~amd64
dev-haskell/gi-atk ~amd64
dev-haskell/gi-cairo ~amd64
dev-haskell/gi-cairo-connector ~amd64
dev-haskell/gi-cairo-render ~amd64
dev-haskell/gi-dbusmenu ~amd64
dev-haskell/gi-dbusmenu ~amd64
dev-haskell/gi-dbusmenugtk3 ~amd64
dev-haskell/gi-gdk ~amd64
dev-haskell/gi-gdkpixbuf ~amd64
dev-haskell/gi-gdkx11 ~amd64
dev-haskell/gi-gio ~amd64
dev-haskell/gi-glib ~amd64
dev-haskell/gi-gobject ~amd64
dev-haskell/gi-gtk ~amd64
dev-haskell/gi-gtk-hs ~amd64
dev-haskell/gi-harfbuzz ~amd64
dev-haskell/gi-pango ~amd64
dev-haskell/gi-xlib ~amd64
dev-haskell/gtk-sni-tray ~amd64
dev-haskell/gtk-strut ~amd64
dev-haskell/happy ~amd64
dev-haskell/hashable ~amd64
dev-haskell/haskell-gi ~amd64
dev-haskell/haskell-gi-base ~amd64
dev-haskell/haskell-gi-overloading ~amd64
dev-haskell/haskell-lexer ~amd64
dev-haskell/hinotify ~amd64
dev-haskell/hostname ~amd64
dev-haskell/hourglass ~amd64
dev-haskell/hslogger ~amd64
dev-haskell/hstringtemplate ~amd64
dev-haskell/http-client ~amd64
dev-haskell/http-client-tls ~amd64
dev-haskell/http-conduit ~amd64
dev-haskell/http-date ~amd64
dev-haskell/http-types ~amd64
dev-haskell/http2 ~amd64
dev-haskell/hunit ~amd64
dev-haskell/indexed-traversable ~amd64
dev-haskell/indexed-traversable-instances ~amd64
dev-haskell/integer-logarithms ~amd64
dev-haskell/invariant ~amd64
dev-haskell/io-storage ~amd64
dev-haskell/iproute ~amd64
dev-haskell/iwlib ~amd64
dev-haskell/kan-extensions ~amd64
dev-haskell/language-c ~amd64
dev-haskell/lens ~amd64
dev-haskell/lifted-base ~amd64
dev-haskell/memory ~amd64
dev-haskell/mime-types ~amd64
dev-haskell/missingh ~amd64
dev-haskell/monad-control ~amd64
dev-haskell/monad-loops ~amd64
dev-haskell/mono-traversable ~amd64
dev-haskell/mtl ~amd64
dev-haskell/multimap ~amd64
dev-haskell/nats ~amd64
dev-haskell/netlink ~amd64
dev-haskell/network ~amd64
dev-haskell/network-bsd ~amd64
dev-haskell/network-byte-order ~amd64
dev-haskell/network-uri ~amd64
dev-haskell/old-locale ~amd64
dev-haskell/old-time ~amd64
dev-haskell/onetuple ~amd64
dev-haskell/optparse-applicative ~amd64
dev-haskell/parallel ~amd64
dev-haskell/parsec ~amd64
dev-haskell/parsec-numbers ~amd64
dev-haskell/pem ~amd64
dev-haskell/pretty-hex ~amd64
dev-haskell/pretty-show ~amd64
dev-haskell/primitive ~amd64
dev-haskell/primitive-unaligned ~amd64
dev-haskell/profunctors ~amd64
dev-haskell/psqueues ~amd64
dev-haskell/quickcheck ~amd64
dev-haskell/random ~amd64
dev-haskell/rate-limit ~amd64
dev-haskell/reflection ~amd64
dev-haskell/regex-base ~amd64
dev-haskell/regex-compat ~amd64
dev-haskell/regex-posix ~amd64
dev-haskell/regex-tdfa ~amd64
dev-haskell/resourcet ~amd64
dev-haskell/safe ~amd64
dev-haskell/scientific ~amd64
dev-haskell/scotty ~amd64
dev-haskell/semialign ~amd64
dev-haskell/semigroupoids ~amd64
dev-haskell/semigroups ~amd64
dev-haskell/setlocale ~amd64
dev-haskell/simple-sendfile ~amd64
dev-haskell/socks ~amd64
dev-haskell/split ~amd64
dev-haskell/splitmix ~amd64
dev-haskell/statevar ~amd64
dev-haskell/status-notifier-item ~amd64
dev-haskell/stm ~amd64
dev-haskell/streaming-commons ~amd64
dev-haskell/strict ~amd64
dev-haskell/syb ~amd64
dev-haskell/tagged ~amd64
dev-haskell/text ~amd64
dev-haskell/text-short ~amd64
dev-haskell/th-abstraction ~amd64
dev-haskell/th-compat ~amd64
dev-haskell/th-lift ~amd64
dev-haskell/these ~amd64
dev-haskell/time-compat ~amd64
dev-haskell/time-locale-compat ~amd64
dev-haskell/time-manager ~amd64
dev-haskell/time-units ~amd64
dev-haskell/timezone-olson ~amd64
dev-haskell/timezone-series ~amd64
dev-haskell/tls ~amd64
dev-haskell/transformers ~amd64
dev-haskell/transformers-base ~amd64
dev-haskell/transformers-compat ~amd64
dev-haskell/tuple ~amd64
dev-haskell/type-equality ~amd64
dev-haskell/typed-process ~amd64
dev-haskell/unix-compat ~amd64
dev-haskell/unix-time ~amd64
dev-haskell/unliftio-core ~amd64
dev-haskell/unordered-containers ~amd64
dev-haskell/utf8-string ~amd64
dev-haskell/uuid-types ~amd64
dev-haskell/vault ~amd64
dev-haskell/vector ~amd64
dev-haskell/vector-algorithms ~amd64
dev-haskell/void ~amd64
dev-haskell/wai ~amd64
dev-haskell/wai-extra ~amd64
dev-haskell/wai-logger ~amd64
dev-haskell/warp ~amd64
dev-haskell/witherable ~amd64
dev-haskell/word8 ~amd64
dev-haskell/x11 ~amd64
dev-haskell/x11-xft ~amd64
dev-haskell/x509 ~amd64
dev-haskell/x509-store ~amd64
dev-haskell/x509-system ~amd64
dev-haskell/x509-validation ~amd64
dev-haskell/xdg-basedir ~amd64
dev-haskell/xdg-desktop-entry ~amd64
dev-haskell/xml ~amd64
dev-haskell/xml-conduit ~amd64
dev-haskell/xml-helpers ~amd64
dev-haskell/xml-types ~amd64
dev-haskell/zlib ~amd64

# DEV-LANG
dev-lang/ghc ~amd64

# DEV-UTIL
dev-util/ragel ~amd64

# LXDE-BASE
lxde-base/lxappearance ~amd64
lxde-base/lxde-common ~amd64
lxde-base/lxrandr ~amd64

# NET-MISC
net-misc/youtube-viewer ~amd64

# MEDIA-VIDEO
media-video/pipewire ~amd64
media-video/wireplumber ~amd64

# X11-LIBS
x11-libs/libfm ~amd64

# X11-MISC
x11-misc/notify-osd ~amd64
x11-misc/pcmanfm ~amd64
x11-misc/xmobar ~amd64

# X11-THEMES
x11-themes/elementary-xfce-icon-theme ~amd64
x11-themes/notify-osd-icons ~amd64

# X11-WM
x11-wm/xmonad ~amd64
x11-wm/xmonad-contrib ~amd64
```
### Edit file - /etc/portage/package.use
```
nano package.use
```
```
# Realist Xmonad Minimal Desktop
# package.use file -> /etc/portage/package.use

# APP-ADMIN
app-admin/sudo -sendmail

# APP-EDITORS
app-editors/nano magic

# APP-CRYPT
app-crypt/gcr gtk

# APP-ESELECT
app-eselect/eselect-php apache2 fpm

# APP-MISC
app-misc/mc nls -slang unicode gpm sftp

# APP-TEXT
app-text/evince djvu tiff
app-text/ghostscript-gpl cups
app-text/poppler cairo
app-text/xmlto text

# DEV-DB
dev-db/mysql -perl

# DEV-LANG
dev-lang/php apache2 bcmath curl fpm gd mysql mysqli pdo soap sockets spell sqlite xmlreader xmlwriter zip

# DEV-LIBS
dev-libs/elfutils lzma zstd
dev-libs/libdbusmenu gtk3

# DEV-PYTHON
dev-python/PyQt5 -bluetooth dbus declarative gui multimedia network opengl printsupport svg widgets

# DEV-VCS
dev-vcs/git -perl

# GNOME-BASE
gnome-base/gvfs cdda http udisks nfs archive

# MEDIA-FONTS
media-fonts/terminus-font -ru-g

# MEDIA-LIBS
media-libs/audiofile flac
media-libs/gegl cairo
media-libs/flac ogg
media-libs/libsdl opengl
media-libs/libsdl2 haptic opengl
media-libs/libsndfile minimal
media-libs/libvpx postproc
media-libs/mesa d3d9 lm-sensor xa
media-libs/harfbuzz icu

# MEDIA-PLUGINS
media-plugins/alsa-plugins pulseaudio
media-plugins/audacious-plugins aac cdda cue flac http lame libnotify modplug mp3 sndfile vorbis wavpack

# MEDIA-SOUND
media-sound/mpg123 -pulseaudio
media-sound/pulseaudio alsa-plugin -bluetooth -daemon

# MEDIA-VIDEO
media-video/ffmpeg mp3 sdl svg truetype v4l vorbis webp x264 xvid
media-video/pipewire sound-server v4l -bluetooth

# SYS-KERNEL
sys-kernel/zen-sources symlink
sys-kernel/gentoo-sources symlink
sys-kernel/linux-firmware initramfs

# XFCE-BASE
# xfce-base/tumbler epub pdf

# X11-TERMS
x11-terms/rxvt-unicode perl font-styles mousewheel perl 24-bit-color 256-color blink fading-colors gdk-pixbuf startup-notification unicode3 xft

# X11-LIBS
x11-libs/cairo opengl
x11-libs/libfm gtk
x11-libs/motif xft

# X11-MISC
x11-misc/xmobar wifi xft xpm
```
### Edit file - /etc/portage/package.license
```
nano package.license
```
```
# RXMD - Realist Xmonad Minimal Desktop
# package.license file -> /etc/portage/package.license

# APP-EDITORS
app-editors/sublime-text Sublime
app-editors/vscode Microsoft-vscode

# SYS-KERNEL
sys-kernel/linux-firmware linux-fw-redistributable no-source-code
```
### Edit file - /etc/portage/package.mask
```
nano package.mask
```
```
# RXMD - Realist Xmonad Minimal Desktop
# package.mask file -> /etc/portage/package.mask

# // some custom masked package //
```
```
sed -i 's/UTC/local/g' /etc/conf.d/hwclock
```
### Edit file - /etc/fstab
```
nano /etc/fstab
```
```
/dev/sda1   /boot   vfat    noatime       0 2
/dev/sda2   /       f2fs    defaults,rw   0 0
```
```
sed -i 's/localhost/xmonad/g' /etc/conf.d/hostname
```
```
sed -i 's/default8x16/ter-v16b/g' /etc/conf.d/consolefont
```
```
sed -i 's/us/cs/g' /etc/conf.d/keymaps
```
```
sed -i 's/127.0.0.1/#127.0.0.1/g' /etc/hosts
```
```
echo "127.0.0.1 xmonad.gentoo.dev xmonad localhost" >> /etc/hosts
```
### Edit file - /etc/locale.gen
```
nano /etc/locale.gen
```
```
cs_CZ.UTF-8 UTF-8
cs_CZ ISO-8859-2
```
### Edit file - /etc/env.d/02locale
```
nano /etc/env.d/02locale
```
```
LANG="cs_CZ.UTF-8"
LC_COLLATE="C"
```
```
echo "Europe/Prague" > /etc/timezone
```
### Create locale
```
locale-gen
```
```
eselect locale set 7
```
```
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```
### Edit file - /etc/conf.d/net
```
nano /etc/conf.d/net
```
```
config_enp0s3="192.168.0.30 netmask 255.255.255.0"
routes_enp0s3="default via 192.168.0.1"
```
```
cd /etc/init.d/
```
```
ln -s net.lo net.enp0s3
```
### Create user (replace <USER> and <PASSWORD> with custom variables)
```
useradd -m -G audio,video,usb,cdrom,portage,users,wheel -s /bin/bash <USER>
```
```
echo "root:<PASSWORD>" | chpasswd -c SHA256
```
```
echo "user:<PASSWORD>" | chpasswd -c SHA256
```
## Compiling phase 
### Choose and create kernel
```
emerge -g genkernel linux-firmware zen-sources && genkernel all
```
```
emerge -g linux-firmware gentoo-sources genkernel && genkernel all
```
```
emerge -g linux-firmware && emerge -g gentoo-kernel-bin
```
### Install important system packages 
```
emerge -g dhcpcd grub usbutils terminus-font sudo f2fs-tools app-misc/mc ranger dev-vcs/git python oh-my-zsh gentoo-zsh-completions zsh-completions exa alsa-utils lsof htop neofetch eix gentoolkit clang rust --noreplace nano 
```
### Install important desktop packages 
```
emerge -g xmonad xmonad-contrib xmobar imagemagick ueberzug ubuntu-font-family numlockx trayer-srg setxkbmap volumeicon xdotool lxrandr xorg-server lxappearance lxmenu-data gnome-themes-standard rxvt-unicode urxvt-perls elementary-xfce-icon-theme notify-osd picom rofi qt5ct adwaita-qt nitrogen nm-applet pcmanfm xprop i3lock pipewire xsetroot roboto file-roller ristretto tumbler firefox mpv audacious pulsemixer btop youtube-viewer 
```
### Install web developers packages 
```
emerge -g phpmyadmin dev-db/mysql =dev-lang/php-8.1.12 =dev-lang/php-7.4.33 nodejs composer vscode sublime-text
```
### Set PHP version for CLI and APACHE 
```
eselect php set cli php7.4 && eselect php set apache2 php7.4
```
### Install oh-my-zsh plugins and theme
```
git clone https://github.com/romkatv/powerlevel10k.git /usr/share/zsh/site-contrib/oh-my-zsh/custom/themes/powerlevel10k
```
```
git clone https://github.com/zsh-users/zsh-autosuggestions.git /usr/share/zsh/site-contrib/oh-my-zsh/custom/plugins/zsh-autosuggestions
```
```
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh/site-contrib/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

## Configurations
### Grub
```
nano /etc/default/grub
```
```
GRUB_GFXMODE=1920x1080x32
GRUB_GFXPAYLOAD_LINUX=keep
GRUB_BACKGROUND="/boot/grub/grub.png"
GRUB_DISABLE_OS_PROBER=0
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
```

### Sudo
```
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
```
### USER - dotfiles setting
```
cd /home/<USER>
```
```
rm .bashrc
```
```
wget -q http://78.45.232.18:55/xmonad/dotfiles.zip
```
```
unzip -oq dotfiles.zip
```
```
chown -R <USER>:<USER> /home/<USER>/
```
```
cd i3lock-fancy
```
```
make install
```
### ROOT - dotfiles setting
```
cd /root
```
```
wget -q http://78.45.232.18:55/xmonad/root_dotfiles.zip
```
```
unzip -oq root_dotfiles.zip
```
```
chown -R root:root /root
```
### System Wallpapers and Audacious Nucleo Skin
```
cd /usr
```
```
wget -q http://78.45.232.18:55/xmonad/usr.zip
```
```
unzip -oq usr.zip
```
### Change default shell to OH-MY-ZSH
```
chsh -s /bin/zsh root
```
```
chsh -s /bin/zsh <USER>
```
### Grub Install
```
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=XMONAD --recheck /dev/sda
```
```
cd /boot/grub && wget -q http://78.45.232.18:55/xmonad/grub.png
```
```
grub-mkconfig -o /boot/grub/grub.cfg
```

### Config WEB Develop enviroment PHP, APACHE, MYSQL, PHPMYADMIN
```
rm -R /usr/lib/tmpfiles.d/mysql.conf
```
```
nano /usr/lib/tmpfiles.d/mysql.conf
```
```
d /run/mysqld 0755 mysql mysql -
```
```
sed -i 's/SSL_DEFAULT_VHOST/PHP/g' /etc/conf.d/apache2
```
```
echo "ServerName localhost" >> /etc/apache2/httpd.conf
```
```
rm -R /var/www/localhost/htdocs/index.html
```
```
echo "<?php phpinfo(); ?>" > /var/www/localhost/htdocs/index.php
```
```
cp /var/www/localhost/htdocs/phpmyadmin/config.sample.inc.php /var/www/localhost/htdocs/phpmyadmin/config.inc.php
```
```
mkdir /var/www/localhost/htdocs/phpmyadmin/tmp/
```
```
chown -R apache:apache /var/www/ && usermod -aG apache <USER>
```
```
chmod -R 775 /var/www/localhost/htdocs
```
```
chmod -R 777 /var/www/localhost/htdocs/phpmyadmin/tmp
```
### Add Blowfish secret to phpmyadmin
```
nano /var/www/localhost/htdocs/phpmyadmin/config.inc.php
```
```
$cfg['blowfish_secret'] = 'WntN0150l71sLq/{w4V0:ZXFv7WcB-Qz'; 
```
### Mysql root password
```
emerge --config mysql
```
### Run daemons
```
rc-update add elogind boot
```
```
rc-update add consolefont default
```
```
rc-update add numlock default
```
```
rc-update add sshd default
```
```
rc-update add dbus default
```
```
rc-update add alsasound default
```
```
rc-update add dhcpcd default
```
```
rc-update add apache2 default
```
```
rc-update add mysql default
```
```
rc-update add NetworkManager default
```
### Store volume
```
alsactl store
```
### Cleaning
```
rm -R /home/<USER>/dotfiles.zip && rm -R /usr/usr.zip && rm -R /root/root_dotfiles.zip
```
### Reboot to Created Xmonad Desktop
```
umount -R /mnt/gentoo && reboot
```
