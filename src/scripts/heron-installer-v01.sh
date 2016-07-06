#!/bin/bash

#CHANGE_ME
DOWNLOAD_SOURCE_URL=/home/heronuser/workspace
echo "DOWNLOAD_SOURCE_URL=$DOWNLOAD_SOURCE_URL"
TARGET_INSTALL_DIR=/usr/hdp/current/heron
echo "TARGET_INSTALL_DIR=$TARGET_INSTALL_DIR"
ZKHOSTS="zk0"
echo "ZKHOSTS=$ZKHOSTS"

HDI_HELPER_FILE_NAME=HDInsightUtilities-v01.sh
echo "Downloading helper functions: $HDI_HELPER_FILE_NAME"
# Import the helper method module.
wget -O /tmp/$HDI_HELPER_FILE_NAME -q https://hdiconfigactions.blob.core.windows.net/linuxconfigactionmodulev01/$HDI_HELPER_FILE_NAME && source /tmp/$HDI_HELPER_FILE_NAME && rm -f /tmp/$HDI_HELPER_FILE_NAME

#REMOVE_ME
shopt -s expand_aliases
alias download_file=cp

# In case Heron is installed, exit.
if [ -e $TARGET_INSTALL_DIR ]; then
    echo "Heron is already installed, exiting ..."
    exit 0
fi
mkdir $TARGET_INSTALL_DIR

# Download Heron binary to temporary location.
HERON_CLIENT_INSTALLER=heron-client-install.sh
echo "Downloading and install Heron client: $HERON_CLIENT_INSTALLER"
download_file $DOWNLOAD_SOURCE_URL/$HERON_CLIENT_INSTALLER /tmp/$HERON_CLIENT_INSTALLER 
chmod +x /tmp/$HERON_CLIENT_INSTALLER 
/tmp/$HERON_CLIENT_INSTALLER --prefix=$TARGET_INSTALL_DIR --heronrc=$TARGET_INSTALL_DIR/.heronrc
rm -f /tmp/$HERON_CLIENT_INSTALLER

HERON_TOOLS_INSTALLER=heron-tools-install.sh
echo "Downloading and install Heron tools: $HERON_TOOLS_INSTALLER"
download_file $DOWNLOAD_SOURCE_URL/$HERON_TOOLS_INSTALLER /tmp/$HERON_TOOLS_INSTALLER
chmod +x /tmp/$HERON_TOOLS_INSTALLER 
/tmp/$HERON_TOOLS_INSTALLER --prefix=$TARGET_INSTALL_DIR 
rm -f /tmp/$HERON_TOOLS_INSTALLER

echo "Creating links to Heron binaries."
ln -sf $TARGET_INSTALL_DIR/bin/heron /usr/bin/heron

# Customize heron config files for this cluster
STATE_MANAGER_CONF_FILE=$TARGET_INSTALL_DIR/heron/conf/reef/statemgr.yaml
echo "Creating state manager conf file: $STATE_MANAGER_CONF_FILE"
cat > $STATE_MANAGER_CONF_FILE <<EOL
heron.class.state.manager: com.twitter.heron.statemgr.zookeeper.curator.CuratorStateManager
heron.statemgr.connection.string: $ZKHOSTS:2181 
heron.statemgr.root.path: "/heron"
heron.statemgr.zookeeper.is.initialize.tree: True
heron.statemgr.zookeeper.session.timeout.ms: 30000
heron.statemgr.zookeeper.connection.timeout.ms: 30000
heron.statemgr.zookeeper.retry.count: 10
heron.statemgr.zookeeper.retry.interval.ms: 10000
EOL

TOOLS_CONF_FILE=$TARGET_INSTALL_DIR/herontools/conf/heron_tracker.yaml
echo "Creating tools conf file: $TOOLS_CONF_FILE"
cat > $TOOLS_CONF_FILE <<EOL
statemgrs:
  -
    type: "zookeeper"
    name: "local"
    host: $ZKHOSTS
    port: 2181
    rootpath: "/heron"
    tunnelhost: "localhost"
EOL

# REMOVE_ME
# Copy jars needed by client till heron supports classpaths
TEMP_CLASSPATH_DIR=$TARGET_INSTALL_DIR/heron/lib/scheduler
cp /usr/hdp/current/hadoop-client/lib/jackson-mapper-asl-1.9.13.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/lib/commons-collections-3.2.2.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/lib/commons-configuration-1.6.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/lib/commons-logging-1.1.3.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/lib/commons-compress-1.4.1.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/lib/htrace-core-3.1.0-incubating.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/lib/commons-lang-2.6.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/lib/avro-1.7.4.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/lib/jackson-core-asl-1.9.13.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/lib/jackson-jaxrs-1.9.13.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/lib/jackson-xc-1.9.13.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/lib/jersey-core-1.9.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-yarn-client/lib/jersey-client-1.9.jar $TEMP_CLASSPATH_DIR

cp /usr/hdp/current/hadoop-yarn-client/hadoop-yarn-api.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-yarn-client/hadoop-yarn-client.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-yarn-client/hadoop-yarn-common.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/hadoop-auth.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/hadoop-azure.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/hadoop-common.jar $TEMP_CLASSPATH_DIR

cp /usr/hdp/2.4.1.1-3/hadoop/client/netty-all-4.0.23.Final.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/2.4.1.1-3/hadoop/client/jetty-util.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/2.4.1.1-3/hadoop/lib/azure-storage-2.2.0.jar $TEMP_CLASSPATH_DIR

cp $HADOOP_CONF_DIR/yarn-site.xml . && jar uf $TEMP_CLASSPATH_DIR/hadoop-yarn-common.jar yarn-site.xml && rm yarn-site.xml
cp $HADOOP_CONF_DIR/core-site.xml . && jar uf $TEMP_CLASSPATH_DIR/hadoop-common.jar core-site.xml && rm core-site.xml
chmod +r $TEMP_CLASSPATH_DIR/hadoop-yarn-common.jar $TEMP_CLASSPATH_DIR/hadoop-common.jar
