#!/bin/zsh
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
echo "Si no descomentaste alguna region se compilara normalmente"
echo "Puedes editar manualmente la region editando con cualquier editor de texto el archivo /etc/locale.gen"
locale-gen
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
python3 post-inst.py $hostname
echo "Instalando un gestor de paqueter AUR"
choice=$(gum choose "yay" "paru")
if [ $choice = "yay" ]; do
  git clone https://github.com/Jguer/yay.git
  cd yay && makepkg -si
else
  git clone https://github.com/Morganamilo/paru.git
  cd paru && makepkg -si
fi

exit
