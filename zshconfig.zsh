# Source nvm
export NVM_DIR="/usr/local/bin/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
[ -s "$NVM_DIR/nvm.sh" ] && nvm use node >/dev/null  # This loads node

# Load Antigen
source /usr/local/bin/antigen.zsh
antigen init /etc/antigenrc

# Load p10k
if [[ $(tty) != "/dev/tty"* ]]; then
    source /etc/p10k.zsh
else
    source /etc/p10k-console.zsh
fi

# Display welcome message
echo -e "\nLogged in as $(whoami)@$(hostname)"
IPADDR=$(hostname -I | awk '{print $1}')
if [ "$IPADDR" = "" ]; then
	echo "Not connected to a router!"
else
	echo "Connected as $IPADDR"
fi
figlet "Hello $(whoami)"

