.. _automatic_data_balancing:

Automatic Data Balancing on Docker
==================================

This tutorial runs Confluent Auto Data Balancing (ADB) on Kafka, which allows you to shift data to create an even workload across your cluster.  By the end of this tutorial, you will have successfully run Confluent Auto Data Balancing CLI to rebalance data after adding and removing brokers.

.. include:: includes/docker-tutorials.rst
    :start-line: 2

#. Start the services by using the example Docker Compose file.  Navigate to ``cp-docker-images/examples/enterprise-kafka``, where it is located:

   .. codewithvars:: bash

    cd cp-docker-images/examples/enterprise-kafka


#. Start up the services.  The Docker Compose file has configuration for one |zk| and 6 Kafka brokers. These brokers are configured to be on 2 racks. We will first start one rack (with 3 brokers) and create a topic with sample data and run the ADB CLI tool to balance the cluster. After this step, we will walk you through a tutorial for adding another rack of brokers and running the ADB CLI tool to rebalance the data across the new added brokers.

   Start |zk| and first rack of brokers using the Docker Compose commands.

   .. codewithvars:: bash

      docker-compose create

   You should see the following

   .. codewithvars:: bash

      Creating enterprisekafka_zookeeper_1
      Creating enterprisekafka_kafka-6_1
      Creating enterprisekafka_kafka-4_1
      Creating enterprisekafka_kafka-5_1
      Creating enterprisekafka_kafka-2_1
      Creating enterprisekafka_kafka-3_1
      Creating enterprisekafka_kafka-1_1

   Start the services

   .. codewithvars:: bash

      docker-compose start zookeeper kafka-1 kafka-2 kafka-3

   You should see the following

   .. codewithvars:: bash

      Starting zookeeper ... done
      Starting kafka-2 ... done
      Starting kafka-3 ... done
      Starting kafka-1 ... done

   Make sure the services are up and running:

   .. codewithvars:: bash

      docker-compose ps

   You should see the following:

   .. codewithvars:: bash

        Name                        Command            State    Ports
      ------------------------------------------------------------------------
      enterprisekafka_kafka-1_1     /etc/confluent/docker/run   Up
      enterprisekafka_kafka-2_1     /etc/confluent/docker/run   Up
      enterprisekafka_kafka-3_1     /etc/confluent/docker/run   Up
      enterprisekafka_kafka-4_1     /etc/confluent/docker/run   Exit 0
      enterprisekafka_kafka-5_1     /etc/confluent/docker/run   Exit 0
      enterprisekafka_kafka-6_1     /etc/confluent/docker/run   Exit 0
      enterprisekafka_zookeeper_1   /etc/confluent/docker/run   Up

   Now check the |zk| logs to verify that |zk| is healthy.

   .. codewithvars:: bash

      docker-compose logs zookeeper | grep -i binding

   You should see the following in your terminal window:

   .. codewithvars:: bash

      zookeeper_1  | [2016-10-21 22:15:22,494] INFO binding to port 0.0.0.0/0.0.0.0:22181 (org.apache.zookeeper.server.NIOServerCnxnFactory)

   Next, check the Kafka logs for the destination cluster to verify that broker is healthy.

   .. codewithvars:: bash

      docker-compose logs kafka-1 | grep -i started

   You should see message a message that looks like the following:

   .. codewithvars:: bash

      kafka-1_1    | [2016-10-21 22:19:50,964] INFO [Socket Server on Broker 1], Started 1 acceptor threads (kafka.network.SocketServer)
      kafka-1_1    | [2016-10-21 22:19:51,300] INFO [Kafka Server 1], started (kafka.server.KafkaServer)
      ....


