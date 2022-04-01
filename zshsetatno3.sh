
echo "Make a .zshrc in home directory before executing"
#adding .zshrc
echo "Enter Username: "
read username

#adding plugin and extention to .zshrc
sed -i -e 's/plugins=(.*)/plugins=(git archlinux zsh-syntax-highlighting zsh-autosuggestions)/' /home/$username/.zshrc
sed -i -e "s/ZSH_THEME=\".*\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g" /home/$username/.zshrc




#append without NOPASSWD
sudo echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

#command to comment no sudo password
sudo sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/#%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers
