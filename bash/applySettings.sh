#!/bin/bash

################################################################## 
## applySettings.sh - this script is used to set my prefered    ##
## prefered settings after a fresh manjaro linux installation   ##
##################################################################

# get and run script from github:
# wget https://raw.github.com/pylight/scripthub/master/bash/applySettings.sh -O - | sh

##################################################################

# move the panel to the top of the screen and tweak appearence
echo "applying xfce panel settings..."
xfconf-query  -c xfce4-panel -p /panels/panel-0/position -t string -s "p=6;x=960;y=14"
xfconf-query -c xfce4-panel -p /panels/panel-0/background-alpha -s 60
xfconf-query -c xfce4-panel -p /panels/panel-0/size -s 23
xfconf-query -c xfce4-panel -p /plugins/plugin-6/show-frame -s "false"


# install and set elementary icon theme
echo "installing and setting elementary icon theme..." 
sudo pacman -S elementary-icon-theme
xfconf-query -c xsettings -p /Net/IconThemeName -s "elementary"
sudo pacman -Rsc faenza-icon-theme

# install and set a lighter theme (zukitwo)
echo "installing and setting zukitwo gtk theme..." 
sudo pacman -S gtk-theme-zukitwo
xfconf-query -c xsettings -p /Net/ThemeName -s "Zukitwo"
xfconf-query -c xfwm4 -p /general/theme -s "Zukitwo"

# disable xfce compositor (xfwm4) and use tear free / more beautiful compton instead (see also http://goo.gl/TKrXOV)
echo "replacing xfwm4 with compton..."
xfconf-query --channel=xfwm4 --property=/general/use_compositing --set=false
sudo pacman -S compton 
# config will be added from .dotfiles repo 
# autostart entry is also added below

# replace thunar with nemo
echo "replacing thunar with nemo file manager.."
sudo pacman -S nemo
sudo rm /usr/bin/Thunar /usr/bin/thunar
sudo ln -s /usr/bin/nemo /usr/bin/thunar         
sudo ln -s /usr/bin/nemo /usr/bin/Thunar
# disable xfdesktop icons, nemo will be used to display icons on the desktop
xfconf-query -c xfce4-desktop -p /desktop-icons/style -s 0 

# replace xfce4-terminal with urxvt terminal emulator and set a better shortcut
echo "replace xfce4-terminal with urxvt"
sudo pacman -S rxvt-unicode
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Primary>t" -r
sudo pacman -R xfce4-terminal
# download bashscript that supports opening new tabs with a shortcut
mkdir ~/Scripts
cd ~/Scripts
wget https://raw.github.com/pylight/scripthub/master/bash/runUrxvt.sh
chmod +x runUrxvt.sh 
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Control><Alt>t" -n -t string -s "$HOME/Scripts/runUrxvt.sh"

# checkout and set up .dotfiles (github repo that contains important configurations)
echo "checkout config files (dotfiles git-repo)..."
sudo pacman -S git
cd ~
git clone git://github.com/pylight/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh --doinstall

# set user default shell to zsh
chsh -s /bin/zsh

# install other nice tools
echo "installing other software..."
sudo pacman -S vim htop clementine xbmc deadbeef geany chromium virtualbox virtualbox-guest-iso virtualbox-host-dkms zsh openssh conky xdotool keepassx pidgin gdb meld tree

# install important drivers
sudo pacman -S hplip 

# install packages from aur
yaourt -S dropbox nemo-dropbox pencil teamviewer

# add autostart entries
# compton
echo "set autostart entries for compton and nemo"
sudo sh -c "echo '[Desktop Entry]\nEncoding=UTF-8\nType=Application\nName=Compton\nComment=\nExec=compton\nStartupNotify=false\nTerminal=false\nHidden=false' > /etc/xdg/autostart/compton.desktop"
# nemo
sudo sh -c "echo '[Desktop Entry]\nEncoding=UTF-8\nType=Application\nName=Nemo\nComment=\nExec=nemo -n --no-desktop\nStartupNotify=false\nTerminal=false\nHidden=false' > nemo.desktop"

# restart system
read -p "All settings applied. Restart system now? [y/N] " prompt
if [[ $prompt =~ [yY](es)* ]]
then
 sudo reboot
fi
