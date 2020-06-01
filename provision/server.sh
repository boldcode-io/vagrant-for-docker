#!/bin/sh

set -e
set -u

export DEBIAN_FRONTEND=noninteractive

install_base() {
	apt-get update
	apt-get install -y \
    	apt-transport-https \
    	ca-certificates \
    	curl \
    	wget \
    	vim \
    	gnupg2 \
    	software-properties-common
}

install_docker() {
	# Add Docker’s official GPG key:
	curl -fsSL https://download.docker.com/linux/debian/gpg \
		| sudo apt-key add -

	add-apt-repository \
   		"deb [arch=amd64] https://download.docker.com/linux/debian \
   		$(lsb_release -cs) \
   		stable"
	apt-get update

	# Install the latest version of Docker CE and containerd
	apt-get install -y docker-ce docker-ce-cli containerd.io

	if ! grep '^docker:' /etc/group ; then
		addgroup docker
	fi

	if ! grep '^docker:.*vagrant' /etc/group ; then
		adduser vagrant docker
	fi
}

install_docker_compose() {
	# Install docker-compose
	sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" \
		-o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
}

install_base
install_docker
install_docker_compose

echo "SUCCESS."

