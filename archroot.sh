#!/bin/bash

clear

set -e

if [ "$(mount | grep '/mnt ' | sed 's/on.*//')" == "/dev/nvme0n1p2" ];
then
        disk="nvme0n1"
fi

if [ "$(mount | grep '/mnt ' | sed 's/on.*//')" == "/dev/sda2" ];
then
        disk="sda"
fi

if [ "$(mount | grep '/mnt ' | sed 's/on.*//')" == "/dev/vda2" ];
then
        disk="vda"
fi

grub-install /dev/"$disk"
grub-mkconfig -o /boot/grub/grub.cfg

useradd -m virt
echo "virt:1" | chpasswd
echo "root:1" | chpasswd

echo "virt ALL=(ALL:ALL) ALL" >> /etc/sudoers

touch pacman.txt

if [ "$(pacman -Q networkmanager)" == "networkmanager" ];
then
	echo "networkmanager" >> pacman.txt
fi

if [ "$(pacman -Q sddm)" == "sddm" ];
then
	echo "sddm" >> pacman.txt
fi

if [ "$(pacman -Q gdm)" == "gdm" ];
 then
 	echo "gdm" >> pacman.txt
fi

if [ "$(cat pacman.txt | grep 'networkmanager')" == "networkmanager" ];
then
	systemctl enable NetworkManager
fi

if [ "$(cat pacman.txt | grep 'networkmanager')" == "networkmanager" ] && [ "$(cat pacman.txt | grep 'sddm')" == "sddm" ];
then
	systemctl enable NetworkManager
	systemctl enable sddm
fi

if [ "$(cat pacman.txt | grep 'networkmanager')" == "networkmanager" ] && [ "$(cat pacman.txt | grep 'gdm')" == "gdm" ];
then
	systemctl enable NetworkManager
	systemctl enable gdm
fi

echo "Password for user 'virt' = 1, for root = 1"
echo
echo "NOTE: I recommend changing the password for the user and root for security!"
sleep 10

rm pacman.txt

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
locale-gen

