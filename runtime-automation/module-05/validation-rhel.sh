#!/bin/sh
echo "Validating module-05" >> /tmp/progress.log

# Objective: the server now offers the post-quantum hybrid group. A post-quantum
# client succeeds and negotiates X25519MLKEM768, AND a classical client still
# works (fallback preserved).

# 1) The config offers the post-quantum hybrid group.
if ! grep -q "X25519MLKEM768" /etc/nginx/conf.d/pqc-web.conf 2>/dev/null; then
    echo "FAIL: /etc/nginx/conf.d/pqc-web.conf does not offer X25519MLKEM768"
    echo "HINT: set 'ssl_ecdh_curve X25519MLKEM768:X25519;' then 'sudo nginx -t' and 'sudo systemctl reload nginx'."
    exit 1
fi

# 2) A post-quantum client succeeds over HTTPS.
CODE=$(curl -k -s -o /dev/null -w '%{http_code}' --curves X25519MLKEM768 https://localhost/ 2>/dev/null)
if [ "$CODE" != "200" ]; then
    echo "FAIL: a post-quantum client got '$CODE' from https://localhost/, expected 200"
    echo "HINT: did you reload nginx after editing the config? Check 'sudo systemctl status nginx'."
    exit 1
fi

# 3) The negotiated group is actually the post-quantum hybrid.
if ! echo | openssl s_client -connect localhost:443 -groups X25519MLKEM768 2>/dev/null | grep -q 'Negotiated TLS1.3 group: X25519MLKEM768'; then
    echo "FAIL: the server did not negotiate X25519MLKEM768"
    echo "HINT: confirm 'ssl_ecdh_curve X25519MLKEM768:X25519;' is set and nginx was reloaded."
    exit 1
fi

# 4) The classical fallback still works.
if ! echo | openssl s_client -connect localhost:443 -groups X25519 2>/dev/null | grep -q 'Negotiated TLS1.3 group: X25519$'; then
    echo "FAIL: the classical X25519 fallback no longer works"
    echo "HINT: in this module keep both groups: 'ssl_ecdh_curve X25519MLKEM768:X25519;'."
    exit 1
fi

echo "PASS: module-05 objectives verified (post-quantum negotiated, classical fallback intact)"
exit 0
