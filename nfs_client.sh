#!/bin/bash
yum install nfs-utils nano -y
systemctl enable firewalld --now

echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab         # добавляем строку в /etc/fstab         # добавляем строку в /etc/fstab

systemctl daemon-reload                     # перезапускаем службы
systemctl restart remote-fs.target