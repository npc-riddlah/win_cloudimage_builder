#!/bin/bash
PATH_VIRTIO="/tmp/virtio.iso"

mkdir -p "$WCB_PATH_SYSPART/drv/virtio"
if [ ! -f $PATH_VIRTIO ]; then
	echo "Virtio-win.iso is not cached. Downloading into $PATH_VIRTIO"
	wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso -O $PATH_VIRTIO -q
else
	echo "Using cached virtio-win.iso"
fi
echo "Extracting..."
7z x $PATH_VIRTIO -o"$WCB_PATH_SYSPART/drv/virtio"
echo "Done!"
