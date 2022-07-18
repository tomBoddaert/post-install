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

# install zsh, vim, docker, figlet, curl, openssh-server, vsc-i, vlc
echo -e "\nInstalling docker, figlet, openssh-server, vim, vlc, vsc (insiders) and zsh..."
apt-get -qqy install zsh vim docker.io figlet curl openssh-server 1>/dev/null
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

# setup ssh
echo -e "\nSetting up ssh server (port 2222)..."
if [[ -f ./authorized_keys ]]
then
    (echo "Found 'authorized_keys' file" && mkdir ${SUDO_USER_HOME}/.ssh 2>/dev/null && cp -r ./authorized_keys ${SUDO_USER_HOME}/.ssh/authorized_keys && chown -R $SUDO_USER ${SUDO_USER_HOME}/.ssh && chmod -R 700 ${SUDO_USER_HOME}/.ssh)
else
    (mkdir -p ${SUDO_USER_NAME}/.ssh/authorized_keys && chown -R $SUDO_USER ${SUDO_USER_HOME}/.ssh && chmod -R 700 ${SUDO_USER_HOME}/.ssh)
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
