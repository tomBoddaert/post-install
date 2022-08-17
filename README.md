# Tom's post-install setup script

`> sudo bash setup.sh`

This is my personal setup script, designed to work out of the box with Ubuntu.

It will install:
 - Caffeine
 - Curl
 - Discord-ptb
 - Docker
 - Figlet
 - GIMP
 - Go
 - Google Chrome
 - Hue lights
 - Node.js
 - OpenRGB
 - Rust
 - Steam
 - VLC
 - VSC (insiders)
 - Vim
 - Wget

Zsh will be setup with antigen, some bundles and the p10k theme, which is setup as per [p10k.zsh](p10k.zsh) for most terminals and [p10k-console.zsh](p10k-console.zsh) for consoles, due to reduced font options.

It will setup my ['fake-ssh' container](#'fake-ssh'-container), which is a docker container, with an ssh server running on port 22.

It sets up [ssh](#SSH) on port 2222 for public key authentication only. If an `authorized_keys` file is present in this directory, it will add that to your `authorized_keys` file.

After install, you can delete this directory.


## Using other GNU/Linux based operating systems

Any Linux distro with `apt-get` will work. You must also install [`snap`](https://snapcraft.io/docs/installing-snap-on-debian) before running the script.


## Advice

If you do not understand any of this, please **do not run this script**!


## SSH

This script sets up an SSH server on port 2222, with [public key authentication](https://www.ssh.com/academy/ssh/public-key-authentication) only. To learn how to use public key authentication, go [here](https://serverpilot.io/docs/how-to-use-ssh-public-key-authentication/).


## 'fake-ssh' container

The default user names and passwords are:
 - `admin` : `4dM1n`
 - `{user}` : `{user}password` (replacing `{user}` with your username)

You can `ssh` to them using `ssh admin@localhost` or `ssh $USER@localhost` or from an external computer.

This will be setup to run at startup by default but can be disabled by removing the line added in crontab, by using `crontab -e`.

.

.

### Trademarks

Ubuntu is a registered trademark of Canonical Ltd.
