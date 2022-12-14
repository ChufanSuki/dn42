#!/bin/bash
echo '*** Install bird and wireguard'
apt update
apt upgrade -y
apt install -y wireguard bird2

echo '*** Backing old bird config file...'
mv /etc/bird/bird.conf /etc/bird/bird.conf.bak

echo '*** Downloading config files...'
wget -4 -O /tmp/bird.conf https://raw.githubusercontent.com/ChufanSuki/dn42/main/bird.conf && mv -f /tmp/bird.conf /etc/bird/bird.conf
wget -4 -O /tmp/ibgp.conf https://raw.githubusercontent.com/ChufanSuki/dn42/main/ibgp.conf && mv -f /tmp/ibgp.conf /etc/bird/ibgp.conf
wget -4 -O /tmp/dn42_roa.conf https://dn42.burble.com/roa/dn42_roa_bird2_4.conf && mv -f /tmp/dn42_roa.conf /etc/bird/dn42_roa.conf
wget -4 -O /tmp/dn42_roa_v6.conf https://dn42.burble.com/roa/dn42_roa_bird2_6.conf && mv -f /tmp/dn42_roa_v6.conf /etc/bird/dn42_roa_v6.conf
wget -4 -O ~/peer.sh https://raw.githubusercontent.com/ChufanSuki/dn42/main/peer.sh
wget -4 -O ~/remove-peer.sh https://raw.githubusercontent.com/ChufanSuki/dn42/main/remove-peer.sh

echo '*** Setting bird configs...'
ip address
read -p 'IPv4 Address: ' ownip
read -p 'IPv6 Address: ' ownipv6

echo "define OWNAS           = 4242422023;
define OWNIP           = $ownip;
define OWNIPv6         = $ownipv6;
" > /etc/bird/variables.conf

echo '*** Write crontab configs to /etc/crontab ...'

echo '# ChufanSuki DN42 Network
0 * * * * root wget -4 -q -O /tmp/bird.conf https://raw.githubusercontent.com/ChufanSuki/dn42/main/bird.conf && mv -f /tmp/bird.conf /etc/bird/bird.conf && birdc configure
0 * * * * root wget -4 -q -O /tmp/ibgp.conf https://raw.githubusercontent.com/ChufanSuki/dn42/main/ibgp.conf && mv -f /tmp/ibgp.conf /etc/bird/ibgp.conf && birdc configure
0 * * * * root wget -4 -q -O /tmp/dn42_roa.conf https://dn42.burble.com/roa/dn42_roa_bird2_4.conf && mv -f /tmp/dn42_roa.conf /etc/bird/dn42_roa.conf && birdc configure
0 * * * * root wget -4 -q -O /tmp/dn42_roa_v6.conf https://dn42.burble.com/roa/dn42_roa_bird2_6.conf && mv -f /tmp/dn42_roa_v6.conf /etc/bird/dn42_roa_v6.conf && birdc configure
0 * * * * root wget -4 -q -O /tmp/peer.sh https://raw.githubusercontent.com/ChufanSuki/dn42/main/peer.sh && mv -f /tmp/peer.sh /root/peer.sh
0 * * * * root wget -4 -q -O /tmp/remove-peer.sh https://raw.githubusercontent.com/ChufanSuki/dn42/main/remove-peer.sh && mv /tmp/remove-peer.sh /root/remove-peer.sh
' >> /etc/crontab
systemctl restart cron
systemctl status cron

echo '*** Updating System Networking Configurations...'
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.rp_filter=0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.rp_filter=0' >> /etc/sysctl.conf
echo 'net.ipv6.conf.default.forwarding=1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.conf
sysctl -p

echo '*** Creating /etc/bird/peers/ folder...'
mkdir -p /etc/bird/peers

echo '*** Reconfiguring BIRD...'
birdc configure

echo '*** All done!'
echo ''

exit 0