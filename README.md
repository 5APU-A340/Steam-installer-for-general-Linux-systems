# Steam Installer for General Linux Systems

这是一个功能强大的通用 Linux Steam 安装脚本，旨在解决各发行版在安装 Steam 过程中遇到的依赖缺失、32位库不匹配、软件源未配置以及权限限制等典型问题。

---

## 核心特性

* **智能兼容性**：支持多种发行版，包括 Ubuntu, Debian, Kali, Arch Linux, Manjaro, Fedora, Nobara, OpenSUSE 等。
* **自动补全驱动**：识别 NVIDIA/AMD/Intel 显卡并自动安装对应的 32位图形兼容库，这是解决“启动后转圈闪退”的关键。
* **自动仓库管理**：自动开启 multilib (Arch)、multiverse (Ubuntu) 或 RPMFusion (Fedora)。
* **残留进程清理**：启动前自动杀掉僵尸进程，杜绝 Steam is already running 报错。
* **智能权限切换**：虽然安装需要 root 权限，但脚本会自动切换回普通用户身份拉起 Steam，符合官方安全规范。
* **自动回退方案**：在极少数不支持的原生环境，引导用户通过 Flatpak 进行安装。

---

## 快速上手

请按照以下步骤在您的终端执行操作：

```bash
# 1. 下载脚本 (使用 GitHub 原始链接确保获取最新版)
curl -L -o install_steam.sh [https://raw.githubusercontent.com/5APU-A340/Steam-installer-for-general-Linux-systems/main/install_steam.sh](https://raw.githubusercontent.com/5APU-A340/Steam-installer-for-general-Linux-systems/main/install_steam.sh)

# 2. 赋予执行权限
chmod +x install_steam.sh

# 3. 以 sudo 权限运行
sudo ./install_steam.sh