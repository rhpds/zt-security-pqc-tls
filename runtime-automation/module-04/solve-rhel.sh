#!/bin/sh
echo "Solving module-04" >> /tmp/progress.log

# Participant commands for module-04 (observational): show the app works for a
# classical client, then watch a post-quantum-requiring client fail against
# Bill's classical-only server.
echo "--- normal (classical) client, should succeed ---"
curl -k https://localhost/
echo "--- post-quantum-requiring client, should FAIL ---"
curl -k --curves X25519MLKEM768 https://localhost/ || echo "post-quantum-required connection refused, as expected"
echo "--- openssl diagnosis of the failure ---"
echo | openssl s_client -connect localhost:443 -groups X25519MLKEM768 2>&1 | grep -iE "alert|handshake|failure|group" || true
echo "--- service logs ---"
journalctl -u nginx --no-pager -n 20

echo "Solved module-04" >> /tmp/progress.log
exit 0