#. Now that the brokers are up, we will create a test topic called "adb-test".

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm confluentinc/cp-kafka:|release| \
      kafka-topics --create --topic adb-test --partitions 20 --replication-factor 3 --if-not-exists --zookeeper localhost:22181

   You should see the following output in your terminal window:

   .. codewithvars:: bash

    Created topic "adb-test".

   Before moving on, verify that the topic was created successfully:

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm confluentinc/cp-kafka:|release| \
      kafka-topics --describe --topic adb-test --zookeeper localhost:22181

   You should see the following output in your terminal window:

   .. codewithvars:: bash

    Topic:adb-test 	PartitionCount:20      	ReplicationFactor:3    	Configs:
    Topic: adb-test	Partition: 0   	Leader: 2      	Replicas: 2,1,3	Isr: 2,1,3
    Topic: adb-test	Partition: 1   	Leader: 3      	Replicas: 3,2,1	Isr: 3,2,1
    Topic: adb-test	Partition: 2   	Leader: 1      	Replicas: 1,3,2	Isr: 1,3,2
    Topic: adb-test	Partition: 3   	Leader: 2      	Replicas: 2,3,1	Isr: 2,3,1
    Topic: adb-test	Partition: 4   	Leader: 3      	Replicas: 3,1,2	Isr: 3,1,2
    Topic: adb-test	Partition: 5   	Leader: 1      	Replicas: 1,2,3	Isr: 1,2,3
    Topic: adb-test	Partition: 6   	Leader: 2      	Replicas: 2,1,3	Isr: 2,1,3
    Topic: adb-test	Partition: 7   	Leader: 3      	Replicas: 3,2,1	Isr: 3,2,1
    Topic: adb-test	Partition: 8   	Leader: 1      	Replicas: 1,3,2	Isr: 1,3,2
    Topic: adb-test	Partition: 9   	Leader: 2      	Replicas: 2,3,1	Isr: 2,3,1
    Topic: adb-test	Partition: 10  	Leader: 3      	Replicas: 3,1,2	Isr: 3,1,2
    Topic: adb-test	Partition: 11  	Leader: 1      	Replicas: 1,2,3	Isr: 1,2,3
    Topic: adb-test	Partition: 12  	Leader: 2      	Replicas: 2,1,3	Isr: 2,1,3
    Topic: adb-test	Partition: 13  	Leader: 3      	Replicas: 3,2,1	Isr: 3,2,1
    Topic: adb-test	Partition: 14  	Leader: 1      	Replicas: 1,3,2	Isr: 1,3,2
    Topic: adb-test	Partition: 15  	Leader: 2      	Replicas: 2,3,1	Isr: 2,3,1
    Topic: adb-test	Partition: 16  	Leader: 3      	Replicas: 3,1,2	Isr: 3,1,2
    Topic: adb-test	Partition: 17  	Leader: 1      	Replicas: 1,2,3	Isr: 1,2,3
    Topic: adb-test	Partition: 18  	Leader: 2      	Replicas: 2,1,3	Isr: 2,1,3
    Topic: adb-test	Partition: 19  	Leader: 3      	Replicas: 3,2,1	Isr: 3,2,1

#. Next, we'll try generating some data to our new topic:

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm \
      confluentinc/cp-kafka:|release| \
      bash -c 'kafka-producer-perf-test --topic adb-test --num-records 2000000 --record-size 1000 --throughput 100000 --producer-props bootstrap.servers=localhost:19092'

   This command will use the built-in Kafka Performance Producer to produce 2 GB of sample data to the topic. Upon running it, you should see the following:

   .. codewithvars:: bash

    209047 records sent, 41784.3 records/sec (39.85 MB/sec), 91.1 ms avg latency, 520.0 max latency.
    325504 records sent, 65100.8 records/sec (62.08 MB/sec), 35.6 ms avg latency, 474.0 max latency.
    258023 records sent, 51573.7 records/sec (49.18 MB/sec), 359.6 ms avg latency, 1264.0 max latency.
    287934 records sent, 57586.8 records/sec (54.92 MB/sec), 455.1 ms avg latency, 1429.0 max latency.
    413091 records sent, 81978.8 records/sec (78.18 MB/sec), 200.6 ms avg latency, 757.0 max latency.
    282214 records sent, 56128.5 records/sec (53.53 MB/sec), 495.6 ms avg latency, 1738.0 max latency.
    85071 records sent, 16815.8 records/sec (16.04 MB/sec), 468.0 ms avg latency, 3861.0 max latency.
    115 records sent, 8.8 records/sec (0.01 MB/sec), 8307.4 ms avg latency, 13127.0 max latency.
    13358 records sent, 2671.6 records/sec (2.55 MB/sec), 15408.9 ms avg latency, 23005.0 max latency.
    74948 records sent, 14284.0 records/sec (13.62 MB/sec), 6555.0 ms avg latency, 22782.0 max latency.
    5052 records sent, 1010.4 records/sec (0.96 MB/sec), 3228.3 ms avg latency, 8508.0 max latency.
    2000000 records sent, 30452.988199 records/sec (29.04 MB/sec), 786.61 ms avg latency, 23005.00 ms max latency, 82 ms 50th, 1535 ms 95th, 22539 ms 99th, 22929 ms 99.9th.

