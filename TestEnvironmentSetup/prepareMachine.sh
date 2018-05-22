apt-get update -y
apt-get install -y software-properties-common libssl-dev
pip3 install  sleekxmpp==1.3.1  
apt-get install -y python3.5 python3-pip python-dev
pip3 install  sleekxmpp==1.3.1  
pip3 install  psutil pystun
apt-get install -y openvswitch-switch
mkfs -t ext4 /dev/xvda4
mkdir /mnt/mydrive
mount -t ext4 /dev/xvda4 /mnt/mydrive
chmod -Rv 777 /mnt/mydrive
chown -R sam /mnt/mydrive

apt-get -y install lxc lxc-templates wget bridge-utils
echo "lxc.lxcpath=/mnt/mydrive/Linuxcontainers" > /etc/lxc/lxc.conf
mkdir -p /mnt/mydrive/Linuxcontainers
systemctl restart lxc
lxc-create -n ubuntu_lxc -t ubuntu

cat>>/mnt/mydrive/Linuxcontainers/ubuntu_lxc/config<<EOL
# custom network config
lxc.network.type = veth
lxc.network.name = camera
lxc.network.flags = up
lxc.network.veth.pair = camera

# custom network config
lxc.network.type = veth
lxc.network.name = compute
lxc.network.flags = up
lxc.network.veth.pair = compute
EOL

lxc-start -n ubuntu_lxc
lxc-attach -n ubuntu_lxc -- echo "nameserver 127.0.0.1" | sudo tee -a /mnt/mydrive/Linuxcontainers/ubuntu_lxc/rootfs/etc/resolvconf/resolv.conf.d/head > /dev/null
lxc-attach -n ubuntu_lxc -- resolvconf -u


apt-get remove docker docker-engine docker.io
apt-get install -y \
	apt-transport-https \
	ca-certificates \
		curl \
		software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  apt-key add -

add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable"
apt-get update 
apt-get install -y docker-ce
systemctl stop docker
sed -i '/ExecStart/c\ExecStart=/usr/bin/dockerd -g /mnt/mydrive/docker/ -H fd://' /lib/systemd/system/docker.service
mkdir -p /mnt/mydrive/docker
systemctl daemon-reload
systemctl start docker
usermod -aG docker $USER
su -
su - $USER
cd ~