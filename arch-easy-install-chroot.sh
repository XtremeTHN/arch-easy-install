#!/bin/bash
echo "Corriendo en arch-chroot"
root_pass=""
while [ "$root_pass" == "" ]; do
  echo "Define una contraseña para root, debe ser dificil de adivinar"
  root_pass=$(gum input --placeholder Contraseña)
done
