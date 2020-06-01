#!/bin/sh

set -e
set -u

export DEBIAN_FRONTEND=noninteractive

install_base() {
	apt-get update
	apt-get install -y \
    	apt-transport-https \
    	ca-certificates \
    	curl wget \
    	git git-flow \
    	vim \
    	gnupg2 \
    	software-properties-common \
    	libssl-dev libreadline-dev zlib1g-dev
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

install_asdf() {
	su - vagrant -c "rm -fr ~/.asdf"
	su - vagrant -c 'git clone https://github.com/asdf-vm/asdf.git ~/.asdf '\
		'&& cd ~/.asdf '\
		'&& git checkout "$(git describe --abbrev=0 --tags)"'

	set -x
	su - vagrant -c "sed -i '/^## BEGIN ASDF/,/^## END ASDF/d' ~/.bashrc"
	su - vagrant -c "echo '## BEGIN ASDF' >> ~/.bashrc"
	su - vagrant -c 'echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc'
	su - vagrant -c 'echo ". $HOME/.asdf/completions/asdf.bash" >> ~/.bashrc'
	su - vagrant -c "echo '## END ASDF' >> ~/.bashrc"
	set +x
}

asdf_install() {
	language="${1:-}"
	version="${2:-}"

	if [ -z "$language" ]; then return ; fi
	if [ -z "$version" ]; then return ; fi

	set -x
	su - vagrant -c '. $HOME/.asdf/asdf.sh && asdf plugin-add '"$language"' || true'
	su - vagrant -c '. $HOME/.asdf/asdf.sh && asdf plugin-update '"$language"' || true'
	su - vagrant -c '. $HOME/.asdf/asdf.sh && asdf list-all '"$language"' >/dev/null 2>&1'
	su - vagrant -c '. $HOME/.asdf/asdf.sh && asdf install '"$language"' '"$version"
	set +x
}

asdf_global() {
	language="${1:-}"
	version="${2:-}"

	if [ -z "$language" ]; then return ; fi
	if [ -z "$version" ]; then return ; fi

	su - vagrant -c '. $HOME/.asdf/asdf.sh && asdf global '"$language"' '"$version"
}

install_base
install_docker
install_docker_compose
install_asdf

asdf_install ruby 2.6.5
asdf_install python 3.8.3

asdf_global ruby 2.6.5
asdf_global python 3.8.3

echo "SUCCESS."

