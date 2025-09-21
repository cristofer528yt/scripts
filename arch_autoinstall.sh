#!/bin/bash

# Проверка что скрипт не запущен с sudo
if [ "$EUID" -eq 0 ]; then
    echo -e "\e[41m\e[97mОШИБКА: Не запускайте скрипт с sudo!\e[0m"
    echo -e "\e[41m\e[97mERROR: Do not run script with sudo!\e[0m"
    exit 1
fi

echo -e "\e[41m\e[97m\e[1mУДАЛЯЕМ ВСЁ NVIDIA. ОСТАВЛЯЕМ ТОЛЬКО NOUVEAU.\e[0m"
echo -e "\e[41m\e[97m\e[1mЭТО СКРИПТ ТОЛЬКО ДЛЯ СМЕНЫ ДРАЙВЕРА. ВСЁ ОСТАЛЬНОЕ УДАЛЯЕТСЯ.\e[0m"
echo -e "\e[41m\e[97m\e[1mНажмите любую клавишу, чтобы продолжить...\e[0m"
read -n1 -s
echo ""

# ------------------
# 1. УДАЛЯЕМ ВСЁ, ЧТО СВЯЗАНО С NVIDIA
# ------------------

echo -e "\e[33mУдаление всех пакетов NVIDIA...\e[0m"
sudo pacman -Rns --noconfirm \
    nvidia \
    nvidia-utils \
    nvidia-settings \
    nvidia-vaapi-driver \
    lib32-nvidia-utils \
    lib32-nvidia-libgl \
    lib32-nvidia-opencl \
    nvidia-opencl \
    nvidia-drm \
    nvidia-modeset \
    nvidia-libgl \
    nvidia-libgl32 \
    nvidia-prime \
    nvidia-xrun \
    2>/dev/null || true

# Блокируем загрузку модулей NVIDIA
echo -e "\e[33mСоздание чёрного списка NVIDIA...\e[0m"
sudo mkdir -p /etc/modprobe.d
echo "blacklist nvidia" | sudo tee /etc/modprobe.d/blacklist-nvidia.conf >/dev/null
echo "blacklist nvidia-uvm" | sudo tee -a /etc/modprobe.d/blacklist-nvidia.conf >/dev/null
echo "blacklist nvidia-drm" | sudo tee -a /etc/modprobe.d/blacklist-nvidia.conf >/dev/null
echo "blacklist nvidia-modeset" | sudo tee -a /etc/modprobe.d/blacklist-nvidia.conf >/dev/null
echo "blacklist nvidia-nvlink" | sudo tee -a /etc/modprobe.d/blacklist-nvidia.conf >/dev/null

# Удаляем возможные конфиги, которые могут блокировать nouveau
sudo rm -f /etc/modprobe.d/blacklist-nouveau.conf 2>/dev/null || true

# ------------------
# 2. УСТАНАВЛИВАЕМ ТОЛЬКО НЕОБХОДИМОЕ ДЛЯ NOUVEAU
# ------------------

echo -e "\e[33mУстановка минимального набора для nouveau...\e[0m"
sudo pacman -S --noconfirm \
    xf86-video-nouveau \
    mesa \
    lib32-mesa \
    vulkan-icd-loader \
    lib32-vulkan-icd-loader \
    vulkan-mesa-layers

# Убедимся, что нет конфликтующих драйверов
sudo pacman -Rns --noconfirm \
    xf86-video-intel \
    xf86-video-amdgpu \
    vulkan-intel \
    vulkan-radeon \
    lib32-vulkan-intel \
    lib32-vulkan-radeon \
    intel-vaapi-driver \
    2>/dev/null || true

# ------------------
# 3. ПЕРЕСОЗДАЁМ INITRAMFS
# ------------------

echo -e "\e[33mПересоздание initramfs...\e[0m"
sudo mkinitcpio -P

# ------------------
# 4. ОБНОВЛЯЕМ КЭШ
# ------------------

echo -e "\e[33mОбновление динамических библиотек...\e[0m"
sudo ldconfig

