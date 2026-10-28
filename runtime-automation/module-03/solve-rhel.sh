#!/bin/sh
echo "Solving module-03" >> /tmp/progress.log

# Participant commands for module-03: inspect the server config, test it, bring
# the nginx service up, and connect over classical TLS (the baseline).
cat /etc/nginx/conf.d/pqc-web.conf
nginx -t
systemctl enable --now nginx
sleep 1
systemctl status nginx --no-pager
curl -k https://localhost/
echo | openssl s_client -connect localhost:443 2>/dev/null | grep "Negotiated TLS1.3 group"

echo "Solved module-03" >> /tmp/progress.log
exit 0
