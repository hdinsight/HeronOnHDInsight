#!/bin/bash

# Import installer helper method module.
HDI_HELPER_FILE_NAME=HDInsightUtilities-v01.sh
HDI_HELPER_SOURCE=https://hdiconfigactions.blob.core.windows.net/linuxconfigactionmodulev01
echo "Downloading helper functions: $HDI_HELPER_SOURCE/$HDI_HELPER_FILE_NAME"
wget -O /tmp/$HDI_HELPER_FILE_NAME -q $HDI_HELPER_SOURCE/$HDI_HELPER_FILE_NAME && source /tmp/$HDI_HELPER_FILE_NAME && rm -f /tmp/$HDI_HELPER_FILE_NAME


#########################################
# Data node specific actions below
#########################################
if [ `test_is_datanode` == 1 ]; then
    echo "This is a data node. Installing required packages "
    apt-get install libunwind-setjmp0-dev -y
    exit 0
fi

#########################################
# Head node specific actions below
#########################################

# Parse options to the installer, zookeeper host and heron version to be installed
ZK_HOSTS="zk0-heron"
HERON_VERSION="0.14.4"
OVERWRITE=false
while getopts ":z:v:f" opt; do
  case $opt in
    z)
      ZK_HOSTS=$OPTARG
      ;;
    v)
      HERON_VERSION=$OPTARG
      ;;
    f)
      OVERWRITE=true
      ;;
    \?)
      echo " " 1>&2
      echo "Invalid use of the installer" 1>&2 
      echo "Usage e.g. [-z zk0-heron] [-v 0.14.4.SNAPSHOT] [-f]" 1>&2
      echo "-z zookeeper host" 1>&2
      echo "-v heron installer version" 1>&2
      echo "-f force overwrite existing installation" 1>&2
      echo " " 1>&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." 1>&2
      exit 1
      ;;
  esac
done
echo "ZK_HOSTS=$ZK_HOSTS"
echo "HERON_VERSION=$HERON_VERSION"


# Prepare target install directory
TARGET_INSTALL_DIR=/usr/heron
echo "TARGET_INSTALL_DIR=$TARGET_INSTALL_DIR"
if [ -e $TARGET_INSTALL_DIR ]; then
  echo "Heron is already installed."
  if [ "$OVERWRITE" = "true" ]; then
    echo "Overwriting existing installation."
  else
    echo "Exiting"
    exit 1
  fi
else
  mkdir "$TARGET_INSTALL_DIR"
fi


# Fetch and install heron client and tools
DOWNLOAD_SOURCE_URL="https://github.com/twitter/heron/releases/download/$HERON_VERSION/"
HERON_CLIENT_INSTALLER="heron-client-install-$HERON_VERSION-ubuntu.sh"
HERON_TOOLS_INSTALLER="heron-tools-install-$HERON_VERSION-ubuntu.sh"

echo "Downloading and installing Heron client: $DOWNLOAD_SOURCE_URL/$HERON_CLIENT_INSTALLER"
download_file $DOWNLOAD_SOURCE_URL/$HERON_CLIENT_INSTALLER /tmp/$HERON_CLIENT_INSTALLER
chmod +x /tmp/$HERON_CLIENT_INSTALLER
/tmp/$HERON_CLIENT_INSTALLER --prefix=$TARGET_INSTALL_DIR --heronrc=$TARGET_INSTALL_DIR/.heronrc
rm -f /tmp/$HERON_CLIENT_INSTALLER

echo "Downloading and installing Heron tools: $DOWNLOAD_SOURCE_URL/$HERON_TOOLS_INSTALLER"
download_file $DOWNLOAD_SOURCE_URL/$HERON_TOOLS_INSTALLER /tmp/$HERON_TOOLS_INSTALLER
chmod +x /tmp/$HERON_TOOLS_INSTALLER
/tmp/$HERON_TOOLS_INSTALLER --prefix=$TARGET_INSTALL_DIR
rm -f /tmp/$HERON_TOOLS_INSTALLER

echo "Creating links to Heron binaries."
ln -sf $TARGET_INSTALL_DIR/bin/heron /usr/bin/heron
ln -sf $TARGET_INSTALL_DIR/bin/heron-tracker /usr/bin/heron-tracker
ln -sf $TARGET_INSTALL_DIR/bin/heron-ui /usr/bin/heron-ui


# Customize heron config files for this cluster
STATE_MANAGER_CONF_FILE="$TARGET_INSTALL_DIR/heron/conf/yarn/statemgr.yaml"
echo "Creating state manager conf file: $STATE_MANAGER_CONF_FILE"
cat > $STATE_MANAGER_CONF_FILE <<EOL
heron.class.state.manager: com.twitter.heron.statemgr.zookeeper.curator.CuratorStateManager
heron.statemgr.connection.string: $ZK_HOSTS:2181
heron.statemgr.root.path: "/heron"
heron.statemgr.zookeeper.is.initialize.tree: True
heron.statemgr.zookeeper.session.timeout.ms: 30000
heron.statemgr.zookeeper.connection.timeout.ms: 30000
heron.statemgr.zookeeper.retry.count: 10
heron.statemgr.zookeeper.retry.interval.ms: 10000
EOL

TOOLS_CONF_FILE="$TARGET_INSTALL_DIR/herontools/conf/heron_tracker.yaml"
echo "Creating tools conf file: $TOOLS_CONF_FILE"
cat > $TOOLS_CONF_FILE <<EOL
statemgrs:
  -
    type: "zookeeper"
    name: "remotezk"
    hostport: $ZK_HOSTS:2181
    rootpath: "/heron"
    tunnelhost: "localhost"
EOL


# REMOVE_ME
HADOOP_CONF_DIR="/etc/hadoop/conf"
echo "HADOOP_CONF_DIR=$HADOOP_CONF_DIR"
# Copy jars needed by client till heron supports classpaths
TEMP_CLASSPATH_DIR=$TARGET_INSTALL_DIR/heron/lib/scheduler
cp /usr/hdp/current/hadoop-client/client/jackson-mapper-asl.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/client/jackson-core-asl.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/client/jackson-jaxrs.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/client/jackson-xc.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/client/commons-collections.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/client/commons-configuration.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/client/commons-compress.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/client/commons-logging.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/client/commons-lang.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/client/htrace-core.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/client/avro.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/client/jersey-core.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/client/jersey-client.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/client/netty-all.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/client/jetty-util.jar $TEMP_CLASSPATH_DIR

cp /usr/hdp/current/hadoop-client/lib/azure-storage*.jar $TEMP_CLASSPATH_DIR

cp /usr/hdp/current/hadoop-yarn-client/hadoop-yarn-api.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-yarn-client/hadoop-yarn-client.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-yarn-client/hadoop-yarn-common.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/hadoop-auth.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/hadoop-azure.jar $TEMP_CLASSPATH_DIR
cp /usr/hdp/current/hadoop-client/hadoop-common.jar $TEMP_CLASSPATH_DIR


cp $HADOOP_CONF_DIR/yarn-site.xml . && jar uf $TEMP_CLASSPATH_DIR/hadoop-yarn-common.jar yarn-site.xml && rm yarn-site.xml
cp $HADOOP_CONF_DIR/core-site.xml . && jar uf $TEMP_CLASSPATH_DIR/hadoop-common.jar core-site.xml && rm core-site.xml
chmod +r $TEMP_CLASSPATH_DIR/hadoop-yarn-common.jar $TEMP_CLASSPATH_DIR/hadoop-common.jar
