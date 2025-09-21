#!/bin/bash
# Проверка что скрипт не запущен с sudo
if [ "$EUID" -eq 0 ]; then
    echo -e "\e[41m\e[97mОШИБКА: Не запускайте скрипт с sudo!\e[0m"
    echo -e "\e[41m\e[97mERROR: Do not run script with sudo!\e[0m"
    exit 1
fi
#installing all codec, what gives me deepseek
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
sudo pacman -Sy --noconfirm reflector
sleep 5
sudo reflector --country Russia --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syy
sudo pacman -S --noconfirm gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly && sudo pacman -S --noconfirm ffmpeg gst-libav && sudo pacman -S --noconfirm a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 x265 xvidcore
sudo pacman -S --noconfirm vlc mpv
sudo pacman -S --noconfirm gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly ffmpeg a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 x265 xvidcore libavc1394 libdc1394 libdv libdvdnav libdvdread libmpeg2 libraw1394 libavif libheif libde265 libaom dav1d svt-av1 vpx opus libfdk-aac libmp3lame libvpx libx264 libx265 libxvid libpng libjpeg-turbo libtiff webp libwebp libvorbis libogg libFLAC libmad libmpeg2 liba52 libdca libdv libtheora libvdpau libva libva-utils intel-vaapi-driver nvidia-vaapi-driver mesa-va-drivers mesa-vdpau-drivers vulkan-icd-loader lib32-vulkan-icd-loader
sudo pacman -S --noconfirm \
    gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly \
    ffmpeg ffmpeg2theora ffmpegthumbnailer \
    a52dec faac faad2 flac lame libcdio libcdio-paranoia libdca libdv libmad \
    libmpeg2 libvorbis libxv wavpack opus libopus libfdk-aac libmp3lame \
    x264 x265 xvidcore libavif libheif libde265 libaom dav1d svt-av1 vpx libvpx \
    libpng libjpeg-turbo libtiff webp libwebp jasper \
    libdvdnav libdvdread libbluray \
    libva libva-utils libvdpau intel-vaapi-driver nvidia-vaapi-driver \
    mesa-va-drivers mesa-vdpau-drivers vulkan-icd-loader lib32-vulkan-icd-loader \
    libraw1394 libavc1394 libdc1394 libraw libusb libass libsoxr \
    python-pillow python-numpy python-opencv \
    vlc mpv smplayer celluloid \
    mplayer mpv-mpris \
    mediainfo exiftool handbrake handbrake-cli
sudo pacman -S flameshot obs-studio
sudo pacman -S gimp inkscape krita
sudo pacman -S htop bashtop gotop
sudo pacman -S ncdu baobab gparted
sudo pacman -S wireshark-qt nmap
sudo pacman -S timeshift
sudo pacman -S wine-staging lutris
sudo pacman -S audacity ardour
sudo pacman -S handbrake
sudo pacman -S code visual-studio-code-bin
sudo pacman -S python-pip
sudo pacman -S firefox chromium
sudo pacman -S --noconfirm mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader
sudo pacman -S --noconfirm xf86-video-intel xf86-video-amdgpu xf86-video-nouveau
sudo pacman -S --noconfirm vulkan-intel vulkan-radeon lib32-vulkan-intel lib32-vulkan-radeon
sudo pacman -Rns nvidia nvidia-utils nvidia-settings 2>/dev/null || true
echo "blacklist nvidia" | sudo tee /etc/modprobe.d/blacklist-nvidia.conf >/dev/null
sudo pacman -S --noconfirm mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader
sudo pacman -S --noconfirm xf86-video-intel xf86-video-amdgpu xf86-video-nouveau
sudo pacman -S --noconfirm vulkan-intel vulkan-radeon lib32-vulkan-intel lib32-vulkan-radeon
sudo pacman -S --noconfirm lib32-nouveau-dri
sudo pacman -S --noconfirm lib32-mesa lib32-vulkan-icd-loader lib32-vulkan-radeon lib32-vulkan-intel
sudo pacman -S --noconfirm lib32-nouveau-dri
sudo mkinitcpio -P
sudo ldconfig

#------------------
#just apps what i use
sudo pacman -S --noconfirm python3
sudo pacman -S --noconfirm vlc-plugin-ffmpeg vlc-plugin-x264 vlc-plugin-x265 vlc-plugins-all vlc-plugin-ffmpeg  && sudo pacman -S --noconfirm vlc-plugin-ffmpeg
# ------------------
# auto isntall aur
sudo pacman -S --noconfirm git micro lolcat cmatrix && sudo pacman -S micro nano lolcat git cmatrix #and other from pacman, part from yay(aur) after
git clone https://aur.archlinux.org/yay.git
sleep 2
cd yay
makepkg -si
sleep 2
cd ..
sudo rm -rf yay
# --------------
# installing my package
yay -S video2ascii yandex-music telegram-desktop discord --noconfirm #no steam because i dont need him on linux, im playing games on windows
yay -S mangohud-git
