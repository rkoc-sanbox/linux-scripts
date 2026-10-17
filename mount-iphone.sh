#!/usr/bin/env bash
# Pairs the USB-connected iPhone with this computer and mounts its media (photos, videos) under
# ~/mnt/iphone. Unlock the phone and tap "Trust" when it asks. Unmount with unmount-iphone.sh.
set -euo pipefail

mount_point="${HOME}/mnt/iphone"

# /proc/mounts rather than `mountpoint`: on a stale mount stat itself fails with an I/O error.
if grep -qs " ${mount_point} " /proc/mounts; then
	if ls "${mount_point}" >/dev/null 2>&1; then
		echo "iPhone already mounted at ${mount_point}"
		exit 0
	fi

	# The phone locked or was replugged while mounted: clear the dead mount and mount again.
	echo "Stale mount at ${mount_point}; remounting"
	fusermount -uz "${mount_point}"
fi

idevicepair pair
mkdir -p "${mount_point}"
ifuse "${mount_point}"
echo "iPhone mounted at ${mount_point}"
