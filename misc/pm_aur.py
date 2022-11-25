from os import system as execute
from sys import argv

if argv[1] == "paru":
    execute(f"su {argv[1]} ./inst_paru.sh")
    sys.exit(0)
elif argv[1] == "yay":
    execute(f"su {argv[1]} ./inst_yay.sh")
    sys.exit(0)
sys.exit(1)
