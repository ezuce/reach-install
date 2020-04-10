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
and follow instructions on the screen
## Stop Reach

As user ezuce execute:

```sh
cd /home/ezuce/reach-install
./reach stop
```
