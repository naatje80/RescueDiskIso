#! /bin/sh

set -e

DEBUG=0

sudo pacman --noconfirm -Sy git

# Prepare SystemRescueCD sources
if [[ ! -d systemrescue-sources ]]; then
	git clone --depth=1 --recurse-submodule https://gitlab.com/systemrescue/systemrescue-sources
else
	git -C systemrescue-sources pull
	git -C systemrescue-sources reset --hard
fi

sudo cp -v systemrescue-sources/pacman.conf /etc/pacman.conf

sudo pacman --noconfirm -Sy \
	archiso \
	hugo \
	edk2-shell \
	mtools \
	isomd5sum \
	doublecmd-qt5 \
	base-devel

# Get ddrescueview
if [[ ! -e ddrescueview ]]; then
	./download_ddrescueview.sh
fi

# GTK2 package is no longer available, compiling from aur source package
if [[ ! -d gtk2 ]]; then
	git clone https://aur.archlinux.org/packages/gtk2.git
fi
cd gtk2
if [[  ! -e $(echo ./pkg/gtk2/usr/lib/libgdk-x11-2.0.so.0.*) -o ! -e $(echo ./pkg/gtk2/usr/lib/libgtk-x11-2.0.so.0.*) ]]; then
	makepkg -sf --noconfirm
fi
cp -v ./pkg/gtk2/usr/lib/libgdk-x11-2.0.so.0.* ../systemrescue-sources/airootfs/usr/lib/libgdk-x11-2.0.so.0
cp -v ./pkg/gtk2/usr/lib/libgtk-x11-2.0.so.0.* ../systemrescue-sources/airootfs/usr/lib/libgtk-x11-2.0.so.0
cd ..

# Get crazy disk info
if [[ ! -e crazydiskinfo/crazy ]]; then
	git clone --depth=1 https://github.com/otakuto/crazydiskinfo.git
	patch -p0 < crazy_disk_info.patch
	cd crazydiskinfo
	cmake . -DCMAKE_POLICY_VERSION_MINIMUM=3.5
	make -j $(nproc)
	cd ..
fi

# Additional tools
cp -v ddrescueview systemrescue-sources/airootfs/usr/bin
cp -v crazydiskinfo/crazy systemrescue-sources/airootfs/usr/bin

# Copy desktop shortcuts
if [[ ! -d systemrescue-sources/airootfs/root/Desktop ]]; then
	mkdir -p systemrescue-sources/airootfs/root/Desktop
fi
cp -v cpu-x.desktop systemrescue-sources/airootfs/root/Desktop

# Default wallpaper 
if [[ ! -d systemrescue-sources/airootfs/usr/share/backgrounds/xfce ]]; then
	mkdir -p systemrescue-sources/airootfs/usr/share/backgrounds/xfce 
fi
cp -v wallpaper_rescuediskiso.png systemrescue-sources/airootfs/usr/share/backgrounds/xfce

if [[ ! -d systemrescue-sources/airootfs/root/.config/xfce4/xfconf/xfce-perchannel-xml ]]; then
	mkdir -p systemrescue-sources/airootfs/root/.config/xfce4/xfconf/xfce-perchannel-xml 
fi
cp -v xfce4-desktop.xml systemrescue-sources/airootfs/root/.config/xfce4/xfconf/xfce-perchannel-xml 

# Autostart conky
if [[ ! -d systemrescue-sources/airootfs/root/.config/autostart ]]; then
	mkdir -p systemrescue-sources/airootfs/root/.config/autostart
fi
cp -v Conky.desktop systemrescue-sources/airootfs/root/.config/autostart
cp -v .conkyrc systemrescue-sources/airootfs/root

cp -v start-xfce.sh systemrescue-sources/airootfs/etc/profile.d
cp -v enable-desktop-icons.sh systemrescue-sources/airootfs/etc/profile.d

cd systemrescue-sources
if [[ ! -d airootfs/opt/RescueDiskUtil ]]; then
	git clone --recurse-submodule https://github.com/naatje80/RescueDiskUtil.git airootfs/opt/RescueDiskUtil
else
	git -C airootfs/opt/RescueDiskUtil pull
fi

cp -v airootfs/opt/RescueDiskUtil/RescueDiskUtil.desktop airootfs/root/Desktop
if [[ ! -d airoots/usr/share/pixmaps ]]; then
	mkdir -p airootfs/usr/share/pixmaps 
fi
cp -v airootfs/opt/RescueDiskUtil/RescueDiskUtil.png airootfs/usr/share/pixmaps

# Additional required packages
echo "conky
python-pillow
libatasmart
cpu-x
" >>packages


if [[ ${DEBUG} == 1 ]]; then
	sudo ./build.sh -v -d -N RescueDiskIso
else
	sudo ./build.sh -N RescueDiskIso
fi

sudo mv -v out/*.iso ../
sudo chown -R $USER: ../*.iso
