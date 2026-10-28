#!/bin/sh
echo "Solving module-06" >> /tmp/progress.log

# Participant commands for module-06: harden the server to offer ONLY the
# post-quantum hybrid group, reload nginx, then verify post-quantum works and a
# classical-only client is refused.
sed -i 's|ssl_ecdh_curve.*|ssl_ecdh_curve X25519MLKEM768;|' /etc/nginx/conf.d/pqc-web.conf
grep ssl_ecdh_curve /etc/nginx/conf.d/pqc-web.conf
nginx -t
systemctl reload nginx
sleep 1
echo "--- post-quantum client, should succeed ---"
curl -k --curves X25519MLKEM768 https://localhost/
echo "--- negotiated group (should be X25519MLKEM768) ---"
echo | openssl s_client -connect localhost:443 -groups X25519MLKEM768 2>/dev/null | grep "Negotiated TLS1.3 group"
echo "--- classical-only client, should be REFUSED ---"
curl -k --curves X25519 https://localhost/ || echo "classic-only client refused, as expected"

echo "Solved module-06" >> /tmp/progress.log
exit 0
