#!/bin/bash
echo "Corriendo en arch-chroot"
echo "Define una contraseña para el usuario root"
passwd
user=""
echo "Escribe un usuario para tu sistema"
while [ "$user" = "" ]; do
  user=$(gum input --placeholder "Usuario")
done
useradd -m $user
echo "Contraseña para el nuevo usuario"
passwd $user
echo "Añadiendote al grupo wheel"
usermod -aG wheel $user
echo "Edita manualmente la region que quieras compilar"
echo "Pulsa cualquier tecla"
read
nano /etc/locale.gen
echo "Si no descomentaste alguna region aparecera un error"
locale-gen
localerr="$?"
if [ "$localerr" -gt 0 ]; do
  echo "Un error ha ocurrido, volviendo a abrir"
  while [ "$localerr" -eq 0 ]; do
    nano /etc/locale.gen
    locale-gen
    localerr="$?"
  done
fi
echo "Quieres cargar una distribucion de teclado?"
yes_no=$(gum choice "Si" "No")

if [ "$yes_no" = "Si" ]; then
  choice=$(gum input --placeholder "Distro. teclado")
  while [ "$choice" = "" ]; do
    choice=$(gum input --placeholder "Distro. teclado")
  done
  loadkeys $choice
  echo "Guardando..."
  echo "KEYMAP=$choice" > /etc/vconsole.conf
fi
echo "Instalando grub..."
pacman -S efibootmgr
grub-install $(cat /mnt/main_disk)
grub-mkconfig -o /boot/grub/grub.cfg
echo "Define el nombre de tu maquina (arch, $user, etc)"
hostname=$(gum input --placeholder "Hostname")
echo $hostname > /etc/hostname
echo "# Static table lookup for hostnames.\n# See hosts(5) for details.\n\n127.0.0.1         localhost\n::1               localhost\n127.0.0.1         $hostname.localhost $hostname" > /etc/hosts
exit
