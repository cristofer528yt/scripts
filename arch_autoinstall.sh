#!/bin/bash

# Проверка что скрипт не запущен с sudo
if [ "$EUID" -eq 0 ]; then
    echo -e "\e[41m\e[97mОШИБКА: Не запускайте скрипт с sudo!\e[0m"
    echo -e "\e[41m\e[97mERROR: Do not run script with sudo!\e[0m"
    exit 1
fi

echo -e "\e[48;5;202m\e[30m⚠️  ВНИМАНИЕ: Не запускайте скрипт с sudo! ⚠️\e[0m"
echo -e "\e[48;5;202m\e[30m   Скрипт уже содержит sudo где это необходимо.\e[0m"
echo -e "\e[48;5;202m\e[30m   Запуск с sudo может сломать установку!\e[0m"
echo -e "\e[48;5;202m\e[30m   Используйте: ./autoinstall.sh (БЕЗ sudo!)\e[0m"
echo "-------"
echo -e "\e[48;5;202m\e[30m⚠️  WARNING: Do not run script with sudo! ⚠️\e[0m"
echo -e "\e[48;5;202m\e[30m   Script already has sudo where needed.\e[0m"
echo -e "\e[48;5;202m\e[30m   Running with sudo may break installation!\e[0m"
echo -e "\e[48;5;202m\e[30m   Use: ./autoinstall.sh (NO sudo!)\e[0m"
echo -e "\e[41m\e[97m\e[1mЕсли скрипт запущен без ROOT или SUDO, нажмите любую клавишу чтобы продолжить...\e[0m"
echo -e "\e[41m\e[97m\e[1mIf the script is run without ROOT or SUDO, press any key to continue...\e[0m"
read -n1 -s
echo ""

# Обновление зеркал
sudo pacman -Sy --noconfirm reflector
sleep 5
sudo reflector --country Russia --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syy

# Установка всех медиа-кодеков и инструментов (один раз, без дубликатов)
sudo pacman -S --noconfirm \
    gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly \
    ffmpeg ffmpeg2theora ffmpegthumbnailer \
    a52dec faac faad2 flac lame libcdio libcdio-paranoia libdca libdv libmad \
    libmpeg2 libvorbis libxv wavpack opus libopus libfdk-aac libmp3lame \
    x264 x265 xvidcore libavif libheif libde265 libaom dav1d svt-av1 vpx libvpx \
    libpng libjpeg-turbo libtiff webp libwebp jasper \
    libdvdnav libdvdread libbluray \
    libva libva-utils libvdpau intel-vaapi-driver \
    mesa-va-drivers mesa-vdpau-drivers vulkan-icd-loader lib32-vulkan-icd-loader \
    libraw1394 libavc1394 libdc1394 libraw libusb libass libsoxr \
    python-pillow python-numpy python-opencv \
    vlc mpv smplayer celluloid mplayer mpv-mpris \
    mediainfo exiftool handbrake handbrake-cli \
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
    mesa lib32-mesa \
    xf86-video-intel xf86-video-amdgpu xf86-video-nouveau \
    vulkan-intel vulkan-radeon lib32-vulkan-intel lib32-vulkan-radeon \
    lib32-mesa \
    nftables

# ------------------
# УДАЛЕНИЕ ПРОПРИЕТАРНЫХ ДРАЙВЕРОВ NVIDIA И ПЕРЕКЛЮЧЕНИЕ НА NOUVEAU
# ------------------

# Удаляем все пакеты NVIDIA
sudo pacman -Rns --noconfirm nvidia nvidia-utils nvidia-settings nvidia-vaapi-driver 2>/dev/null || true

# Блокируем загрузку модуля nvidia
echo "blacklist nvidia" | sudo tee /etc/modprobe.d/blacklist-nvidia.conf >/dev/null
echo "blacklist nvidia-uvm" | sudo tee -a /etc/modprobe.d/blacklist-nvidia.conf >/dev/null
echo "blacklist nvidia-drm" | sudo tee -a /etc/modprobe.d/blacklist-nvidia.conf >/dev/null
echo "blacklist nvidia-modeset" | sudo tee -a /etc/modprobe.d/blacklist-nvidia.conf >/dev/null

# Убеждаемся, что nouveau включен (обычно включен по умолчанию)
# Если нужно — можно добавить в initramfs, но в Arch nouveau уже включён по умолчанию
# Убедимся, что модуль nouveau не заблокирован
sudo rm -f /etc/modprobe.d/blacklist-nouveau.conf 2>/dev/null || true

# Пересоздаём initramfs для применения blacklist
sudo mkinitcpio -P

# Обновляем кэш динамических библиотек
sudo ldconfig

# ------------------
# Установка AUR-менеджера yay
# ------------------

sudo pacman -S --noconfirm git micro lolcat cmatrix
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
sudo rm -rf yay

# ------------------
# Установка приложений из AUR
# ------------------

yay -S --noconfirm video2ascii yandex-music telegram-desktop discord mangohud-git

# Установка шрифтов Powerline
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts

# ------------------
# Установка Oh My Zsh
# ------------------

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

# ------------------
# Дополнительные системные пакеты
# ------------------

sudo pacman -S --noconfirm tmux expect

echo -e "\n\e[42m\e[30mУстановка завершена! Перезагрузитесь для применения драйверов.\e[0m"
echo -e "\e[42m\e[30mRestart your system to apply Nouveau drivers.\e[0m"
