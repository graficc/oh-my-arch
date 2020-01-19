#!/bin/bash

# Localize
# time
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
# language
sed -i '176c en_US.UTF-8 UTF-8' /etc/locale.gen
sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# Network
echo 'Arch_omen' > /etc/hostname
echo '127.0.0.1    localhost' >> /etc/hosts
echo '::1          localhost' >> /etc/hosts
echo '127.0.1.1    Arch_omen.localdomain  Arch_omen' >> /etc/hosts

# Ucode and Initramfs
pacman -Syy --noconfirm intel-ucode
mkinitcpio -p linux-lts

# Grub
pacman -S --noconfirm grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB_ARCH --recheck
grub-mkconfig -o /boot/grub/grub.cfg
