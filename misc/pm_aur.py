from os import system as execute
from sys import argv
from sys import exit as ex
if argv[1] == "paru":
    execute(f"su {argv[1]} ./inst_paru.sh")
    ex(0)
elif argv[1] == "yay":
    execute(f"su {argv[1]} ./inst_yay.sh")
    ex(0)
ex(1)
