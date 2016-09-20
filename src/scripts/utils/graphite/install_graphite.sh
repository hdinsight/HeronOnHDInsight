#!/bin/bash

# Graphite installation #
#########################

echo "Installing Graphite backend; carbon and whisper"
pip install https://github.com/graphite-project/ceres/tarball/master
pip install whisper
pip install carbon
pip install service_identity

echo "Preparing config files"
GRAPHITE_HOME=/opt/graphite
cp $GRAPHITE_HOME/aggregation-rules.conf.example   $GRAPHITE_HOME/aggregation-rules.conf
cp $GRAPHITE_HOME/carbon.amqp.conf.example         $GRAPHITE_HOME/carbon.amqp.conf
cp $GRAPHITE_HOME/rewrite-rules.conf.example       $GRAPHITE_HOME/rewrite-rules.conf
cp $GRAPHITE_HOME/storage-schemas.conf.example     $GRAPHITE_HOME/storage-schemas.conf
cp $GRAPHITE_HOME/blacklist.conf.example           $GRAPHITE_HOME/blacklist.conf
cp $GRAPHITE_HOME/carbon.conf.example              $GRAPHITE_HOME/carbon.conf
cp $GRAPHITE_HOME/relay-rules.conf.example         $GRAPHITE_HOME/relay-rules.conf
cp $GRAPHITE_HOME/storage-aggregation.conf.example $GRAPHITE_HOME/storage-aggregation.conf
cp $GRAPHITE_HOME/whitelist.conf.example           $GRAPHITE_HOME/whitelist.conf



# Graphite-web installation #
#############################
echo "Installing Graphite-web and its dependencies"
apt-get install -y libffi-dev python-cairo-dev python-django python-ldap python-memcache python-dev python-setuptools python-pyparsing
pip install cairocffi
pip install django-tagging==0.3.6
pip install graphite-web

echo "Preparing web config files"
cp $GRAPHITE_HOME/dashboard.conf.example           $GRAPHITE_HOME/dashboard.conf
cp $GRAPHITE_HOME/graphTemplates.conf.example      $GRAPHITE_HOME/graphTemplates.conf
cp $GRAPHITE_HOME/webapp/graphite/local_settings.py.example $GRAPHITE_HOME/webapp/graphite/local_settings.py


echo "Next Steps: "
echo "> Verify all dependencies are installed: git clone https://github.com/graphite-project/graphite-web.git , ./check-dependencies.py"
echo "> Start graphite server: $GRAPHITE_HOME/bin/carbon-cache.py start"
echo "> Edit graphite web settings: vi $GRAPHITE_HOME/webapp/graphite/local_settings.py and fix edit SECRET and DATABASES TIME_ZONE CARBONLINK_HOSTS"
echo "> Create web database: PYTHONPATH=$PYTHONPATH:$GRAPHITE_HOME/webapp django-admin syncdb --settings=graphite.settings"
echo "> Start webapp: PYTHONPATH=$PYTHONPATH:$GRAPHITE_HOME/webapp:$GRAPHITE_HOME/storage/whisper ./bin/run-graphite-devel-server.py --port=8085 --libs=$GRAPHITE_HOME/webapp $GRAPHITE_HOME 1>$GRAPHITE_HOME/storage/log/webapp/process.log 2>&1 &"

# cd /tmp
#wget https://grafanarel.s3.amazonaws.com/builds/grafana_3.1.1-1470047149_amd64.deb
#dpkg -i grafana_3.1.1-1470047149_amd64.deb
#service grafana-server start
# /var/log/grafana
# vi /etc/grafana/grafana.ini
# port 3000
