#!/bin/sh

set -e

echo "launching... (${SIP_USERNAME}, ${ARI_USERNAME})"

cat > /usr/local/asterisk/etc/asterisk/pjsip.custom.conf <<EOF
[outbound-auth]
type=auth
auth_type=userpass
username=${SIP_USERNAME}
password=${SIP_PASSWORD}
EOF

cat > /usr/local/asterisk/etc/asterisk/ari.custom.conf <<EOF
[$ARI_USERNAME]
type = user
read_only = no
password = $ARI_PASSWORD
password_format = plain
EOF

exec /usr/local/asterisk/sbin/asterisk -c -q -p -m -f
