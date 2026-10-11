#!/bin/bash
# Copy src/linuwu_sense.c into the DKMS tree, rebuild, reload. Run: sudo bash install-dkms.sh
set -euo pipefail
[ "$EUID" -eq 0 ] || { echo "run with sudo"; exit 1; }
DKMS_SRC=/usr/src/linuwu-sense-1.0
KVER=$(uname -r)
cp -a "$DKMS_SRC/linuwu_sense.c" "$DKMS_SRC/linuwu_sense.c.bak-$(date +%F-%H%M)"
cp "$(dirname "$0")/src/linuwu_sense.c" "$DKMS_SRC/linuwu_sense.c"
dkms build   -m linuwu-sense -v 1.0 -k "$KVER" --force
dkms install -m linuwu-sense -v 1.0 -k "$KVER" --force
systemctl stop damx-daemon.service
rmmod linuwu_sense; modprobe linuwu_sense
systemctl start damx-daemon.service
sleep 2
echo "version: $(cat /sys/devices/platform/acer-wmi/nitro_sense/version)"
echo "profile: $(cat /sys/firmware/acpi/platform_profile)"
journalctl -u damx-daemon -n 20 -o cat | grep -i 'driver version'
