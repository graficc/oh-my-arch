# Arch + KDE安装

进入刚刚安装的 Arch Linux 使用root登录

#### 联网

- 有线和USB网络共享

  ```sh
  dhcpcd <网卡型号>
  ```

- 无线

  ```sh
  wifi-menu
  dhcpcd <网卡型号>
  ```

#### 添加用户

```sh
useradd -m -G wheel,adm -s /bin/bash aaron    # aaron替换为你喜欢的用户名，不能大写^_^
passwd aaron    # 设置用户密码
EDITOR=vim visudo
```

这时会进入vim的操作界面，取消`# %wheel ALL=(ALL) ALL`的注释即那个#号即可

#### 启用32位支持、添加Archlinuxcn源和aur helper

- 启用32位支持，即启用archlinux的[multilib]，它里面有一些32位程序，如`steam`，`wine`等；启用很简单，取消`/etc/pacman.conf`相应的注释即可

  ```sh
  #[multilib]
  #Include = /etc/pacman.d/mirrorlist
  #Color
  #VerbosePkgLists
  ```

  取消Color的注释可以让pacman彩色输出，而VerbosePkgLists则是升级软件时，可以查看新旧软件对比

- 添加Archlinuxcn社区源，里面打包了aur上国人常用软件和一些软件的Linux版本，在`/etc/pacman.conf`中加入即可

  ```sh
  [archlinuxcn]
  SigLevel = TrustedOnly
  Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch     # 可自行替换其他镜像源
  ```

  再使用`pacman -Syy archlinuxcn-keyring`安装该源所需的密钥

  ps：有时添加密钥出错，可进行如下操作

  ```sh
  rm -rf /etc/pacman.d/gnupg
  pacman-key --init
  pacman-key --populate archlinux
  pacman-key --populate archlinuxcn
  pacman -Syy archlinuxcn-keyring
  ```

- aur helper可以让你快速便捷地安装aur上的软件，yay是用Go语言写的，操作与pacman类似的aur helper，在archlinuxcn源中就有

  ```sh
  pacman -S yay     # 即可
  ```

#### 安装Xorg服务

- Xorg服务

  ```sh
  pacman -S xorg
  ```

  只需安装该软件包组即可

- 触摸板驱动

  在KDE上需要`xf86-input-synaptics`来设置触摸板，而gnome使用`xf86-input-libinput`即可统一管理输入设备

  ```sh
  pacman -S xf86-input-libinput xf86-input-synaptics 
  ln -sf /usr/share/X11/xorg.conf.d/40-libinput.conf /etc/X11/xorg.conf.d/40-libinput.conf    # 初始化输入设备配置
  ln -sf /usr/share/X11/xorg.conf.d/70-synaptics.conf /etc/X11/xorg.conf.d/70-synaptics.conf    # 初始化触摸板配置
  ```

#### 安装显卡驱动

- intel核显开源驱动

  intel开源驱动已经在kernel中集成，即`modesetting`，也可以追加安装`xf86-video-intel `驱动，它提供了xorg上的2D加速服务，但arch wiki上不建议安装该驱动，可能在一些显卡上有问题，若需安装，也请使用`modesetting`提供驱动；`mesa`提供了3D加速的DRI驱动和OpenGL支持，`lib32-mesa`为32位应用提供该支持，`vulkan-intel`提供vulkan支持，`intel-media-driver`提供VA-API视频硬件加速支持（>=Broadwell）

  ```sh
  pacman -S mesa vulkan-intel intel-media-driver
  ```

  还需设置`LIBVA_DRIVER_NAME`环境变量才可启用VA-API支持

  ```sh
  echo 'export LIBVA_DRIVER_NAME=iHD' > /etc/profile.d/va-api.sh
  chmod a+x /etc/profile.d/va-api.sh
  ```

