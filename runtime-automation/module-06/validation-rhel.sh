#!/bin/sh
echo "Validating module-06" >> /tmp/progress.log

# Objective: the server now REQUIRES post-quantum key exchange -- a post-quantum
# client works and negotiates X25519MLKEM768, while a classical-only client is
# refused.

# 1) A post-quantum client succeeds.
CODE=$(curl -k -s -o /dev/null -w '%{http_code}' --curves X25519MLKEM768 https://localhost/ 2>/dev/null)
if [ "$CODE" != "200" ]; then
    echo "FAIL: a post-quantum client got '$CODE' from https://localhost/, expected 200"
    echo "HINT: ensure 'ssl_ecdh_curve X25519MLKEM768;' is set and run 'sudo systemctl reload nginx'."
    exit 1
fi

# 2) The negotiated group is the post-quantum hybrid.
if ! echo | openssl s_client -connect localhost:443 -groups X25519MLKEM768 2>/dev/null | grep -q 'Negotiated TLS1.3 group: X25519MLKEM768'; then
    echo "FAIL: the server did not negotiate X25519MLKEM768"
    echo "HINT: confirm 'ssl_ecdh_curve X25519MLKEM768;' and reload nginx."
    exit 1
fi

# 3) A classical-only client is now refused.
CLCODE=$(curl -k -s -o /dev/null -w '%{http_code}' --curves X25519 https://localhost/ 2>/dev/null || true)
if [ "$CLCODE" = "200" ]; then
    echo "FAIL: the server still accepts a classical-only (X25519) client"
    echo "HINT: set 'ssl_ecdh_curve X25519MLKEM768;' (no classical fallback) and reload nginx."
    exit 1
fi

echo "PASS: module-06 objectives verified (server requires post-quantum key exchange; classical client refused)"
exit 0
