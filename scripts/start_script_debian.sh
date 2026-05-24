if [ ! -f /etc/resolv.conf ]; then
    echo 'nameserver 172.20.1.22' > /etc/resolv.conf
fi

tee /tmp/payload.json <<EOF
{
  "role_id": "$ROLEID",
  "secret_id": "$SECRETID"
}
EOF

if [[ $CHANGED -eq "true" ]] 
then 
echo -e "$SSH_KEYS" > $KEY_PATH
fi
rm -rf /tmp/payload.json

mkdir /etc/ssh/auth_principals /root/.ssh
printf "nikou  ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nikou
printf 'root' > /etc/ssh/auth_principals/root
printf 'root,nikou' > /etc/ssh/auth_principals/nikou
usermod -s /bin/bash $USERNAME
systemctl restart sshd


hostnamectl set-hostname $VMNAME
export VMSNAME=${VMNAME%%.*}
sed  -i '/127.0.1.1/d' /etc/hosts
sed -ie "/127.0.0.1 localhost/a 127.0.1.1 $VMNAME $VMSNAME" /etc/hosts
