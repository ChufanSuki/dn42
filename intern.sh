#!/bin/bash

echo
echo "This script is for iBGP config."
echo

read -p "Choose a short name for this internal peer: " PEER_NAME
read -p "Enter your ASN (e.g. 4242422023): " YOUR_ASN
read -p "Enter peer DN42 IPv4 address: " PEER_IP4
read -p "Enter peer DN42 IPv6 address: " PEER_IP6
read -p "Enter peer DN42 IPv4 network(s) (space separated): " PEER_NET4
read -p "Enter peer DN42 IPv6 network(s) (space separated): " PEER_NET6
read -p "Enter peer WireGuard endpoint ADDRESS: " PEER_ENDPOINT
read -p "Enter peer WireGuard pubkey: " PEER_PUBKEY
read -p "Enter local DN42 IPv4 address: " YOUR_IP4
read -p "Enter local DN42 IPv6 address: " YOUR_IP6
YOUR_PORT="000${PEER_IP4##*.}"
YOUR_PORT="3${YOUR_PORT:(-4)}"
PEER_PORT="000${YOUR_IP4##*.}"
PEER_PORT="3${PEER_PORT:(-4)}"
echo "Local <---> ${PEER_NAME}"
echo "${YOUR_IP4} <---> ${PEER_IP4}"
echo "${YOUR_IP6} <---> ${PEER_IP6}"
echo "Will route: ${PEER_NET4}"
echo "Will route: ${PEER_NET6}"
echo "Peer endpoint: ${PEER_ENDPOINT}:${PEER_PORT}"
echo "Peer pubkey: ${PEER_PUBKEY}"
pause "Is that right?"

WIREGUARD_CONFIG_FILE="/etc/wireguard/intern_${PEER_NAME}.conf"

echo '*** Writing WireGuard configs...'
echo "# Peer dn42-${PEER_ASN:0-4:4}
[Interface]
PrivateKey = `cat private`
ListenPort = ${YOUR_PORT}
Address = ${YOUR_IP4}
Address = ${YOUR_IP6}
PostUp = ip -4 route add dev intern_${PEER_NAME} ${PEER_IP4}/32
PostUp = ip -6 route add dev intern_${PEER_NAME} ${PEER_IP6}/128
`echo -n ${PEER_NET4} | xargs -rn1 echo PostUp = ip -4 route add dev intern_${PEER_NAME}`
`echo -n ${PEER_NET6} | xargs -rn1 echo PostUp = ip -6 route add dev intern_${PEER_NAME}`

echo "Table      = off

[Peer]
PublicKey = ${PEER_PUBKEY}
Endpoint = ${PEER_ENDPOINT}:${PEER_PORT}
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 30" >> $WIREGUARD_CONFIG_FILE

systemctl enable --now wg-quick@intern_${PEER_NAME}
echo -e "$(SYSTEMD_COLORS=1 systemctl status wg-quick@intern_${PEER_NAME})"