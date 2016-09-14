# HeronOnHDInsight

Heron is a successor of Apache Storm (stream processing), open sourced by Twitter [[ref]] (http://twitter.github.io/heron). Heron executes user workflows, called topologies [[ref]](http://twitter.github.io/heron/docs/concepts/topologies/), to process data streams. A Heron topology can be deployed on a YARN cluster on HDInsight using the scripts in this repository.

* Each Heron topology is a long running service, and is deployed as a long running YARN job.
* The YARN scheduler [[ref]] (http://twitter.github.io/heron/docs/operators/deployment/schedulers/yarn/) for Heron is developed using Apache REEF framework [[ref]](http://reef.apache.org/).

> This is work in progress. The installer script and the scheduler for Heron is evolving.

## Sample cluster creation
1. Create the cluster
  1. Begin creating a new HDInsight Cluster
  2. Select `Standard Storm on Linux (3.4)` cluster type
  3. Configure the `Credentials`, desired `Storage account` and cluster size. Heron topology will run on `YARN` nodes which are collocated with `Supervisor` nodes.
  4. Create the cluster
2. Deploy Heron using `Script Actions` on the clusterSelect `Optional Configuration -> Script Actions`.
  1. Find the Zookeeper hostnames using `Cluster Dashboard` (Ambari dashboard). This information will be needed later.
  2. On the HDInsight Cluster view, select `Script Actions` to initiate Heron installation
  3. Provide the Heron installer script url: `https://raw.githubusercontent.com/hdinsight/HeronOnHDInsight/master/src/scripts/heron-installer-v01.sh`
  4. Select `Nimbus` and `Supervisor` nodes as intallation targets. The script will install Heron client on the `Nimbus` nodes (the head nodes in this case) and install dependencies on the `Supervisor` (worker) nodes.
  5. The script takes the following parameters
    1. Required `ZooKeeper` host name:  `-z <zk_host_name>`, for e.g. `zk0-heron`. Use the value obtained from `Cluster Dashboard` above.
    1. Optional Heron version string:  `-v <version>`, for e.g. ` 0.14.4.SNAPSHOT`. The default value is `0.14.3`
    1. Optional flag to overwrite existing installation:  `-f`
    1. Sample parameter string: `-z zk0-heron -v 0.14.4.SNAPSHOT -f`

## Submit a topology
1. Connect (SSH) to one of the nodes where the Heron client is installed, the `head` nodes in this case.
1. Use the [[Heron CLI]](http://twitter.github.io/heron/docs/operators/heron-cli/) to submit the topology. For e.g. `heron submit yarn /usr/heron/heron/examples/heron-examples.jar com.twitter.heron.examples.ExclamationTopology ExclamationTopology`

## Starting Heron services: UI and Tracker
1. Execute `heron-tracker` and `heron-ui` commands on a `head` nodes.
1. Establish SSH tunnel ([[ref]] (https://azure.microsoft.com/en-us/documentation/articles/hdinsight-linux-ambari-ssh-tunnel/)) to access the Heron dashboard. Access `<ip_of_head_node>:8889`.
