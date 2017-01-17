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
apt-get --no-install-recommends install -y iproute mariadb-server galera-3 pv iputils-ping net-tools percona-xtrabackup-24 socat nmap curl

# gof3r for s3 commands and go-cron to schedule backups
# need to build gof3r from source as the binary doesnt work
apt-get -y install git
curl -O https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz
tar -xvf go1.6.linux-amd64.tar.gz
mv go /usr/local
ln -s /usr/local/go/bin/go /usr/bin/go
export GOPATH=/usr/local
go get github.com/rlmcpherson/s3gof3r/gof3r

curl -L --insecure https://github.com/odise/go-cron/releases/download/v0.0.7/go-cron-linux.gz | zcat > /usr/local/bin/go-cron
chmod u+x /usr/local/bin/go-cron

# Latest jq
curl -L --insecure https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 > /usr/bin/jq
chmod u+x /usr/bin/jq

apt-get -y autoremove
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