#. Run `confluent-rebalancer` to balance the data in the cluster.

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm \
      confluentinc/cp-enterprise-kafka:|release| \
      bash -c "confluent-rebalancer execute --zookeeper localhost:22181 --metrics-bootstrap-server localhost:19092 --throttle 100000000 --force --verbose"

   You should see the rebalancing start and should see the following:

   .. codewithvars:: bash

    You are about to move 6 replica(s) for 6 partitions to 1 broker(s) with total size 0.9 MB.
    The preferred leader for 6 partition(s) will be changed.
    In total, the assignment for 7 partitions will be changed.

    The following brokers will require more disk space during the rebalance and, in some cases, after the rebalance:
        Broker     Current (MB)    During Rebalance (MB)  After Rebalance (MB)
        2          2,212.8         2,213.8                2,213.8

    Min/max stats for brokers (before -> after):
          Type  Leader Count                 Replica Count                Size (MB)
          Min   8 (id: 2) -> 10 (id: 1)      21 (id: 2) -> 27 (id: 1)     2,069.6 (id: 1) -> 2,069.1 (id: 1)
          Max   12 (id: 3) -> 11 (id: 2)     30 (id: 1) -> 27 (id: 1)     2,212.8 (id: 2) -> 2,213.8 (id: 2)

    Rack stats (before -> after):
          Rack       Leader Count    Replica Count   Size (MB)
          rack-a     31 -> 31        81 -> 81        6,352 -> 6,352

    Broker stats (before -> after):
          Broker     Leader Count    Replica Count   Size (MB)
          1          11 -> 10        30 -> 27        2,069.6 -> 2,069.1
          2          8 -> 11         21 -> 27        2,212.8 -> 2,213.8
          3          12 -> 10        30 -> 27        2,069.6 -> 2,069.1

    The rebalance has been started, run `status` to check progress.

    Warning: You must run the `status` or `finish` command periodically, until the rebalance completes, to ensure the throttle is removed. You can also alter the throttle by re-running the execute command passing a new value.

   You can check the status of the rebalance operation by running the following command:

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm \
      confluentinc/cp-enterprise-kafka:|release| \
      bash -c "confluent-rebalancer status --zookeeper localhost:22181"

   If you see the a message like ``7 partitions are being rebalanced``, wait for 15-20 seconds and rerun the above command until you see ``No rebalance is currently in progress``.  This means that the rebalance action has completed successfully.

   You can finish the rebalance action by running the following command (this command ensures that the replication throttle is removed):

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm \
      confluentinc/cp-enterprise-kafka:|release| \
      bash -c "confluent-rebalancer finish --zookeeper localhost:22181"

   You should see the following in the logs:

   .. codewithvars:: bash

    The rebalance has completed and throttling has been disabled

