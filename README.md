# HeronOnHDInsight

Heron is a successor of Apache Storm (stream processing), open sourced by Twitter [[ref]] (http://twitter.github.io/heron). Heron executes user workflows, called topologies [[ref]](http://twitter.      github.io/heron/docs/concepts/topologies/), to process data streams. A Heron topology can be deployed on a YARN cluster on HDInsight using the scripts in this repository.

* Each Heron topology is a long running service, and is deployed as a long running YARN job.
* The YARN scheduler [[ref]] (http://twitter.github.io/heron/docs/operators/deployment/schedulers/yarn/) for Heron is developed using Apache REEF framework [[ref]](http://reef.apache.org/).

> This is work in progress. The installer script and the scheduler for Heron is evolving.

## Sample cluster creation
1. Begin creating a new HDInsight Cluster
2. Select `Standard Storm on Linux (3.4)` cluster type
3. Configure the `Credentials`, desired `Storage account` and cluster size. Heron topology will run on `YARN` nodes which are collocated with `Supervisor` nodes.
4. Select `Optional Configuration -> Script Actions`.
  1. Provide the Heron installer script url: `https://raw.githubusercontent.com/hdinsight/HeronOnHDInsight/master/src/scripts/heron-installer-v01.sh`
  1. The `Nimbus` nodes are the head nodes for a `Storm` cluster. If the `Nimbus` nodes are preferred nodes for Heron client, select `Nimbus`.
  2. Provide a `ZooKeeper` host name in parameters, for e.g. if the cluster name is `heron-test`, `ZooKeeper` host name is `zk0-heron`
3. Create the cluster 
