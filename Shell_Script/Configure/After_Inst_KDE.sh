#!/bin/bash

# Font
sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji

# Set language
sudo sh -c "echo 'LANG=zh_CN.UTF-8' > /etc/locale.conf"

# Set input method
sudo pacman -S --noconfirm fcitx5-git fcitx5-gtk-git fcitx5-qt5-git fcitx5-rime-git kcm-fcitx5-git fcitx5-chinese-addons-git
echo 'export GTK_IM_MODULE=fcitx5' > .xprofile
echo 'export QT_IM_MODULE=fcitx5' >> .xprofile
echo 'export XMODIFIERS=@im=fcitx5' >> .xprofile
echo 'fcitx5 &' >> .xprofile

# Install TLP
sudo pacman -S --noconfirm tlp tlp-rdw ethtool smartmontools
sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket

# Install software for personal use
sudo pacman -S --noconfirm wget curl aria2 gcc gdb make clang lldb llvm git zsh vim neovim google-chrome spotify netease-cloud-music telegram-desktop typora qq-linux wps-office-cn wps-office-mui-zh-cn ttf-wps-fonts libreoffice-fresh libreoffice-fresh-zh-cn visual-studio-code-bin electron-ssr clash --needed
