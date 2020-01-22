### Arch Linux 折腾日常之基本系统的安装

Arch Linux是我最喜欢的发行版之一, 它接近上游, 可以体验到最新的软件包；系统可以自行定制却没LFS那么折腾, 我这样对Linux晓得一点皮毛的人也可以上手, 但这也可能是我无法发挥Arch的威力的原因。@~@

我的配置：惠普的暗影精灵5 i7-9750H+GTX1650 该死的双显卡, 让我Linux安装特别曲折, 下面正式开始

#### 安装前的准备

将archlinux的iso烧录到U盘

```sh
sudo umount /dev/sdX*                  # 卸载U盘
sudo dd if=./archlinux.iso of=/dev/sdX \
oflag=sync status=progress bs=4M       # 烧录iso
```

#### 启动到Live CD

插入U盘, 启动到archlinux的Live CD

ps：N卡最好在启动时按下e并在末尾加入 "modprobe.blacklist=nouveau" 以禁用 nouveau 开源驱动, 否则可能花屏或者出现其他莫名bug

#### 验证启动模式

```sh
ls /sys/firmware/efi/efivars
```

如果有结果, 系统就是以UEFI模式启动的, 否则是BIOS模式启动的, 我的笔记本是UEFI模式启动

#### 联网

可以用`ip link`查看自己的网卡型号, en打头的是有线, 比如宽带或者手机USB网络共享, wl打头是无线网卡的型号。我的笔记本在archlinux的Live CD下可以看到eno1和wlan0

- 有线

  插了网线的的启动Live CD时就会用dhcpcd获取有线的ip地址, 也可以ping一下百度测试一下

- 无线

  ```sh
  wifi-menu                 # 连接wifi
  dhcpcd wlan0              # 获取ip地址
  ping -c4 www.baidu.com    # 测试连接
  ```

  wlan0 替换为你自己的无线网卡型号就行

- USB网络共享

  ```sh
  dhcpcd <网卡型号>         # 即可自动获取ip地址
  ```

#### 更换软件源

```sh
vim /etc/pacman.d/mirorrlist
```

这个mirrorlist在会复制到接下来安装的系统中, 我在第一行加入了下面的镜像源, 可自行更换 

```sh
Server = https://mirrors.neusoft.edu.cn/archlinux/$repo/os/$arch
```

#### 更新系统时间

```sh
timedatectl set-ntp true
timedatectl status       # 可选, 查看系统现在的时间状态
```

#### 分区

- 我的分区方案：

    | 挂载点    | 分区类型                 | 大小  | 文件系统 |
    | --------- | ------------------------ | ----- | -------- |
    | /boot/efi | EFI系统分区(EF00)        | 512MB | fat32    |
    | /         | Linux 根目录(8300)       | 50GB  | xfs      |
    | /home     | 个人数据目录(8300)       | 200GB | xfs      |
    | [SWAP]    | Linux swap交换分区(8200) | 4GB   | swap     |

    GPT分区表最好使用 gdisk 命令或者 cgdisk 交互命令

    ```sh
    gdisk /dev/nvme0n1     # 更换为自己想要安装到的硬盘
    ```

    nvme一般是m.2接口的硬盘, sata的硬盘可能是sda、sdb什么的

    分完区可以用 lsblk 命令检查一下

- 格式化和挂载分区

  ```sh
  mkfs.fat -F32 /dev/nvme0n1p1          # 格式化efi分区
  mkfs.xfs /dev/nvme0n1p2               # 格式化root分区
  mkfs.xfs /dev/nvme0n1p3               # 格式化home分区
  mkswap /dev/nvme0n1p4                 # 格式化swap分区
  swapon /dev/nvme0n1p4                 # 启用swap
  mount /dev/nvme0n1p2 /mnt             # 把root分区挂载到/mnt
  mkdir -p /mnt/boot/efi /mnt/home      # 建立/boot/efi和/home目录
  mount /dev/nvme0n1p1 /mnt/boot/efi    # 挂载efi分区到/boot/efi
  mount /dev/nvme0n1p3 /mnt/home        # 挂载home分区到/home
  ```

#### 开始安装

```sh
pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware\
dosfstools xfsprogs sysfsutils inetutils net-tools dhcpcd netctl iw wpa_supplicant dialog\
less vim man-db man-pages bash-completion
```

base组更改之后需要加装很多东西, 管理文件系统的、联网的、文本编辑的......

基本系统：`base`、`base-devel` 其中`base-devel`包含很多开发所需工具

Linux内核：`linux-lts`、`linux-lts-headers`, 我安装的是LTS的Linux, bug会少一些, ArchLinux中有许多为不是使用主线稳定内核的用户提供`dkms`版的软件, 需要内核对应的`headers`来安装

大部分驱动：`linux-firmware`

管理文件系统：`xfsprogs`、`dosfstool`、`sysfsutils`, 管理xfs、fat32等文件系统

网络连接所需工具：`inetutils`、`net-tools`、`dhcpcd`、`netctl`、`iw`、`wpa_supplicant`、`dialog` 来管理有线和无线连接

文本浏览和编辑工具：`less`、`vim`

man系统手册：`man-db`、`man-pages`

为了等下可以补全部分命令安装`bash-completion`

#### 配置系统

- Fstab

  生成fstab文件

  ```sh
  genfstab -U /mnt >> /mnt/etc/fstab
  ```

  建议用vim查看一下生成后的fstab`vim /mnt/etc/fstab`

- Chroot

  Change root 到刚刚安装的系统

  ```sh
  arch-chroot /mnt
  ```

- 本地化

  - 时区

    ```sh
    ln -sf /usr/share/zoneinfo/Asia/Shanghai \
    /etc/localtime       # 更改时区
    hwclock --systohc    # 应用到硬件时间
    ```

  - 语言

    ```sh
    vim /etc/locale.gen
    ```

    移除下列语言的注释(#)即可

    ```sh
    en_US.UTF-8 UTF-8
    zh_CN.UTF-8 UTF-8
    ```

    ```sh
    locale-gen
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf
    ```

    生成语言信息, 然后更改语言环境为英文, 避免乱码

- 网络配置

  ```sh
  echo 'Arch-Omen' > /etc/hostname
  vim /etc/hosts
  ```

  Arch-Omen是我自己的主机名, 自己更改为喜欢的名字即可, 下面的主机名也要随着该

  加入以下内容

  ```sh
  127.0.0.1       localhost
  ::1             localhost
  127.0.1.1       Arch-Omen.localdomain    Arch-Omen
  ```

- Initramfs

  ```sh
  pacman -Syy intel-ucode    # 安装intel微码
  mkinitcpio -p linux-lts    # 生成initramfs
  ```
  
- 设定Root密码

  ```sh
  passwd     # 即可
  ```

#### 安装引导

```sh
pacman -S grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot/efi \
--bootloader-id=GRUB_ARCH --recheck      # 安装grub引导
grub-mkconfig -o /boot/grub/grub.cfg     # 生成grub配置
```

若是多系统, 需要将其他系统的efi分区挂载, 然后再使用上述最后一条命令重新生成grub配置即可

#### 重启

```sh
exit
umount -a    # 卸载已挂载的文件系统
reboot
```

若是N卡, 建议在重启启动时grub中按e添加参数, 在linux所在行行尾添加 "modprobe.blacklist=nouveau"再按Ctrl + x启动即可

#### 参考链接

1. [ArchLinux‘s Install Guide](https://wiki.archlinux.org/index.php/Installation_guide)
2. [ArchLinux's Install Guide中文译版](https://wiki.archlinux.org/index.php/Installation_guide_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))
