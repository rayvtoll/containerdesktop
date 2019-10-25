#!/bin/sh

/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf &

chown -R $USER:$USER /home/$USER
useradd -m -s /bin/bash $USER ; echo $USER:$USER | chpasswd

rm -rf /home/$USER/.ssh/*
mkdir -p /home/$USER/.ssh
ssh-keygen -b 2048 -t rsa -f /home/$USER/.ssh/id_rsa -q -N ""

cp /etc/skel/.* /home/$USER/
cp -r /etc/skel/.config /home/$USER/
HOME=/home/$USER

chown -R $USER:$USER /home/$USER

cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
dpkg-reconfigure -f non-interactive tzdata

echo "rm -f /entrypoint.sh" >> run.sh
echo "tail -f /dev/null" >> run.sh
chmod +x run.sh
sh run.sh