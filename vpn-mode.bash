#!/usr/bin/env bash

set -x

if [[ $UID != 0 ]]; then
    echo "Run as root!"
    exit 1
fi

CONFIG_PATH=$2
DEFAULT_INFO_PATH='/tmp/tun2socks_info'
IP_ROUTE_RULES_PATH='/tmp/ip_route_rules'
TUN_INTERFACE='tun0'

usage() {
    echo "Usage: vpn-mode.bash <run/kill> <vpn_config.bash>"
    exit 1
}

cleanup() {
    source "$DEFAULT_INFO_PATH"

    ip link set dev $TUN_INTERFACE down &>/dev/null
    ip link del dev $TUN_INTERFACE

    ip route flush dev $TUN_INTERFACE &>/dev/null
    ip route flush dev $DEFAULT_INTERFACE &>/dev/null
    ip route flush table main &>/dev/null
    ip route restore < "$IP_ROUTE_RULES_PATH"

    rm -rf "$IP_ROUTE_RULES_PATH" "$DEFAULT_INFO_PATH"
}

run_tun2socks() {
    source "$CONFIG_PATH" || usage

    local DEFAULT_INTERFACE=$(/sbin/ip route | awk '/default/ { print $5 }')
    local DEFAULT_GATEWAY=$(/sbin/ip route | awk '/default/ { print $3 }')

    ip route save > "$IP_ROUTE_RULES_PATH"

    if ! ip link set dev $TUN_INTERFACE up &>/dev/null ; then
        ip tuntap add mode tun dev $TUN_INTERFACE
        ip addr add 198.18.0.1/15 dev $TUN_INTERFACE
        ip link set dev $TUN_INTERFACE up
    fi

    ip route del default
    ip route add "$CONFIG_EXTERNAL_SERVER_IP" via $DEFAULT_GATEWAY dev $DEFAULT_INTERFACE metric 1

    for i in "${CONFIG_EXCLUDE_CIDRS[@]}"; do
        ip route add "$i" via $DEFAULT_GATEWAY dev $DEFAULT_INTERFACE metric 1
    done

    ip route add default via 198.18.0.1 dev tun0 metric 2

    cat > "$DEFAULT_INFO_PATH" << EOF
DEFAULT_INTERFACE=$DEFAULT_INTERFACE
DEFAULT_GATEWAY=$DEFAULT_GATEWAY
EOF

    systemd-run --scope -p MemoryLimit=50M -p CPUQuota=10% \
        tun2socks -device $TUN_INTERFACE -proxy "$CONFIG_PROXY" --loglevel silent &
}

if [[ "$1" == "kill" ]]; then
    cleanup
elif [[ "$1" == "run" ]]; then
    run_tun2socks
else
    usage
fi
