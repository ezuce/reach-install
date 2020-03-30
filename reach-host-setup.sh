#!/bin/bash -e

# terminal colors
FG_GREEN_BOLD="$(tput setaf 2)$(tput bold)"
FG_GREY="$(tput sgr0)"
FG_RED_BOLD="$(tput setaf 1)$(tput bold)"
FG_BOLD="$(tput bold)"
DEFAULT="$(tput sgr0)"

yum -y update

# install and run docker
yum -y install yum-utils device-mapper-persistent-data lvm2 git ngrep tcpdump net-tools sudo
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce
systemctl start docker
systemctl enable docker

# install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

useradd --home-dir /home/ezuce -g docker ezuce

#mkdir -p /home/ezuce/keys
#mkdir -p /home/ezuce/keys-challenge/.well-known/acme-challenge

# get installation scripts
cd /home/ezuce
git clone 
git clone -b master --depth 1 https://github.com/ezuce/reach-install.git 2> /dev/null
chown ezuce:ezuce -R /home/ezuce

# user ezuce can quietly alter iptables to open port range for RTP media
echo "%ezuce ALL=(root) NOPASSWD:/sbin/iptables" > /etc/sudoers.d/ezuce

cat <<-EOF
	${FG_BOLD}Login now as user ${FG_GREEN_BOLD}ezuce${FG_BOLD} to continue ...${DEFAULT}
EOF
