#!/bin/sh
echo "Solving module-05" >> /tmp/progress.log

# Participant commands for module-05: fix the server so it offers the post-quantum
# hybrid group (preferred) with classical fallback, reload nginx, and verify
# post-quantum is negotiated.
grep ssl_ecdh_curve /etc/nginx/conf.d/pqc-web.conf
sed -i 's|ssl_ecdh_curve.*|ssl_ecdh_curve X25519MLKEM768:X25519;|' /etc/nginx/conf.d/pqc-web.conf
grep ssl_ecdh_curve /etc/nginx/conf.d/pqc-web.conf
nginx -t
systemctl reload nginx
sleep 1
echo "--- post-quantum client, should now succeed ---"
curl -k --curves X25519MLKEM768 https://localhost/
echo "--- negotiated group (should be X25519MLKEM768) ---"
echo | openssl s_client -connect localhost:443 -groups X25519MLKEM768 2>/dev/null | grep "Negotiated TLS1.3 group"
echo "--- classical client still works (fallback) ---"
echo | openssl s_client -connect localhost:443 -groups X25519 2>/dev/null | grep "Negotiated TLS1.3 group"

echo "Solved module-05" >> /tmp/progress.log
exit 0
