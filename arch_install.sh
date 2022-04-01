#part1
lsblk
echo "Just make efi and linux partition because swap will be made from linux hdd partititon"
read -p "Do you want reflector mirror update? [yn]" reflect
if [[ $reflect = y ]] ; then
  reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
fi
#reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
printf '\033c'
echo "Install beggining"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
lsblk
echo "Enter the drive: "
read drive
cfdisk $drive 
echo "Enter the linux partition: "
read partition
mkfs.ext4 $partition 
read -p "Did you also created efi partition? [yn]" answer
if [[ $answer = y ]] ; then
  echo "Enter EFI partition: "
  read efipartition
  mkfs.vfat -F 32 $efipartition
fi
if [[ $answer = n ]] ; then
  echo "Enter EFI partition: "
  read efipartition
  mkdir -p /mnt/boot/efi
  mount $efipartition /mnt/boot/efi 
fi
mount $partition /mnt 
pacstrap /mnt base base-devel linux linux-firmware intel-ucode git vim
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit

#part2
printf '\033c'
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
#i915 nvidia(mkinitcpio -p linux)
pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
sed -i -e 's/MODULES=(.*)/MODULES=(i915 nvidia)/' /etc/mkinitcpio.conf
mkinitcpio -p linux
passwd
# echo root:password | chpasswd
# pacman --noconfirm -S grub efibootmgr os-prober
pacman -S grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools reflector base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call  virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld flatpak sof-firmware nss-mdns acpid os-prober ntfs-3g terminus-font tlp

echo "Enter EFI partition: " 
read efipartition
mkdir /boot/efi
mount $efipartition /boot/efi 
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
# pacman --noconfirm -S dhcpcd networkmanager 
# systemctl enable NetworkManager.service 
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable reflector.timer
systemctl enable tlp 
# systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid

#visudo
#EDITOR=vim visudo
#uncomment wheel

#echo "Enter Username: "
#read username
#useradd -m -G wheel -s /bin/bash $username
#passwd $username

#swapfile
dd if=/dev/zero of=/swapfile bs=1M count=8192 status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
# vim /etc/fstab
#(swapfile as comment)
echo "/swapfile  none   swap   defaults   0 0" >> /etc/fstab
echo "Pre-Installation Finish Reboot now after genfstabbing last command"
genfstab -U /mnt >> /mnt/etc/fstab


#rm /bin/sh
#ln -s dash /bin/sh
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "Enter Username: "
read username
useradd -m -G wheel -s /bin/bash $username
passwd $username
echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
exit 





#part3
printf '\033c'
cd $HOME
sudo timedatectl set-ntp true
sudo hwclock --systohc

# sudo reflector -c India Germany -a 6 --sort rate --save /etc/pacman.d/mirrorlist
# sudo reflector --country India,France,Germany --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist


#sudo systemctl start firewalld
#sudo firewall-cmd --add-port=1025-65535/tcp --permanent
#sudo firewall-cmd --add-port=1025-65535/udp --permanent
#sudo firewall-cmd --reload


git clone https://aur.archlinux.org/yay-git.git
echo "Enter Username: "
read username
chown -R $username:$username ./yay-git
cd yay-git
makepkg -si

sudo pacman -S --noconfirm xorg sddm plasma kde-applications firefox simplescreenrecorder obs-studio vlc papirus-icon-theme kdenlive materia-kde

# sudo flatpak install -y spotify

sudo systemctl enable sddm

yay --noconfirm -S layan-kde-git spotify-adblock google-chrome brave-bin visual-studio-code-bin sublime-text-4 nerd-fonts-fantasque-sans-mono ttf-meslo-nerd-font-powerlevel10k ttf-joypixels tela-icon-theme ksysguard plasma5-applets-netspeed telegram-desktop-bin


/bin/echo -e "fix sudo privileges after reboot"
/bin/echo -e "part3 end here"
exit
