#!/bin/bash
USER=rhel

echo "Adding wheel" > /root/post-run.log
usermod -aG wheel rhel

# Passwordless sudo for the lab user (participant runs sudo nginx -t,
# sudo systemctl restart nginx, and edits /etc/nginx/conf.d with sudo).
echo 'rhel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/rhel-nopasswd
chmod 0440 /etc/sudoers.d/rhel-nopasswd

echo "Setup vm rhel" > /tmp/progress.log
chmod 666 /tmp/progress.log

# --- Post-Quantum TLS lab provisioning (single rhel VM) ---
# On RHEL 10.1+ the post-quantum algorithms are already part of the DEFAULT
# crypto-policy, and OpenSSL 3.5 already offers the X25519MLKEM768 hybrid TLS
# key-exchange group. No packages or policy changes are required for PQC itself.
# The participant brings up a web server running as a systemd service, sees PQC
# break it, then fixes the server so it negotiates X25519MLKEM768.

# Install the web server (runs as a native systemd service) and openssl.
dnf install -y nginx openssl >> /tmp/progress.log 2>&1

# ---------------------------------------------------------------------------
# Lay down the "web application" the participant will run as a service.
#   /etc/nginx/conf.d/pqc-web.conf     -> the file participants edit (TLS groups)
#   /etc/pki/tls/certs|private/pqc-web* -> throwaway self-signed cert
#   /usr/share/nginx/html/index.html   -> the web page
# The nginx service itself is left stopped; the participant enables and starts
# it in module-03.
# ---------------------------------------------------------------------------

# The participant-editable server block. It starts PINNED TO THE CLASSICAL
# X25519 group only -- this is the bug the participant fixes in module-05.
cat > /etc/nginx/conf.d/pqc-web.conf << 'EOF'
server {
    listen              443 ssl;
    server_name         _;

    ssl_certificate     /etc/pki/tls/certs/pqc-web.crt;
    ssl_certificate_key /etc/pki/tls/private/pqc-web.key;
    ssl_protocols       TLSv1.3;

    # TLS key-exchange groups this server is willing to offer.
    # Pinned to the classical X25519 group only -- no post-quantum option.
    ssl_ecdh_curve      X25519;

    root  /usr/share/nginx/html;
    index index.html;
}
EOF
chmod 644 /etc/nginx/conf.d/pqc-web.conf

# The web page.
cat > /usr/share/nginx/html/index.html << 'EOF'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Super-Business Portal</title>
  </head>
  <body>
    <h1>Super-Business Secure Portal</h1>
    <p>If you can read this over HTTPS, the web service is up.</p>
  </body>
</html>
EOF
chmod 644 /usr/share/nginx/html/index.html

# Throwaway self-signed certificate for the lab (clients use curl -k). Placed in
# the standard RHEL PKI paths so it carries the correct SELinux context for nginx.
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout /etc/pki/tls/private/pqc-web.key \
  -out    /etc/pki/tls/certs/pqc-web.crt \
  -subj   "/CN=localhost" -days 3650 >> /tmp/progress.log 2>&1
chmod 600 /etc/pki/tls/private/pqc-web.key
chmod 644 /etc/pki/tls/certs/pqc-web.crt

# Validate the config now so any provisioning problem surfaces at deploy time
# (the participant still starts the service themselves in module-03).
nginx -t >> /tmp/progress.log 2>&1

echo "Lab setup complete" >> /tmp/progress.log
exit 0
