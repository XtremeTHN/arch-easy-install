#!/usr/bin/zsh
if [ "$(id -nu)" != "root" ]; then
	sudo -k
	echo "[x] No hay permisos de superusuario activos, solicitando"
	PASS=$(gum input --placeholder "Contraseña de tu usuario")
	exec sudo -S -p '' "$0" "$@" <<< "$PASS"
	exit 1
fi

RED="\x1b[31m"
RESET="\x1b[0m"
echo "Bienvenido al script de instalacion BSPWM, comenzará la instalacion automaticamente"
ping -c 1 google.com > /dev/null
if [ "$?" -gt 0 ]; then

  if [ -e "/tmp/ssid_tmp" ]; then
	  echo "Utilizar internet introducido anteriormente?"
	  if [ $(gum choose "Si" "No") = "Si" ]; then
		  iwctl station wlan0 connect $SSID password $WIFI_PASS
	  fi
  fi
  echo "Introduce el nombre del internet (SSID)"
  SSID=$(gum input --placeholder "Nombre del internet")
  echo "Introduce la contraseña de tu internet"
  if [ "$SSID" = "" ]; then
    echo "Nombre de internet no especificado, saliendo"
    exit
  fi
  WIFI_PASS=$(gum input --placeholder "Contraseña")
  if [ "$WIFI_PASS" = "" ]; then
    echo "Contraseña no especificada, saliendo"
    exit
  fi
  echo "Se conectara a internet mediante iwctl (dhcpcd)"
  echo $SSID > /tmp/ssid_tmp
  echo $WIFI_PASS > /tmp/wifi_tmp

  iwctl station wlan0 connect $SSID password $WIFI_PASS

  if [ "$?" -gt 0 ]; then
	  echo "$RED [ERR] $RESET Ha habido un problema al conectarse al internet"
	  exit
  fi

  ping -c 1 www.google.com > /dev/null

  if [ "$?" -eq 2 ]; then
    echo "$RED [ERR] $RESET Has introducido una contraseña incorrecta, SSID incorrecto o no hay internet, sin internet no se podran descagar los paquetes, saliendo... "
    exit
  fi
fi
gum confirm "Se formateara el disco que selecciones y los archivos seran eliminados, ¿Deseas continuar?"

echo "Las particiones tendrás que crearlas manualmente, predeterminadamente solo se ocupan 3 particiones, una particion para la raiz del sistema, una para el booteo y otra para archivos de intercambio (swap)"
cfdisk
echo "Particion principal"
sd=$(gum input --placeholder "/dev/sda(1,2,3..)")
echo "Particion boot"
sdB=$(gum input --placeholder "/dev/sda(1,2,3..)")
echo "Particion swap"
sdS=$(gum input --placeholder "/dev/sda(1,2,3..)")

echo "Formato de la particion principal?"
format=$(gum choose "btrfs" "ext4")
if [ "$format" = "btrfs" ]; then
	mkfs.btrfs -f $sd
fi

if [ format = "ext4" ]; then
  mkfs.ext4 $sd
fi
mkfs.vfat -F 32 $sdB
mkswap $sdS
swapon

echo "Comenzando instalacion automatizada..."
mount $sd /mnt
mount --mkdir $sdB /mnt/boot
mount --mkdir $sdB /mnt/boot/efi
echo "Paquetes a instalar: linux linux-firmware linux-headers networkmanager grub wpa_supplicant base base-devel"
echo "Deseas instalar paquetes adicionales?"
choice=$(gum choose "Si" "No")
if [ $choice = "Si" ]; then
  echo "Escribelos separados por espacios"
  aditional_pkgs=$(gum input --placeholder "Paquetes")
fi
pacstrap /mnt linux linux-firmware linux-headers networkmanager grub wpa_supplicant base base-devel gum $additional_pkgs
if [ $? -gt 0 ]; then
  echo "$RED [x] $RESET Se ha producido un error al crear la raiz del sistema e/o instalar los paquetes"
  exit
fi
echo "Creando tabla de particiones"
genfstab -U /mnt > /mnt/etc/fstab
echo "Ejecutando segunda parte en chroot..."
mv arch-easy-install-chroot /mnt
arch-chroot /mnt sh arch-easy-install-chroot.sh
echo "Instalado correctamente"
echo "Puedes reiniciar"
exit
