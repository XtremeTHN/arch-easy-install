import sys

text = 
f"""
# Static table lookup for hostnames.
# See hosts(5) for details.

127.0.0.1       localhost
::1             localhost
127.0.0.1       {sys.argv[1]}.localhost {sys.argv[1]}
"""
with open("/etc/hosts","w") as file:
    file.write(text)

