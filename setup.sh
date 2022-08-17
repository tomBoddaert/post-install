#!/bin/bash

# check for root
if [ "$EUID" -ne 0 ]
    then echo "Please run as root!"
    exit
fi

# check for apt-get
if ! command -v apt-get &>/dev/null
    then echo "Please install 'apt-get'!"
    exit
fi

# check for snap
if ! command -v snap &>/dev/null
    then echo "Please install 'snap'!"
    exit
fi

# enable ufw
echo -e "\nEnabling ufw..."
ufw enable 1>/dev/null

# update and upgrade
echo -e "\nUpdating package lists..."
apt-get -qq update
echo "Updating packages..."
apt-get -qqy upgrade &>/dev/null

# get home path
export SUDO_USER_HOME=$(eval "echo ~$SUDO_USER")

# install Google Chrome
echo -e "\nDownloading Google Chrome..."
apt-get -qqy install wget
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -qP $SUDO_USER_HOME
echo "Installing Google Chrome..."
apt-get -qq install ${SUDO_USER_HOME}/google-chrome-stable_current_amd64.deb 1>/dev/null
rm ${SUDO_USER_HOME}/google-chrome-stable_current_amd64.deb

# uninstall Firefox
echo "Uninstalling Firefox..."
snap remove firefox 1>/dev/null

# install zsh, vim, docker, figlet, curl, openssh-server, vsc-i, vlc, build-essential
echo -e "\nInstalling docker, figlet, openssh-server, vim, vlc, vsc (insiders), zsh and build essential..."
apt-get -qqy install zsh vim docker.io figlet curl openssh-server build-essential 1>/dev/null
snap install code-insiders --classic 1>/dev/null
snap install vlc 1>/dev/null

# setup docker group
groupadd docker 2>/dev/null
usermod -aG docker $SUDO_USER

# install nvm and node
echo "Installing nvm and node..."
export NVM_DIR=/usr/local/bin/nvm
git clone https://github.com/nvm-sh/nvm.git $NVM_DIR -q
(cd $NVM_DIR && git checkout master -q && chmod 755 ./nvm.sh && source ./nvm.sh && nvm install --no-progress node &>/dev/null && nvm use node >/dev/null)

# install Go
echo "Installing Go..."
curl -so ${SUDO_USER_HOME}/go.tar.gz "https://dl.google.com/go/$(curl -s "https://go.dev/dl/?mode=json" | grep -o "go[0-9\.]*\.linux-amd64\.tar\.gz" | head -1)"
tar -xf ${SUDO_USER_HOME}/go.tar.gz -C /usr/local/

