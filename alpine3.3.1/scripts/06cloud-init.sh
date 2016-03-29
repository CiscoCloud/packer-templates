set -ux

apk add cloud-init

for i in cloud-config cloud-final cloud-init cloud-init-local ; do
  rc-update add $i
done
