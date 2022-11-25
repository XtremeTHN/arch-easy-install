from os import system as execute
from sys import argv

if argv[1] == "paru":
    execute("git clone https://github.com/Morganamilo/paru.git")
    execute("cd paru && makepkg -si")
    sys.exit(0)
elif argv[1] == "yay":
    execute("git clone https://github.com/Jguer/yay.git")
    execute("cd yay && makepkg -si")
    sys.exit(0)
sys.exit(1)
