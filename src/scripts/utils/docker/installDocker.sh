#!/bin/bash

CLUSTER_USER=''
while getopts ":u:" opt; do
  case $opt in
    u)
      CLUSTER_USER=$OPTARG
      ;;
    \?)
      echo " " 1>&2
      echo "Invalid use of the installer" 1>&2
      echo "Usage e.g. [-u heron]" 1>&2
      echo "-u [optional] HDI cluster user name" 1>&2
      echo " " 1>&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." 1>&2
      exit 1
      ;;
  esac
done

mv /etc/apt/sources.list.d/HDP.list /etc/apt/
apt-get update
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
apt-get install -y docker-engine
mv /etc/apt/HDP.list  /etc/apt/sources.list.d/

if [ ! -z "$CLUSTER_USER" ];
then
    usermod -aG docker $CLUSTER_USER
fi
