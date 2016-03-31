set -ux

apk add cloud-init

cat >/etc/conf.d/cloud-init-local <<EOF
rc_after="docker"
EOF

for i in cloud-config cloud-final cloud-init cloud-init-local ; do
  rc-update add $i
done
