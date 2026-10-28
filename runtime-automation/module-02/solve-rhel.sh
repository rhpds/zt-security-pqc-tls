#!/bin/sh
echo "Solving module-02" >> /tmp/progress.log

# Participant commands for module-02: inspect the PQC-for-TLS foundation (read-only).
cat /etc/redhat-release
openssl version
update-crypto-policies --show
openssl list -tls-groups | grep -i mlkem

echo "Solved module-02" >> /tmp/progress.log
exit 0
