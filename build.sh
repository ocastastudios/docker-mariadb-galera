# Set correct environment variables.
set -ex

export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive
export TERM=dumb

# WORKAROUND for docker build errors
ln -s -f /bin/true /usr/bin/chfn

# Install MariaDB
apt-get install software-properties-common
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirror.sax.uk.as61049.net/mariadb/repo/10.1/ubuntu xenial main'

apt-get -y update
apt-get -y install wget
wget "https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb"
dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb
apt-get -y update
apt-get --no-install-recommends -y upgrade

apt-get --no-install-recommends install -y iproute mariadb-server galera-3 pv iputils-ping net-tools jq percona-xtrabackup-24 socat nmap
apt-get -y autoremove
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*