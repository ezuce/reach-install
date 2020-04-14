# Reach docker deployment

## Requirements

* A linux server with accessible IP address (public - for https installation) or a linux server with private IP address (for http installation) able to run Docker version at least 1.9.0 (any modern would fit).
* A domain name resolving to this IP address that will serve as an UI entry point and a SIP domain

## Installation

Execute as root:

```sh
yum -y install curl
curl https://raw.githubusercontent.com/ezuce/reach-install/master/reach-host-setup.sh > reach-host-setup
chmod +x reach-host-setup
./reach-host-setup
```
... and wait for prompt:

```
To continue, login as user ezuce [ su - ezuce ] ...
```
Then, as user ezuce execute:

```sh
cd /home/ezuce/reach-install
./reach install
```
and follow instructions on the screen.

The installer will ask you in first two steps to enter FQDN and public IP address of your Reach box. It will try to guess these values, just press Enter if autodetected value is correct. Third step is to choose between HTTP and HTTPS installation. If you choose HTTPS, you have two options: use automatic installation using free Let's Encrypt certificate or using your own certificate for given domain. In the latter case, you need to place your certiface files in `/home/ezuce/reach-install/cert` folder.

## Stop Reach

As user ezuce execute:

```sh
cd /home/ezuce/reach-install
./reach stop
```
