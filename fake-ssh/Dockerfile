FROM ubuntu

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update -y
RUN apt-get -qq install -y sudo openssh-server git curl
RUN apt-get -qq install -y vim nano less zsh
RUN apt-get -qq install -y gcc nodejs npm python3

ADD files /

RUN curl -L git.io/antigen > /usr/local/bin/antigen.zsh \
    && chmod 755 /usr/local/bin/antigen.zsh \
    && cat /etc/zsh/zshrc.custom >> /etc/zsh/zshrc

ARG user1=user

RUN useradd -G sudo admin \
    && useradd $user1 \
    && echo "admin:4dM1n" | chpasswd \
    && chown -R admin /home/admin \
    && chsh -s /bin/zsh admin \ 
    && echo "$user1:${user1}password" | chpasswd \
    && cp -r /home/admin /home/$user1 \
    && chown -R $user1 /home/$user1 \
    && chsh -s /bin/zsh $user1 \
    && chmod 755 /etc/zsh/zshrc \
    && rm /etc/update-motd.d/60-unminimize \
    && chsh -s /bin/zsh root

CMD service ssh restart && /bin/bash
