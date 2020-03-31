#!/bin/bash -e

# terminal colors
FG_GREEN_BOLD="$(tput setaf 2)$(tput bold)"
FG_BOLD="$(tput bold)"
DEFAULT="$(tput sgr0)"

# install and run docker
if which yum > /dev/null 2>&1; then
{
    yum -y update
    yum -y install yum-utils device-mapper-persistent-data lvm2 git ngrep tcpdump net-tools sudo
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum -y install docker-ce
    systemctl start docker
    systemctl enable docker
}
elif which apt-get > /dev/null 2>&1; then
{
    apt-get remove docker docker-engine docker.io
    apt-get -y update
    apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common git ngrep tcpdump net-tools sudo
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    apt-get -y update
    apt-get -y install docker-ce

    systemctl start docker
}
fi

# install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# create user ezuce, if it does not exist
id -u ezuce >/dev/null 2>&1 || useradd --home-dir /home/ezuce -g docker ezuce

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
