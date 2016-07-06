# HeronOnHDInsight

Heron is a successor of Apache Storm (stream processing), open sourced by Twitter [[ref]] (http://twitter.github.io/heron). Heron executes user workflows, called topologies [[ref]](http://twitter.github.io/heron/docs/concepts/topologies/), to process data streams. A Heron topology can be deployed on a YARN cluster on HDInsight using the scripts in this repository. 

* Each Heron topology is a long running service, and is deployed as a long running YARN job.
* The YARN scheduler [[ref]] (http://ashvina.github.io/heron/docs/operators/deployment/schedulers/yarn/) for Heron is developed using Apache REEF framework [[ref]](http://reef.apache.org/). 

> This is work in progress. The installer script and the scheduler for Heron is evolving. 