- NVIDIA显卡闭源驱动

  lts内核安装`nvidia-lts`即可，需要使用图形界面设置可安装`nvidia-settings`，提供VDPAU视频硬件加速和其他特性可安装`nvidia-utils`

  ```sh
  pacman -S nvidia-lts nvidia-settings nvidia-utils
  ```

  双显卡笔记本可采用optimus-manager来管理，具体可见另外一篇文章---`Damn_Nvidia.md`

  ```sh
  pacman -S optimus-manager optimus-manager-qt nvidia-prime
  ```
  
  关于视频硬件加速可在vlc中启用，有VA-API和VDPAU两种，其中VDPAU是NVIDIA提供的，使用N卡才会有

#### 安装KDE

```sh
pacman -S plasma kdebase kdegraphics    # 安装kde桌面和部分工具
pacman -S sddm sddm-kcm    # 安装kde登录界面
pacman -S latte-dock     # KDE上好用的dock栏
systemctl enable sddm    #设置登录界面自启动
```

#### 安装网络管理模块和挂载MTP工具

- 网络管理

  ```sh
  pacman -S networkmanager
  systemctl enable NetworkManager    # 设置网络管理模块自启动 注意大小写
  ```

- 蓝牙管理

  ```sh
  pacman -S bluez bluez-utils pulseaudio-modules-bt
  pacman -S alsa-utils alsa-firmware alsa-plugins pulseaudio-alsa
  usermod -aG lp aaron    # 添加用户到lp组控制蓝牙
  systemctl enable bluetooth    # 设置蓝牙模块开机自启动
  ```
  
  博通的蓝牙芯片需要再aur中加装驱动比如`bluez-firmware`
  
- MTP

  ```sh
  pacman -S libmtp mtpfs
  pacman -S android-tools android-udev    # 可选，使用adb管理手机
  ```

  若果用Gnome类的文件管理器，可以安装`gvfs-mtp`，KDE的话，安装`kio-extras`获得更好体验
  
  ----------
  
  重启进入系统
  
  ----------

#### 安装中文字体

- 使用fontconfig

  我个人使用了fontconfig来让字体更好的渲染，我用到的是`noto-fonts`、`noto-fonts-cjk`、`noto-fonts-emoji`和`FuraCode-Nerd-Font`，前面三个archlinuxcn源有打包，最后一个我是在`nerd-font`项目上下载的，主要来使用zsh主题，个人的fontconfig借鉴了<https://szclsya.me/zh-cn/posts/fonts/linux-config-guide/>上的配置，在dotfiles文件夹里

  ```sh
  sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji
  ```

  将font.conf扔进个人home中的`.config/fontconfig`中重新即可看到效果

- 不使用fontconfig

  推荐安装思源系列字体，在KDE中设置即可

  ```sh
  sudo pacman -S adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts
  ```

#### 更改语言

```sh
sudo sh -c "echo 'LANG=zh_CN.UTF-8' > /etc/locale.conf"
```

注销重新登录即可

#### 安装中文输入法

- fcitx & google-pinyin

  ```sh
  sudo pacman -S fcitx fcitx-configtool fcitx-im fcitx-googlepinyin kcm-fcitx    # 安装输入法
  echo 'export GTK_IM_MODULE=fcitx' > .xprofile
  echo 'export QT_IM_MODULE=fcitx' >> .xprofile
  echo 'export XMODIFIERS=@im=fcitx' >> .xprofile
  ```

  经典的fcitx输入法框架

- fcitx5 & 中州韵(fcitx-rime)输入引擎

  ```sh
  sudo pacman -S fcitx5-git fcitx5-gtk-git fcitx5-qt5-git fcitx5-rime-git kcm-fcitx5-git fcitx5-chinese-addons-git
  echo 'export GTK_IM_MODULE=fcitx5' > .xprofile
  echo 'export QT_IM_MODULE=fcitx5' >> .xprofile
  echo 'export XMODIFIERS=@im=fcitx5' >> .xprofile
  echo 'fcitx5 &' >> .xprofile
  ```

  fcitx5相关软件在archlinuxcn源中

重启后生效

#### 安装TLP笔记本电源管理系统

```sh
sudo pacman -S tlp tlp-rdw ethtool smartmontools    # 安装TLP
sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service    # 设置TLP自启动
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket    # 屏蔽部分服务以免冲突
```

重启后生效

