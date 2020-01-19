#!/bin/bash

# Software source mirror
sed -i 's/Server/#Server/g' /etc/pacman.d/mirrorlist
sed -i '6c Server = https://mirrors.neusoft.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
sed -i '7c Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist

# timedatectl
timedatectl set-ntp true

# Disk part
# mkfs.fat -F32 /dev/nvme0n1p1    # EFI
# mkfs.xfs /dev/nvme0n1p2 -f      # root
# mkfs.xfs /dev/nvme0n1p3 -f      # home
# mkswap /dev/nvme0n1p4           # swap
# swapon /dev/nvme0n1p4           # enable swap
# mount parts
# mount /dev/nvme0n1p2 /mnt
# mkdir -p /mnt/boot/efi /mnt/home
# mount /dev/nvme0n1p1 /mnt/boot/efi
# mount /dev/nvme0n1p3 /mnt/home

# Install base system
pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware dosfstools xfsprogs sysfsutils inetutils net-tools dhcpcd netctl iw wpa_supplicant dialog less vim man-db man-pages bash-completion

# generate fstab
genfstab -U /mnt >> /mnt/etc/fstab
