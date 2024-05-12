#!/bin/bash
yum install nfs-utils nano -y               # доустанавливаем компоненты

systemctl enable firewalld --now            # включаем файрволл
firewall-cmd --add-service="nfs3" --add-service="rpc-bind" --add-service="mountd" --permanent   # создаём правило файрволла
firewall-cmd --reload                       # перезапуск файрволла

systemctl enable nfs --now                  # включаем nfs

# создаём директорию, меняем владельца, назначаем права, проверяем
mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload

# пересоздаём файл с параметрамы nfs шары
cat << EOF > /etc/exports
/srv/share 192.168.50.11/32(rw,sync,root_squash)
EOF

exportfs -r                                 # экспортируем ранее созданную директорию