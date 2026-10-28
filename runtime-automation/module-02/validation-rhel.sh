#!/bin/sh
echo "Validating module-02" >> /tmp/progress.log

# Objective: the system crypto policy is DEFAULT-based and OpenSSL offers the
# post-quantum hybrid TLS group X25519MLKEM768.

POLICY=$(update-crypto-policies --show 2>/dev/null)
if ! echo "$POLICY" | grep -q "DEFAULT"; then
    echo "FAIL: crypto policy is '$POLICY', expected a DEFAULT-based policy"
    echo "HINT: run 'update-crypto-policies --show'; on RHEL 10.1+ it should read DEFAULT."
    exit 1
fi

if ! openssl list -tls-groups 2>/dev/null | grep -qi "X25519MLKEM768"; then
    echo "FAIL: OpenSSL does not list the post-quantum TLS group X25519MLKEM768"
    echo "HINT: confirm with 'openssl list -tls-groups | grep -i mlkem'. Requires RHEL 10.1+ OpenSSL 3.5."
    exit 1
fi

echo "PASS: module-02 objectives verified (policy=$POLICY, X25519MLKEM768 available in OpenSSL)"
exit 0
