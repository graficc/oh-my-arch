## N卡的血泪史和Arch Linux上解决方案

#### 设备：惠普暗影精灵5 i7-9750H + GTX1650 双显卡 Coffee Lake + Turing GPU

大部分知名的Linux我都尝试过了, 因为双显卡的原因各方面都有不同的bug, 先说说在各大Linux上的体验结果, 真是一部血泪史

##### Ubuntu

- 18.04 LTS 这个版本上面并没有自带N卡驱动, 但源里面有, 可以在网上找到教程安装, 参考[双显卡笔记本如何安装NVIDIA卡驱动](https://www.qingsword.com/qing/1020.html), 安装完成后可以正常用Gnome进行显卡切换`intel`和`nvidia`显卡, 闭源驱动性能还好
- 19.10 这个版本会自动安装N卡闭源驱动, 并且有`intel`、`Hybrid`和`nvidia`三种切换模式, 可以用Gnome进行显卡切换`intel`和`nvidia`显卡, 闭源驱动性能较佳
- 据说Ubuntu有最好的i+n卡解决方案, 的确用起来很方便, 性能也还不错；但是Ubuntu内部错误啥的搞得我很恶心, 不久就放弃了

##### Pop!_OS

- 它基于Ubuntu 18.04 LTS 和 19.10 两个版本均有对N卡专门适配过的镜像下载, 安装后均自带Nvidia闭源驱动, 可以通过`system76 power` 这个来切换`intel`、`Hybrid`和`nvidia`三种模式, 而且切换为`intel`模式时, N卡对应的PCI也被移除, 细节方面做的很好

##### Linux Mint

- 和Pop!_OS一样基于Ubuntu 18.04, Mint 19.2版本可以自己到软件管理安装闭源驱动

##### Deepin

- Deepin 15.11 的双显卡管理方案是大黄蜂（Bumblebee）, 这玩意儿对我的显卡并不管用, 安装后直接重启卡死

##### Debian

- 10.02 Debian Wiki上也是大黄蜂方案, 而且源里的N卡闭源驱动也老旧, 所以我自己下载适合我显卡的Nvidia-xxx.run文件来安装, 安装好后并使用了PRIME Render offload（下面详细介绍）配置, 不过弄完后会有花屏现象

**CentOS**

- 最新的Cent OS 8我直接安装时就卡死~-~

##### Fedora

- 安装过Fedora 31 Gnome, 但这个在我电脑上表现并不好, 而且我也没找到Fedoa关于双显卡的解决方案

##### openSUSE

- 体验过Tumbleweed版本, 它提供了一种`suse-prime`的双显卡切换方案, 可以切换`intel`和`nvidia`, 而且`intel`有`i915`和`modesetting`模式切换, 即核显使用不同的驱动, 貌似是配合闭源驱动修改Xorg和dm的配置实现的, 体验极好, 闭源驱动性能不错 PS：需要手动添加NVIDIA源使用该方案

##### Manjaro

- KDE和Gnome版本均体验过, 它是使用mhwd驱动管理器管理显卡驱动。对于双显卡, 它也是用老旧的大黄蜂方案, 我安装完重启卡住, 没办法搞。但它基于Arch Linux, 可以使用Arch Linux的方案, 下面详解。

##### Arch Linux

终于来到重头戏, Arch Wiki上提供了不少的双显卡解决方案

- 大黄蜂(Bumblebee)

  上面说过了, 老旧的大黄蜂对我的显卡并不管用, 但它的bbswitch可以好好利用一下

- nvidia-xrun

  没尝试过, 不过据说体验不好

- optimus-manager

  最近正在折腾的, 表现很不错
  
- PRIME Render Offload

  nvidia官方从435.17支持的类似windows上的双显卡处理方案, 效果比较好
  
- arch-prime-git （Wiki没有说明）

  这是aur上切换显卡的脚本, 作者好像是魔改`suse-prime`的, 在我的笔记本上并不好用

-------------------------

#### 折腾开始

- **bbswitch**

  最初想法是直接关闭独显的, 在网上查了查, 发现bumblebee的一个模块bbswitch可以关闭独显, 于是开始折腾

  - 安装bbswitch

    ```sh
    pacman -S bbswitch-dkms    # lts版内核安装这个
    ```

  - 手动加载bbswitch

    ```sh
    sudo modprobe bbswitch
    ```
  - 手动设置显卡状态
  
    ```sh
    sudo tee /proc/acpi/bbswitch <<<OFF     # 关闭独立显卡
    sudo tee /proc/acpi/bbswitch <<<ON      # 开启独立显卡
    ```
  
    注意在此之前需禁用nvidia相关驱动如`nouveau`、`nvidia`、`nvidia-modeset`、`nvidia-drm`、`nvidia-uvm`, 即在/etc/modprobe.d/加入blacklist文件, 我把他们加入blacklist-nv.conf中
  
    ```sh
    vim /etc/modprobe.d/blacklist-nv.conf
    # 加入以下内容
    blacklist nouveau
    blacklist nvidia
    blacklist nvidia-modeset
    blacklist nvidia-drm
    blacklist nvidia-uvm
    ```
  
    重启之后即可生效, 注意内核参数中不要有关于显卡的设置

  - 关闭独立显卡的输出信息

    ```sh
    dmesg | grep bbswitch
    ```
  
    这样便可简单查看bbswitch输出信息
  
  - 加载bbswitch时关闭显卡, 卸载时开启显卡
  
    ```sh
    sudo sh -c "echo 'options bbswitch load_state=0 unload_state=1' > /etc/modprobe.d/bbswitch.conf"
    ```
  
    其中-1是保持显卡状态不变, 0是关闭显卡, 1是开启显卡
  
  - 关机时自动开启显卡, 即在`/etc/systemd/system/`加入相应服务
  
    ```sh
    sudo vim /etc/systemd/system/nvidia-enable.service
    # 加入以下内容
    [Unit]
    Description=Enable NVIDIA card
    DefaultDependencies=no

    [Service]
    Type=oneshot
    ExecStart=/bin/sh -c 'echo ON > /proc/acpi/bbswitch'

    [Install]
    WantedBy=shutdown.target
    ```
    然后`systemctl enable nvidia-enable.service`即可, 这样可以避免一些下一次开机可能出现的莫名bug
  
  - 开机自动加载bbswitch
  
    archlinux使用systemd管理服务, 向`/etc/modules-load.d/bbswitch.conf`加入bbswitch即可
  
    ```sh
    echo 'bbswitch' > /etc/modules-load.d/bbswitch.conf
    ```
  
  上述操作即可完成开机后自动禁用显卡, 但我遇到了一些问题, 导致我不采用这个方法
  
  一是设置开机自动加载后开机卡死；二是使用`lspci`命令或者挂起休眠后会导致卡死, 上网查了发现是笔记本的ACPI锁死问题, 我尝试加入了`acpi_osi="!Windows 2015"`、`acpi_osi=! acpi_osi="Windows 2009"`、`acpi_osi=! acpi_osi="Windows 2009"`、`acpi_os_name="Microsoft Windows NT"`、` acpi_osi="!Windows2012"`等, 还有下列内核参数
  
  ```sh
  "Microsoft Windows NT"
  "Microsoft Windows XP"
  "Microsoft Windows 2000"
  "Microsoft Windows 2000.1"
  "Microsoft Windows ME: Millennium Edition"
  "Windows 2001"
  "Windows 2006"
  "Windows 2009"
  "Windows 2012"
  "Linux"
  ```
  
  但都会遭遇`lspci`卡死问题, 所以我放弃了该方案
  
  参考链接:
  
  1. [惠狐之书  -  Archlinux 下 Intel 和 NVIDIA 双显卡 de 折腾笔记](https://blog.megumifox.com/public/2018/11/26/archlinux-%E4%B8%8B-intel-%E5%92%8C-nvidia-%E5%8F%8C%E6%98%BE%E5%8D%A1-de-%E6%8A%98%E8%85%BE%E7%AC%94%E8%AE%B0/)
  
  2. [lspci问题在Arch Wiki上的描述](https://wiki.archlinux.org/index.php/NVIDIA_Optimus#Lockup_issue_(lspci_hangs))
  
  3. [bbswitch项目主页](https://github.com/Bumblebee-Project/bbswitch)
  
- **optimus-manager**

  这个是archlinux及其衍生发行版如manajaro可以用的, 类似ubuntu的显卡管理, 不过功能强大许多, 操作也简单许多, 安装如下
  
  ```sh
  sudo pacman -S optimus-manager optimus-manager-qt 
  ```
  
  其中optimus-manager-qt是图形界面设置程序, cn源中有打包, aur中还有一个包叫optimus-manager-qt-kde的包, 项目上说是为kde专门配置的, 但我在使用kde时发现这个不起作用, 反而optimus-manager-qt可以工作, 安装完后注意让其自启动
  
  optimus-manager有三种模式, `nvidia`、`intel`、`hybird`, 可以使用命令切换, 也可使用图形应用来切换, 切换需重新登录。其中`hybird`模式在我笔记本上可以起到下面一种方案即PRIME Render offload的效果
  
  图形界面配置是傻瓜式的, 可以设置开机的模式, 更改intel驱动和nvidia驱动配置, 更改使用显卡管理方案, 如使用`bbswitch`、`acpi_call`来关闭显卡, 前提是你必须先安装, 还可以移除pci中的N卡, 与Pop!_OS上`system-power`类似。
  
  其中需注意的就是
  
  - Xorg下不要有任何关于显卡的配置, 如`/etc/X11/xorg.conf.d/nvidia.conf`和manjaro下`mhwd`管理器的`/etc/X11/xorg.conf.d/90-mhwd.conf`
  - 卸载任何配置Xorg的软件, 如`nvidia-xrun`和`Bumblebee`
  - 部分dm不支持, 如`gdm`需使用aur上的`gdm-prime`替换才可行, manjaro的dm需修改配置
  - 使用nvidia模式时, 只能Xorg而不是wayland
  
  一些其他问题详细可参见项目主页
  
  参考链接:
  
  [optimus-manager项目主页](https://github.com/Askannz/optimus-manager)
  
- PRIME Render offload

  这是nvidia官方支持的双显卡方案, 对我的笔记本支持较好

  可以做到默认情况下使用i卡, 休眠n卡, 省电。安装`nvidia-prime`包后, 在命令面前使用`prime-run`即可使用n卡, 如`prime-run glxinfo | grep -i opengl`可查看n卡部分信息

  最新的xorg已经支持该模式并进入了archlinux仓库中, 需要将NVIDIA驱动安装好, 再配置/etc/X11/xorg.conf.d/nvidia.conf

  官方给的配置如下

  ```sh
  Section "ServerLayout"
          Identifier "layout"
          Screen 0 "iGPU"
          Option "AllowNVIDIAGPUScreens"
  EndSection
  
  Section "Device"
          Identifier "iGPU"
          Driver "modesetting"
  EndSection
  
  Section "Screen"
          Identifier "iGPU"
          Device "iGPU"
  EndSection
  
  Section "Device"
          Identifier "dGPU"
          Driver "nvidia"
  EndSection
  ```

  若不生效需加入BusID, 具体参见依云’s blog

  注意需移除其他管理显卡的工具, 避免冲突

  参考链接:

  1. [Arch Wiki 上对该方案的描述]( https://wiki.archlinux.org/index.php/PRIME#PRIME_GPU_offloading)

  2. [NVIDIA官方文档对该方案的描述](https://download.nvidia.com/XFree86/Linux-x86_64/440.44/README/primerenderoffload.html)

  3. [依云‘s blog关于该方案](https://blog.lilydjwg.me/2019/9/3/nvidia-prime-setup.214768.html)
