#!/bin/bash

# Add user aaron
useradd -m -G wheel,adm -s /bin/bash aaron

# Source mirror and aur helper
sed -i 's/#Color/Color/g' /etc/pacman.conf
sed -i 's/#VerbosePkgLists/VerbosePkgLists/g' /etc/pacman.conf
echo '[archlinuxcn]' >> /etc/pacman.conf
echo 'SigLevel = TrustedOnly' >> /etc/pacman.conf
echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf
pacman -Syy -noconfirm archlinuxcn-keyring
# avoid key error
rm -rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate archlinux
pacman-key --populate archlinuxcn
pacman -Syy archlinuxcn-keyring
# install yay
pacman -S --noconfirm yay

# Xorg
pacman -S --noconfirm xorg mesa vulkan-intel intel-media-driver xf86-input-libinput xf86-input-synaptics
echo 'export LIBVA_DRIVER_NAME=iHD' > /etc/profile.d/va-api.sh
chmod a+x /etc/profile.d/va-api.sh
ln -sf /usr/share/X11/xorg.conf.d/40-libinput.conf /etc/X11/xorg.conf.d/40-libinput.conf
ln -sf /usr/share/X11/xorg.conf.d/70-synaptics.conf /etc/X11/xorg.conf.d/70-synaptics.conf

# Nvidia
pacman -S --noconfirm nvidia-lts nvidia-settings nvidia-utils optimus-manager optimus-manager-qt nvidia-prime

# KDE
pacman -S --noconfirm plasma kdebase kdegraphics sddm sddm-kcm latte-dock
systemctl enable sddm   # enable sddm

# Network and MTP
pacman -S --noconfirm networkmanager --needed
systemctl enable NetworkManager
pacman -S --noconfirm bluez bluez-utils pulseaudio-modules-bt alsa-utils alsa-firmware alsa-plugins pulseaudio-alsa --needed
usermod -aG lp aaron
systemctl enable bluetooth
pacman -S --noconfirm libmtp mtpfs android-tools android-udev
