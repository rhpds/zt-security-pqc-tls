#!/bin/sh
echo "Solving module-01" >> /tmp/progress.log

# Module-01 is the overview. It has no participant commands beyond optional
# exploration; show the environment facts the module describes.
cat /etc/redhat-release
openssl version
openssl list -tls-groups | grep -i mlkem

echo "Solved module-01" >> /tmp/progress.log
exit 0
