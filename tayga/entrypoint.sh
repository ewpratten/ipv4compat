#! /bin/bash
# This script will be fed some env vars:
# - $SNAT_IPV4: The IPv4 address to use for SNAT
# - $TAYGA_IPV6: An IPv6 address to assign to Tayga
# - $WAN_INTERFACE: The name of the WAN interface
set -ex

# Shutdown handler
# cleanup() {
#     echo "Caught shutdown signal. Cleaning up network interfaces"
    
#     # Kill tayga
#     killall tayga
    
#     # Bring down the nat interface
#     ip link del dev nat64
# }
# trap cleanup SIGINT SIGTERM

# Generate the config file
mkdir -p /var/db/tayga
mkdir -p /usr/local/etc
cat >/usr/local/etc/tayga.conf <<EOD
    tun-device nat64
    ipv4-addr 100.64.0.1
    ipv6-addr $TAYGA_IPV6
    prefix 64:ff9b::/96
    dynamic-pool 100.64.0.0/10
    data-dir /var/db/tayga
EOD

# Tell Tayga to generate the translation interface
ip link del dev nat64 || true
tayga --mktun

# Configure the translation interface
ip link set dev nat64 up
ip addr add 100.64.0.1/10 dev nat64
ip addr add $TAYGA_IPV6/128 dev nat64
ip route add 64:ff9b::/96 dev nat64

# Set up SNAT from the translation interface to the outside world
iptables -A FORWARD -i nat64 -o $WAN_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 100.64.0.0/10 -o $WAN_INTERFACE -j SNAT --to-source $SNAT_IPV4

# Start Tayga
tayga -d

# Wait for the process to exit
# wait

# Clean up
# cleanup
