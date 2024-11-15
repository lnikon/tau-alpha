USB=/dev/sdb
PI_MOUNT_POINT=/mnt/pi-disk

IMG=ubuntu-24.04.1-preinstalled-server-arm64+raspi.img.xz
IMG_URL=https://cdimage.ubuntu.com/releases/24.04/release/${IMG}

DOWNLOAD_RPI_LITE_64:
	curl ${IMG_URL} -o img/${IMG}

WIPE_SDB:
	sudo wipefs -a ${USB}

BURN_IMAGE:
	xz -d < img/${IMG} | sudo dd bs=100M of=${USB} status=progress

MOUNT_IMAGE:
	mkdir -p ${PI_MOUNT_POINT}
	mount ${USB}1 ${PI_MOUNT_POINT}

UMOUNT_IMAGE:
	umount ${PI_MOUNT_POINT}

.PHONY: prepare-k8s-master
PREPARE_K8S_MASTER:
	sudo mount ${USB}1 ${PI_MOUNT_POINT}
	sudo rm -f ${PI_MOUNT_POINT}/user-data
	sudo rm -f ${PI_MOUNT_POINT}/network-config
	cp cloud-init/user-data.master.yaml ${PI_MOUNT_POINT}/user-data
	cp cloud-init/meta-data.master.yaml ${PI_MOUNT_POINT}/meta-data
	sed 's/<SSID_NAME>/'"${SSID_NAME}"'/g;s/<SSID_PASSWD>/'"${SSID_PASSWD}"'/g' cloud-init/network-config | sudo tee ${PI_MOUNT_POINT}/network-config
	sudo umount ${PI_MOUNT_POINT}

.PHONY: prepare-node1
PREPARE_NODE1:
	sudo mount ${USB}1 ${PI_MOUNT_POINT}
	sudo rm -f ${PI_MOUNT_POINT}/user-data
	sudo rm -f ${PI_MOUNT_POINT}/network-config
	sed 's/nodeX/node1/g' cloud-init/user-data | sudo tee ${PI_MOUNT_POINT}/user-data
	sed 's/<SSID_NAME>/'"${SSID_NAME}"'/g;s/<SSID_PASSWD>/'"${SSID_PASSWD}"'/g' cloud-init/network-config | sudo tee ${PI_MOUNT_POINT}/network-config
	sudo umount ${PI_MOUNT_POINT}

