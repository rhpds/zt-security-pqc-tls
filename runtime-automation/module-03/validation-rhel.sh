#!/bin/sh
echo "Validating module-03" >> /tmp/progress.log

# Objective: the nginx service is running and reachable over HTTPS, currently
# negotiating the CLASSICAL X25519 group (the baseline).

# 1) The nginx service is active.
if ! systemctl is-active --quiet nginx; then
    echo "FAIL: the nginx service is not running"
    echo "HINT: start it with 'sudo systemctl enable --now nginx' (test first with 'sudo nginx -t')."
    exit 1
fi

# 2) The app answers over HTTPS (classical client).
CODE=$(curl -k -s -o /dev/null -w '%{http_code}' https://localhost/ 2>/dev/null)
if [ "$CODE" != "200" ]; then
    echo "FAIL: HTTPS request to https://localhost/ returned '$CODE', expected 200"
    echo "HINT: check 'sudo systemctl status nginx' and 'sudo journalctl -u nginx'."
    exit 1
fi

# 3) The negotiated key exchange is the classical X25519 (baseline, pre-PQC).
if ! echo | openssl s_client -connect localhost:443 2>/dev/null | grep -q 'Negotiated TLS1.3 group: X25519$'; then
    echo "FAIL: the server did not negotiate the classical X25519 group as expected"
    echo "HINT: in this baseline module the server should offer only X25519 (see /etc/nginx/conf.d/pqc-web.conf)."
    exit 1
fi

echo "PASS: module-03 objectives verified (nginx running, HTTPS up, classical X25519 negotiated)"
exit 0
