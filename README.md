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
Then, as user ezuce, execute:

```sh
cd /home/ezuce/reach-install
./reach install
```
and follow instructions on the screen.

The installer will ask you in first two steps to enter FQDN and public IP address of your Reach box. It will try to guess these values, just press Enter if autodetected values are correct. Third step is to choose between HTTP and HTTPS installation. If you choose HTTPS, you have two options: use automatic installation using free [Let's Encrypt](https://letsencrypt.org/) certificate or using your own certificate for given domain. In the latter case, you need to place your certificate files in `/home/ezuce/reach-install/cert` folder.

## Stop Reach

As user ezuce execute:

```sh
cd /home/ezuce/reach-install
./reach stop
```
## Troubleshooting and logs
As user ezuce execute:

```sh
cd /home/ezuce/reach-install
./reach logs [services]
```
above command will start to output logs from Reach services to stdout - starting with latest recorded log line for each service. If no service is explicitly specified, it will output logs for all of them. Multiple services should be separated by space.

Example:
```sh
./reach logs kamailio freeswitch reach
```
Collection of historical logs intended for troubleshooting can be extracted with command 

```sh
./reach logs -e [otions] [services]
```
switch `-e` or `--export` means exporting logs to files. Accepted options are `--since` and `--until`. Proper values for these options are the same as described in docker documentation for `docker logs` [command](https://docs.docker.com/engine/reference/commandline/logs/):

>The `--since` option shows only the container logs generated after a given date. You can specify the date as an RFC 3339 date, a UNIX timestamp, or a Go duration string (e.g. `1m30s`, `3h`). Besides RFC3339 date format you may also use RFC3339Nano, `2006-01-02T15:04:05`, `2006-01-02T15:04:05.999999999`,  `2006-01-02Z07:00`, and `2006-01-02`. The local timezone on the client will be used if you do not provide either a `Z` or a `+-00:00` timezone offset at the end of the timestamp. When providing Unix timestamps enter seconds[.nanoseconds], where seconds is the number of seconds that have elapsed since January 1, 1970 (midnight UTC/GMT), not counting leap seconds (aka Unix epoch or Unix time), and the optional .nanoseconds field is a fraction of a second no more than nine digits long.

Again, if no service is explicitly specified, logs for all of them will be exported. Exported logs will be compressed and stored in file with name:


reach_**your_fqdn**_**timestamp**.tar.gz

Examples:

to obtain logs from freeswitch and kamailio services from last 2 hours, use:
```sh
./reach logs -e --since 2h freeswitch kamailio
```
to obtain logs from all services from last day, use:
```sh
./reach logs -e --since 24h
```
