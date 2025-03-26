#!/bin/bash

clear

set -e

echo "Welcome to arch-insraller! Which disk do you want to install it on?"
echo
echo "I recommend monitoring the execution of the script, because there may be moments where input from you will be needed."
echo
echo "What disk do you have?"
echo "vda"
echo "nvme0n1"
echo "sda"
read -p "Choose a disk(Enter in words): " answer
sleep 2
echo
echo "How do you want to partition disk?"
echo "1)Auto(Use a read-made option(for virtual 20GB is required, and for hardware 512GB)"
echo "2)Manually(via cfdisk)"
read -p "Choose your variant(Enter the number): " answer2
sleep 5

if [ "$answer2" == "1" ];
then
	case $answer in
	vda)echo "Good, perform disk partitioning for vda"
	  sfdisk /dev/vda < partition_mapVDA.txt;;
	nvme0n1)echo "Good, perform disk partitioning for nvme0n1"
	  sfdisk /dev/nvme0n1 < partition_mapNVME.txt;;
	sda)echo "Good, perform disk partitioning for sda"
	  sfdisk /dev/sda < partition_mapSDA.txt;;

	esac
fi

if [ "$answer2" == "2" ];
then
	cfdisk /dev/"$answer"
	read -p "Have you finished partition? [y/n]: " partition
	if [ "$partition" == "n" ] || [ "$partition" == "N" ] || [ "$partition" == "no" ] || [ "$partition" == "No" ] || [ "$partition" == "NO" ];
	then
		cfdisk /dev/"$answer"
	fi
fi

echo "Now we will solve the problem with PGP keys (just in case)"
sleep 15
pacman-key --populate
pacman -Sy archlinux-keyring
pacman-key --init
pacman-key --refresh-keys

mkfs.vfat /dev/"$answer""1"
mkfs.ext4 /dev/"$answer""2"

mount /dev/"$answer""2" /mnt
mkdir -p /mnt/boot/efi
mount /dev/"$answer""1" /mnt/boot/efi

echo "What country do you live in? (This is necessary to generate mirrors that will allow you to install packages for the system faster)"
echo
echo "1)Russia"
echo "2)Kazakhstan"
echo "3)Others"
read -p "Which?(Enter the number): " country

if [ "$country" == "1" ] || [ "$country" == "1)" ];
then
	reflector --country Russia --save /etc/pacman.d/mirrorlist --protocol https
 fi

if [ "$country" == "2" ] || [ "$country" == "2)" ];
then
	reflector --country Kazakhstan --save /etc/pacman.d/mirrorlist --protocol https
 fi

 if [ "$country" == "3" ] || [ "$country" == "3)" ];
then
	reflector --save /etc/pacman.d/mirrorlist --protocol https
 fi
 
echo "What do you want?"
echo "1) Xfce4"
echo "2) Clearly system(only tty)"
echo "3) KDE Plasma"
echo "4) GNOME"
read -p "What?(Enter the number): " dewm

if [ "$dewm" == "1" ] || [ "$dewm" == "1)" ];
then
	pacstrap /mnt base base-devel linux linux-firmware linux-headers vim vi grub efibootmgr sddm xfce4 xorg ttf-ubuntu-font-family ttf-hack ttf-dejavu ttf-opensans bash-completion networkmanager
fi

if [ "$dewm" == "2" ] || [ "$dewm" == "2)" ];
then
	pacstrap /mnt base base-devel linux linux-firmware linux-headers vim vi grub efibootmgr bash-completion networkmanager
fi

if [ "$dewm" == "3" ] || [ "$dewm" == "3)" ];
then
	pacstrap /mnt base base-devel linux linux-firmware linux-headers vim vi grub efibootmgr xorg ttf-ubuntu-font-family ttf-hack ttf-dejavu ttf-opensans bash-completion networkmanager sddm plasma
fi

if [ "$dewm" == "4" ] || [ "$dewm" == "4)" ];
then
	pacstrap /mnt base base-devel linux linux-firmware linux-headers vim vi grub efibootmgr xorg ttf-ubuntu-font-family ttf-hack ttf-dejavu ttf-opensans bash-completion networkmanager gnome
fi

 if [ "$(ls /mnt/etc/pacman.d/mirrorlist)" == "/mnt/etc/pacman.d/mirrorlist"];
then
	rm /mnt/etc/pacman.d/mirrorlist
 	cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlsit
else
	cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
fi

cat archroot.sh | arch-chroot /mnt bash


umount -R /mnt
reboot
