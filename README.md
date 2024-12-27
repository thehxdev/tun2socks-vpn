# tun2socks VPN
A simple Bash script to configure and run [tun2socks](https://github.com/xjasonlyu/tun2socks) on your Linux machine for
creating a VPN tunnel that routes all of your traffic to a socks5 proxy that probably is running on your local network.

This script can be used with [Xray-Core](https://github.com/xtls/xray-core) or other proxy/tunneling solutions that does not
support VPN-Mode for routing and tunneling all of your traffic.

> [!WARNING]
> This software uses `systemd-run` command to run `tun2socks` with memory limit and CPU quota. It will not work on non-systemd systems.

## Install
First of all install [tun2socks](https://github.com/xjasonlyu/tun2socks). It MUST be in your PATH.
Then you can just put `vpn-mode.bash` file in `/usr/local/bin` and use it. The command below will do this for you:
```bash
sudo curl -L -o '/usr/local/bin/vpn-mode' 'https://raw.githubusercontent.com/thehxdev/tun2socks-vpn/refs/heads/main/vpn-mode.bash'
sudo chmod +x /usr/local/bin/vpn-mode
```

Then you need a config file. You can find an example config in [vpn-config.bash](vpn-config.bash). Download the config file:
```bash
curl -L -o "$HOME/vpn-config.bash" 'https://raw.githubusercontent.com/thehxdev/tun2socks-vpn/refs/heads/main/vpn-config.bash'
```

Edit the config to fit your environment:
```bash
# Your VPN server public IP address
CONFIG_EXTERNAL_SERVER_IP=''

# List of IP CIDRs that you want to exclude
CONFIG_EXCLUDE_CIDRS=('')

# Your (probably local) proxy server
CONFIG_PROXY='socks5://127.0.0.1:10808'
```

## Run
There are only two commands (Must be run as root):
```bash
# Running tun2socks
sudo vpn-mode run $HOME/vpn-config.bash

# Kill tun2socks and cleanup everything
sudo vpn-mode kill
```