#. ADB makes it easy to add new brokers to the cluster. You can now add an entire new rack to your cluster and run the rebalance operation again to balance the data across the cluster.

   Start the new rack by running the following command:

   .. codewithvars:: bash

    docker-compose start kafka-4 kafka-5 kafka-6

   You should follow the instructions in step 4 to verify the Kafka brokers are healthy.

   Now start the rebalance operation by following step #. After the rebalance operation has finished, data should be balanced across the cluster. We will verify that by describing the topic metadata as follows.

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm confluentinc/cp-kafka:|release| \
      kafka-topics --describe --topic adb-test --zookeeper localhost:22181

   You should see that partitions are spread across all of the brokers (i.e you should see some replicas and leaders assigned to brokers 4, 5, or 6).

   .. codewithvars:: bash

    Topic:adb-test 	PartitionCount:20      	ReplicationFactor:3    	Configs:
    Topic: adb-test	Partition: 0   	Leader: 1      	Replicas: 1,5,6	Isr: 5,1,6
    Topic: adb-test	Partition: 1   	Leader: 3      	Replicas: 3,5,4	Isr: 5,3,4
    Topic: adb-test	Partition: 2   	Leader: 6      	Replicas: 6,4,1	Isr: 1,6,4
    Topic: adb-test	Partition: 3   	Leader: 6      	Replicas: 6,5,3	Isr: 5,6,3
    Topic: adb-test	Partition: 4   	Leader: 1      	Replicas: 1,4,5	Isr: 5,1,4
    Topic: adb-test	Partition: 5   	Leader: 3      	Replicas: 6,4,3	Isr: 6,3,4
    Topic: adb-test	Partition: 6   	Leader: 1      	Replicas: 5,1,6	Isr: 5,1,6
    Topic: adb-test	Partition: 7   	Leader: 3      	Replicas: 3,5,4	Isr: 5,3,4
    Topic: adb-test	Partition: 8   	Leader: 4      	Replicas: 4,6,1	Isr: 1,6,4
    Topic: adb-test	Partition: 9   	Leader: 5      	Replicas: 5,6,3	Isr: 5,6,3
    Topic: adb-test	Partition: 10  	Leader: 2      	Replicas: 2,4,5	Isr: 5,2,4
    Topic: adb-test	Partition: 11  	Leader: 4      	Replicas: 4,2,6	Isr: 6,2,4
    Topic: adb-test	Partition: 12  	Leader: 5      	Replicas: 5,2,6	Isr: 5,6,2
    Topic: adb-test	Partition: 13  	Leader: 2      	Replicas: 2,5,4	Isr: 5,2,4
    Topic: adb-test	Partition: 14  	Leader: 4      	Replicas: 4,6,2	Isr: 6,2,4
    Topic: adb-test	Partition: 15  	Leader: 1      	Replicas: 1,3,2	Isr: 1,2,3
    Topic: adb-test	Partition: 16  	Leader: 2      	Replicas: 3,2,1	Isr: 2,1,3
    Topic: adb-test	Partition: 17  	Leader: 3      	Replicas: 3,2,1	Isr: 3,2,1
    Topic: adb-test	Partition: 18  	Leader: 1      	Replicas: 1,2,3	Isr: 1,2,3
    Topic: adb-test	Partition: 19  	Leader: 2      	Replicas: 2,3,1	Isr: 2,3,1


#. Now you can try removing a broker and running the rebalance operation again.

   Hint: You must notify the rebalancer to exclude broker from the rebalance plan. For example, to remove broker 1 you must run the following command:

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm \
      confluentinc/cp-enterprise-kafka:|release| \
      bash -c "confluent-rebalancer execute --zookeeper localhost:22181 --metrics-bootstrap-server localhost:19092 --throttle 100000000 --force --verbose --remove-broker-ids 1"

#. Feel free to experiment with the `confluent-rebalance` command on your own now. When you are done, use the following commands to shutdown all the components.

    .. codewithvars:: bash

     docker-compose stop

    If you want to remove all the containers, run:

    .. codewithvars:: bash

     docker-compose rm
