#!/bin/bash

# Check for VM_TYPE. If not given as argument, then it must
# be defined within the environment.
[ ! -z "$1" ] && VM_TYPE=$1

# Enable EPEL
sudo yum -y install epel-release

# Install Packages
sudo yum -y groupinstall "Development Tools"
sudo yum -y install joe figlet puppet facter ruby-shadow dkms kernel-devel wget firewalld && \
	sudo systemctl enable puppet && \
	sudo systemctl start puppet && \
	sudo systemctl enable firewalld && \
	sudo systemctl start firewalld
firewall-cmd --zone=public --permanent --add-service=ssh
firewall-cmd --reload

# Install Virtualbox Guest Additions or VMware OpenVM Tools
# TODO -- need to work on this. #notpretty
if [ $PACKER_BUILDER_TYPE == "virtualbox-iso" ]; then
	echo "Installing Virtualbox Guest Additions; please wait..."
	wget -q http://10.0.2.2:8401/VBoxGuestAdditions.iso
	sudo mount -o loop /home/vagrant/VBoxGuestAdditions.iso /mnt && cd /mnt && \
		sudo ./VBoxLinuxAdditions.run && sudo /etc/init.d/vboxadd setup
	if [ $? -ne 0 ]; then
		echo
		echo "Warning, Virtualbox Guest Additions failed to install properly."
		echo "You may need to install manually."
		echo
	fi
else
	echo "Enabling VMware yum repo; please wait..."
	cat > /etc/yum.repos.d/vmware.repo <<EOF
[vmware-tools]
name = VMware Tools
baseurl = http://packages.vmware.com/packages/rhel7/x86_64/
enabled = 1
gpgcheck = 1
EOF
	
	yum -y update
	
	echo "Installing OpenVM Tools for VMWare; please wait..."
	yum -y install open-vm-tools open-vm-tools-deploypkg
fi

# Write MotD
figlet "CENTOS 7 MINIMAL" > $HOME/.motd
echo "Build Time: `date`" >> $HOME/.motd
sudo mv /home/vagrant/.motd /etc/motd

