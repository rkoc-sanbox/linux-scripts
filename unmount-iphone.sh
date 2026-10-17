#!/usr/bin/env bash
# Unmounts the iPhone mounted by mount-iphone.sh, so the phone can be unplugged safely. Also clears
# a stale mount (the phone locked or was replugged while mounted, and every access now fails with
# "Input/output error").
set -euo pipefail

mount_point="${HOME}/mnt/iphone"

# /proc/mounts rather than `mountpoint`: on a stale mount stat itself fails with an I/O error.
if ! grep -qs " ${mount_point} " /proc/mounts; then
	echo "iPhone is not mounted at ${mount_point}"
	exit 0
fi

if fusermount -u "${mount_point}" 2>/dev/null; then
	echo "iPhone unmounted from ${mount_point}"
	exit 0
fi

# A stale or busy mount refuses a normal unmount; a lazy one detaches it anyway.
fusermount -uz "${mount_point}"
echo "iPhone mount at ${mount_point} was stale or busy; detached it"
