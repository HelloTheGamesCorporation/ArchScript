#!/bin/bash

clear

set -e

if [ "$(mount | grep '/mnt ' | sed 's/on.*//')" == "/dev/nvme0n1p2" ];
then
        disk="nvme0n1"
elif [ "$(mount | grep '/mnt ' | sed 's/on.*//')" == "/dev/sda2" ];
then
        disk="sda"
elif [ "$(mount | grep '/mnt ' | sed 's/on.*//')" == "/dev/vda2" ];
then
        disk="vda"
fi

grub-install /dev/"$disk"
grub-mkconfig -o /boot/grub/grub.cfg

useradd -m virt
echo "virt:1" | chpasswd
echo "root:1" | chpasswd

echo "virt ALL=(ALL:ALL) ALL" >> /etc/sudoers

systemctl enable NetworkManager

if [ "$(pacman -Q | grep 'sddm')" == "sddm" ];
then
	systemctl enable sddm
elif [ "$(pacman -Q | grep 'gdm')" == "gdm" ];
then
	systemctl enable gdm
else
	echo "sddm or gdm not found, because you install a clean system (i.e. only tty)"
 	sleep 15
fi

echo "Password for user 'virt' = 1, for root = 1"
echo
echo "NOTE: I recommend changing the password for the user and root for security!"
sleep 10

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
locale-gen