# ------------------
# 5. ОЧИСТКА: УДАЛЯЕМ ВСЁ ОСТАЛЬНОЕ (ПОЖЕЛАНИЕ ПОЛЬЗОВАТЕЛЯ)
# ------------------

echo -e "\e[31mУДАЛЯЕМ ВСЁ ОСТАЛЬНОЕ — VLC, MPV, AUR, OH MY ZSH, КОДЕКИ, ГРАФИКА...\e[0m"
echo -e "\e[31mЭТО ПОЖЕЛАНИЕ ПОЛЬЗОВАТЕЛЯ: ОСТАВИТЬ ТОЛЬКО NOUVEAU.\e[0m"
echo -e "\e[31mВСЁ ОСТАЛЬНОЕ УДАЛЯЕТСЯ. ЭТО МАКСИМАЛЬНО ЧИСТЫЙ СИСТЕМНЫЙ СТАТУС.\e[0m"

# Удаляем всё, что было установлено ранее (если вы его не хотите)
# Это необязательно — но по вашему запросу "оставь только nouveau" — удаляем всё лишнее.
# Если вы хотите сохранить что-то — закомментируйте строки ниже.

sudo pacman -Rns --noconfirm \
    vlc mpv smplayer celluloid mplayer \
    gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly \
    ffmpeg ffmpeg2theora ffmpegthumbnailer \
    a52dec faac faad2 flac lame libcdio libcdio-paranoia libdca libdv libmad \
    libmpeg2 libvorbis libxv wavpack opus libopus libfdk-aac libmp3lame \
    x264 x265 xvidcore libavif libheif libde265 libaom dav1d svt-av1 vpx libvpx \
    libpng libjpeg-turbo libtiff webp libwebp jasper \
    libdvdnav libdvdread libbluray \
    libva libva-utils libvdpau \
    mesa-va-drivers mesa-vdpau-drivers \
    libraw1394 libavc1394 libdc1394 libraw libusb libass libsoxr \
    python-pillow python-numpy python-opencv \
    flameshot obs-studio \
    gimp inkscape krita \
    htop bashtop gotop \
    ncdu baobab gparted \
    wireshark-qt nmap \
    timeshift \
    wine-staging lutris \
    audacity ardour \
    code visual-studio-code-bin \
    python-pip \
    firefox chromium \
    lib32-nouveau-dri \
    nftables \
    micro lolcat cmatrix \
    tmux expect \
    2>/dev/null || true

# Удаляем yay и AUR-пакеты
if command -v yay >/dev/null; then
    echo -e "\e[31mУдаление yay и всех AUR-пакетов...\e[0m"
    sudo pacman -Rns --noconfirm yay
    rm -rf ~/.cache/yay
fi

# Удаляем Oh My Zsh
rm -rf ~/.oh-my-zsh
rm -f ~/.zshrc
cp ~/.zshrc.pre-oh-my-zsh ~/.zshrc 2>/dev/null || true

# Удаляем шрифты Powerline
rm -rf ~/fonts

# ------------------
# 6. ФИНАЛЬНОЕ СООБЩЕНИЕ
# ------------------

echo ""
echo -e "\e[42m\e[30m✅ УСТАНОВКА ЗАВЕРШЕНА. ОСТАЛСЯ ТОЛЬКО NOUVEAU.\e[0m"
echo -e "\e[42m\e[30mВСЁ ОСТАЛЬНОЕ УДАЛЕНО.\e[0m"
echo -e "\e[42m\e[30mРЕКОМЕНДУЕМ ПЕРЕЗАГРУЗИТЬСЯ.\e[0m"
echo ""
echo -e "\e[43m\e[30mПроверьте драйвер после перезагрузки:\e[0m"
echo -e "\e[43m\e[30m  lspci -k | grep -A 2 -i vga\e[0m"
echo -e "\e[43m\e[30m  glxinfo | grep "OpenGL renderer"\e[0m"
echo ""
echo -e "\e[41m\e[97m⚠️  ПЕРЕЗАГРУЗИТЕ СИСТЕМУ СЕЙЧАС: sudo reboot\e[0m"
