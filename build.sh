# Set correct environment variables.
set -ex

export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive
export TERM=dumb

# WORKAROUND for docker build errors
ln -s -f /bin/true /usr/bin/chfn

# Install MariaDB
apt-get --no-install-recommends install  -y software-properties-common
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
add-apt-repository 'deb [arch=amd64,i386] http://ftp.ddg.lth.se/mariadb/repo/10.1/ubuntu trusty main'

apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
add-apt-repository 'deb http://repo.percona.com/apt trusty main'
apt-get update
apt-get --no-install-recommends -y upgrade

# gof3r for s3 commands and go-cron to schedule backups
apt-get --no-install-recommends install -y iproute mariadb-server galera-3 pv iputils-ping net-tools jq percona-xtrabackup socat nmap curl
curl -L --insecure https://github.com/rlmcpherson/s3gof3r/releases/download/v0.5.0/gof3r_0.5.0_linux_amd64.tar.gz | zcat > /usr/local/bin/gof3r
chmod u+x /usr/local/bin/gof3r

curl -L --insecure https://github.com/odise/go-cron/releases/download/v0.0.6/go-cron-linux.gz | zcat > /usr/local/bin/go-cron
chmod u+x /usr/local/bin/go-cron

apt-get -y autoremove
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

