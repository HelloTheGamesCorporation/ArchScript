#!/bin/bash
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
sleep 5
echo "How do you want to partition disk?"
echo "1)Auto(Use a read-made option(for virtual 20GB is required, and for hardware 512GB)"
echo "2)Manually(via cfdisk)"
read -p "Choose your variant: " answer2
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
pacman --init
pacman --refresh-keys

mkfs.vfat /dev/"$answer""1"
mkfs.ext4 /dev/"$answer""2"

mount /dev/"$answer""2" /mnt
mkdir -p /mnt/boot/efi
mount /dev/"$answer""1" /mnt/boot/efi

echo "What do you want?"
echo "1) Xfce4"
echo "2) Clearly system(only tty)"
read -p "What? : " dewm

if [ "$dewm" == "1" ];
then
	pacstrap /mnt base base-devel linux linux-firmware linux-headers vim vi grub efibootmgr sddm xfce4 xorg ttf-ubuntu-font-family ttf-hack ttf-dejavu ttf-opensans bash-completion networkmanager
fi

if [ "$dewm" == "2" ];
then
	pacstrap /mnt base base-devel linux linux-firmware linux-headers vim vi grub efibootmgr xorg ttf-ubuntu-font-family ttf-hack ttf-dejavu ttf-opensans bash-completion networkmanager
fi

cat archroot.sh | arch-chroot /mnt bash


umount -R /mnt
reboot
