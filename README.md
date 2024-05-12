`# На сервере:`

yum install nfs-utils nano -y               # доустанавливаем компоненты
systemctl enable firewalld --now            # включаем файрволл
firewall-cmd --add-service="nfs3" --add-service="rpc-bind" --add-service="mountd" --permanent   # создаём правило файрволла
firewall-cmd --reload                       # перезапуск файрволла


systemctl enable nfs --now                  # включаем nfs

`# проверяем порты tcp и udp 2049, 20048, 111`
ss -tnplu | grep 2049
ss -tnplu | grep 20048
ss -tnplu | grep 111

`[root@nfs-server vagrant]# ss -tnplu | grep 2049`
`udp    UNCONN     0      0         *:2049                  *:*                  `
`udp    UNCONN     0      0      [::]:2049               [::]:*                  `
`tcp    LISTEN     0      64        *:2049                  *:*                  `
`tcp    LISTEN     0      64     [::]:2049               [::]:* `
`[root@nfs-server vagrant]# ss -tnplu | grep 20048`
`udp    UNCONN     0      0         *:20048                 *:*                   users:(("rpc.mountd",pid=3687,fd=7))`
`udp    UNCONN     0      0      [::]:20048              [::]:*                   users:(("rpc.mountd",pid=3687,fd=9))`
`tcp    LISTEN     0      128       *:20048                 *:*                   users:(("rpc.mountd",pid=3687,fd=8))`
`tcp    LISTEN     0      128    [::]:20048              [::]:*                   users:(("rpc.mountd",pid=3687,fd=10))`
`[root@nfs-server vagrant]# ss -tnplu | grep 111  `
`udp    UNCONN     0      0         *:111                   *:*                   users:(("rpcbind",pid=342,fd=6))`
`udp    UNCONN     0      0      [::]:111                [::]:*                   users:(("rpcbind",pid=342,fd=9))`
`tcp    LISTEN     0      128       *:111                   *:*                   users:(("rpcbind",pid=342,fd=8))`
`tcp    LISTEN     0      128    [::]:111                [::]:*                   users:(("rpcbind",pid=342,fd=11))`


`# создаём директорию, меняем владельца, назначаем права, проверяем`
mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload
ls -ld /srv/share/upload

`# пересоздаём файл с параметрамы nfs шары`
cat << EOF > /etc/exports
/srv/share 192.168.50.11/32(rw,sync,root_squash)
EOF

exportfs -r                                 # экспортируем ранее созданную директорию
exportfs -s                                 # проверяем

[root@nfs-server vagrant]# exportfs -s
/srv/share  192.168.50.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)

touch /srv/share/upload/server.txt                            # создаём вспомогательный файл для дальнейшей проверки

На клиенте:

yum install nfs-utils nano -y

systemctl enable firewalld --now            # включаем файрволл
systemctl status firewalld                  # проверяем

`# В методичке, предложенной нам допущена описка`
`# echo "192.168.56.12:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab`
`# меняем на правильную строку`

`# ещё одна ремарка от меня: autofs меня подвёл один раз после одного из обновлений. Из за этого все шары в продакшене отлетели. С тех пор я старообрядец и пользуюсь /etc/fstab`


echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab         # добавляем строку в /etc/fstab

systemctl daemon-reload                     # перезапускаем службы
systemctl restart remote-fs.target

mount | grep mnt                            # проверяем

[root@nfs-client vagrant]# mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=23,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=26272)

`# Проверка работоспособности`

ls -lahd /mnt/upload
ls -lah /mnt/upload/

[root@nfs-client mnt]# ls -lah /mnt/upload/
total 0
drwxrwxrwx. 2 nfsnobody nfsnobody 24 May 12 19:52 .
drwxr-xr-x. 3 nfsnobody nfsnobody 20 May 12 19:45 ..
-rw-r--r--. 1 root      root       0 May 12 19:52 server.txt

touch /mnt/upload/client.txt

`# на сервере проверяем`

[root@nfs-server share]# ls -la ./upload/
total 0
drwxrwxrwx. 2 nfsnobody nfsnobody 42 May 12 19:54 .
drwxr-xr-x. 3 nfsnobody nfsnobody 20 May 12 19:45 ..
-rw-r--r--. 1 nfsnobody nfsnobody  0 May 12 19:54 client.txt
-rw-r--r--. 1 root      root       0 May 12 19:52 server.txt
[root@nfs-server share]#

`# далее, автоматизируем всё скриптами (прилагаются).`