# install rust
echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# install discord-ptb
echo "Installing Discord-ptb..."
curl -so ${SUDO_USER_HOME}/discord-ptb.deb $(curl -s https://discord.com/api/download/ptb\?platform\=linux\&format\=deb | grep -o "https:\/\/dl-ptb\.discordapp\.net\/[^\"<]*" | head -1)
apt-get -qqy install ${SUDO_USER_HOME}/discord-ptb.deb
rm ${SUDO_USER_HOME}/discord-ptb.deb

# install steam
echo "Installing Steam..."
curl -so ${SUDO_USER_HOME}/steam.deb $(curl -so /dev/null -D - https://cdn.akamai.steamstatic.com/client/installer/steam.deb | grep -o "https:\/\/repo\.steampowered\.com\/.*\.deb")
apt-get -qqy install ${SUDO_USER_HOME}/steam.deb
rm ${SUDO_USER_HOME}/steam.deb

# install gimp
echo "Installing GIMP..."
snap install gimp

# install openrgb
echo "Installing OpenRGB..."
add-apt-repository ppa:thopiekar/openrgb
apt-get -qq update
apt-get -qqy install openrgb

# install caffeine
echo "Installing Caffeine..."
(cd ${SUDO_USER_HOME}/.local && git clone https://github.com/eonpatapon/gnome-shell-extension-caffeine.git -q && cd gnome-shell-extension-caffeine && make build && make install)

# install hue-lights
echo "Installing Hue-lights..."
(cd ${SUDO_USER_HOME}/.local && git clone https://github.com/vchlum/hue-lights.git && cd hue-lights -q && ./release.sh && gnome-extensions install hue-lights@chlumskyvaclav.gmail.com.zip)

# setup ssh
echo -e "\nSetting up ssh server (port 2222)..."
if [[ -f ./authorized_keys ]]
then
    (echo "Found 'authorized_keys' file" && mkdir ${SUDO_USER_HOME}/.ssh 2>/dev/null && chmod 700 ${SUDO_USER_HOME}/.ssh && touch ${SUDO_USER_HOME}/.ssh/authorized_keys && chmod 600 ${SUDO_USER_HOME}/.ssh/authorized_keys && cat ./authorized_keys >> ${SUDO_USER_HOME}/.ssh/authorized_keys && chown -R $SUDO_USER ${SUDO_USER_HOME}/.ssh && chgrp -R $SUDO_USER ${SUDO_USER_HOME}/.ssh)
else
    (mkdir ${SUDO_USER_HOME}/.ssh 2>/dev/null && chmod 700 ${SUDO_USER_HOME}/.ssh && touch ${SUDO_USER_HOME}/.ssh/authorized_keys && chmod 600 ${SUDO_USER_HOME}/.ssh/authorized_keys && chown -R $SUDO_USER ${SUDO_USER_HOME}/.ssh && chgrp -R $SUDO_USER ${SUDO_USER_HOME}/.ssh)
fi
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.default
sed 's/^#Port 22$/Port 2222/; s/^#PasswordAuthentication yes$/PasswordAuthentication no/' /etc/ssh/sshd_config.default > /etc/ssh/sshd_config
ufw allow 2222 1>/dev/null
systemctl restart ssh

# setup zsh
echo -e "\nSetting up zsh..."
curl -sL git.io/antigen > /usr/local/bin/antigen.zsh
chmod 755 /usr/local/bin/antigen.zsh
mkdir '/usr/local/share/fonts/MesloLGS NF'
curl -so "/usr/local/share/fonts/MesloLGS NF/MesloLGS NF #1.ttf" -L "github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20{Regular,Bold,Italic}.ttf"
curl -so "/usr/local/share/fonts/MesloLGS NF/MesloLGS NF Bold Italic.ttf" -L "github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
cp ./{antigenrc,p10k.zsh,p10k-console.zsh} /etc/
chmod 755 /etc/{antigenrc,p10k.zsh,p10k-console.zsh}
cat ./zshconfig.zsh >> /etc/zsh/zshrc
chsh -s /bin/zsh $SUDO_USER
chsh -s /bin/zsh root

# setup fake ssh container
echo -e "\nSetting up 'fake ssh' container..."
mkdir ${SUDO_USER_HOME}/Documents/docker
cp -R ./fake-ssh ${SUDO_USER_HOME}/Documents/docker/
chmod 754 ${SUDO_USER_HOME}/Documents/docker/fake-ssh/{build,run,runLimited}
chown -R $SUDO_USER ${SUDO_USER_HOME}/Documents/docker
cp ./crontab.txt ${SUDO_USER_HOME}/crontab.tmp
chown $SUDO_USER ${SUDO_USER_HOME}/crontab.tmp
runuser -l $SUDO_USER -c 'cd ~/Documents/docker/fake-ssh && ./build >/dev/null && crontab -l 1>/dev/null 2>/dev/null && crontab -l >~/crontab.tmp; echo "@reboot ${HOME}/Documents/docker/fake-ssh/runLimited" >> ~/crontab.tmp && crontab ~/crontab.tmp'
rm ${SUDO_USER_HOME}/crontab.tmp

# show info.txt
echo -e "\nDONE"
cat ./info.txt
(cat ./info.txt; echo "Press 'q' to exit") | less
