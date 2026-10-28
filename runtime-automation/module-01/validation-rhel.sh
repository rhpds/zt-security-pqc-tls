#!/bin/sh
echo "Validating module-01" >> /tmp/progress.log

# Objective: confirm this is a RHEL 10 host that can do post-quantum TLS.

if ! grep -q "release 10" /etc/redhat-release 2>/dev/null; then
    echo "FAIL: this does not look like a RHEL 10 system"
    echo "HINT: this lab requires Red Hat Enterprise Linux 10.1 or later. Contact lab support."
    exit 1
fi

if ! command -v openssl > /dev/null 2>&1; then
    echo "FAIL: openssl not found"
    echo "HINT: OpenSSL should be pre-installed. Contact lab support."
    exit 1
fi

if ! openssl list -tls-groups 2>/dev/null | grep -qi "X25519MLKEM768"; then
    echo "FAIL: OpenSSL does not offer the post-quantum TLS group X25519MLKEM768"
    echo "HINT: this requires RHEL 10.1+ with OpenSSL 3.5 and the DEFAULT crypto-policy. Contact lab support."
    exit 1
fi

if ! command -v nginx > /dev/null 2>&1; then
    echo "FAIL: nginx not found"
    echo "HINT: nginx should be installed by lab setup. Contact lab support."
    exit 1
fi

echo "PASS: module-01 objectives verified (RHEL 10, OpenSSL post-quantum TLS group, nginx present)"
exit 0
