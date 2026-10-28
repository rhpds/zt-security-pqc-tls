#!/bin/sh
echo "Validating module-04" >> /tmp/progress.log

# Objective: confirm the participant is at the expected "broken" state before
# fixing it -- the server offers classical TLS only, so a classical client
# succeeds but a post-quantum-requiring client is refused.

# 1) A classical client still works.
CODE=$(curl -k -s -o /dev/null -w '%{http_code}' https://localhost/ 2>/dev/null)
if [ "$CODE" != "200" ]; then
    echo "FAIL: the web app is not reachable for a classical client (got '$CODE')"
    echo "HINT: the nginx service from module-03 should still be running: 'sudo systemctl status nginx'."
    exit 1
fi

# 2) A post-quantum-requiring client is refused (this is the point of the module).
PQCODE=$(curl -k -s -o /dev/null -w '%{http_code}' --curves X25519MLKEM768 https://localhost/ 2>/dev/null || true)
if [ "$PQCODE" = "200" ]; then
    echo "FAIL: a post-quantum-requiring client unexpectedly succeeded"
    echo "HINT: at this stage the server should still be pinned to classical X25519 in /etc/nginx/conf.d/pqc-web.conf."
    echo "      Do not fix it yet -- that happens in the next module."
    exit 1
fi

echo "PASS: module-04 objectives verified (classical works, post-quantum client refused by the classical-only server)"
exit 0
