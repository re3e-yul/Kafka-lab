.. _replicator:

Replicator Tutorial on Docker
=============================

In this section, we provide a tutorial for running Replicator which replicates data from two source Kafka clusters to a
destination Kafka cluster.  By the end of this tutorial, you will have successfully run Replicator and replicated data
for two topics from different source clusters to a destination cluster.  Furthermore, you will have also set up a Kafka
Connect cluster because Replicator is built on Connect.

.. include:: includes/docker-tutorials.rst
    :start-line: 2

#. Start the services by using the example Docker Compose file. It will start up 2 source Kafka clusters, one destination
   Kafka cluster and a Kafka Connect cluster. Navigate to ``cp-docker-images/examples/enterprise-replicator``, where it is located:

   .. codewithvars:: bash

    cd cp-docker-images/examples/enterprise-replicator

#. Start the Kafka and Kafka Connect clusters using Docker Compose ``create`` and ``start`` commands.

   .. codewithvars:: bash

    docker-compose create

   You should see the following

   .. codewithvars:: bash

    Creating enterprisereplicator_kafka-1-src-b_1
    Creating enterprisereplicator_kafka-1-src-a_1
    Creating enterprisereplicator_kafka-2-dest_1
    Creating enterprisereplicator_zookeeper-src-b_1
    Creating enterprisereplicator_zookeeper-src-a_1
    Creating enterprisereplicator_connect-host-1_1
    Creating enterprisereplicator_kafka-2-src-a_1
    Creating enterprisereplicator_kafka-2-src-b_1
    Creating enterprisereplicator_kafka-1-dest_1
    Creating enterprisereplicator_zookeeper-dest_1
    Creating enterprisereplicator_connect-host-2_1

   Start all the services

   .. codewithvars:: bash

    docker-compose start

   You should see the following

   .. codewithvars:: bash

    Starting kafka-1-src-b ... done
    Starting kafka-1-src-a ... done
    Starting kafka-2-dest ... done
    Starting zookeeper-src-b ... done
    Starting zookeeper-src-a ... done
    Starting connect-host-1 ... done
    Starting kafka-2-src-a ... done
    Starting kafka-2-src-b ... done
    Starting kafka-1-dest ... done
    Starting zookeeper-dest ... done
    Starting connect-host-2 ... done

   Before we move on, let's make sure the services are up and running:

   .. codewithvars:: bash

    docker-compose ps

   You should see the following:

   .. codewithvars:: bash

      Name                             Command            State   Ports
    ----------------------------------------------------------------------------------
    enterprisereplicator_connect-host-1_1    /etc/confluent/docker/run   Up
    enterprisereplicator_connect-host-2_1    /etc/confluent/docker/run   Up
    enterprisereplicator_kafka-1-dest_1      /etc/confluent/docker/run   Up
    enterprisereplicator_kafka-1-src-a_1     /etc/confluent/docker/run   Up
    enterprisereplicator_kafka-1-src-b_1     /etc/confluent/docker/run   Up
    enterprisereplicator_kafka-2-dest_1      /etc/confluent/docker/run   Up
    enterprisereplicator_kafka-2-src-a_1     /etc/confluent/docker/run   Up
    enterprisereplicator_kafka-2-src-b_1     /etc/confluent/docker/run   Up
    enterprisereplicator_zookeeper-dest_1    /etc/confluent/docker/run   Up
    enterprisereplicator_zookeeper-src-a_1   /etc/confluent/docker/run   Up
    enterprisereplicator_zookeeper-src-b_1   /etc/confluent/docker/run   Up

   Now check the |zk| logs for destination cluster to verify that |zk| is healthy.

   .. codewithvars:: bash

    docker-compose logs zookeeper-dest | grep -i binding

   You should see the following in your terminal window:

   .. codewithvars:: bash

    zookeeper-dest_1   | [2016-10-20 17:31:40,784] INFO binding to port 0.0.0.0/0.0.0.0:42181 (org.apache.zookeeper.server.NIOServerCnxnFactory)

   Next, check the Kafka logs for the destination cluster to verify that it is healthy:

   .. codewithvars:: bash

    docker-compose logs kafka-1-dest | grep -i started

   You should see message a message that looks like the following:

   .. codewithvars:: bash

    kafka-1-dest_1     | [2016-10-20 17:31:45,364] INFO [Socket Server on Broker 1002], Started 1 acceptor threads (kafka.network.SocketServer)
    kafka-1-dest_1     | [2016-10-20 17:31:45,792] INFO [Kafka Server 1002], started (kafka.server.KafkaServer)
    ....

   Similarly verify that the ``source-a`` and ``source-b`` Kafka clusters are ready by running the following commands and verifying the output as described in the steps above.

   .. codewithvars:: bash

    docker-compose logs zookeeper-src-a | grep -i binding
    docker-compose logs zookeeper-src-b | grep -i binding
    docker-compose logs kafka-1-src-a | grep -i started
    docker-compose logs kafka-1-src-b | grep -i started

   Now, you can make sure that the Connect worker is up by running the following command to search the logs:

   .. codewithvars:: bash

    docker-compose logs connect-host-1 | grep started

   You should see the following

   .. codewithvars:: bash

    connect-host-1_1   | [2016-10-20 17:31:48,942] INFO Kafka Connect started (org.apache.kafka.connect.runtime.Connect)
    connect-host-1_1   | [2016-10-20 17:31:50,403] INFO Worker started (org.apache.kafka.connect.runtime.Worker)
    connect-host-1_1   | [2016-10-20 17:31:50,988] INFO Herder started (org.apache.kafka.connect.runtime.distributed.DistributedHerder)


#. You will now create our first Kafka Connect Replicator connector for replicating topic "foo" from source cluster ``source-a``.

   First, create a topic named ``foo``.

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm confluentinc/cp-kafka:|release| \
      kafka-topics --create --topic foo --partitions 3 --replication-factor 2 --if-not-exists --zookeeper localhost:22181

   You should see the following output in your terminal window:

   .. codewithvars:: bash

    Created topic "foo".

   Before moving on, verify that the topic was created successfully:

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm confluentinc/cp-kafka:|release| \
      kafka-topics --describe --topic foo --zookeeper localhost:22181

   You should see the following output in your terminal window:

   .. codewithvars:: bash

    Topic:foo      	PartitionCount:3       	ReplicationFactor:2    	Configs:
    Topic: foo     	Partition: 0   	Leader: 1002   	Replicas: 1002,1001    	Isr: 1002,1001
    Topic: foo     	Partition: 1   	Leader: 1001   	Replicas: 1001,1002    	Isr: 1001,1002
    Topic: foo     	Partition: 2   	Leader: 1002   	Replicas: 1002,1001    	Isr: 1002,1001

#. Next, we'll try generating some data to our new topic:

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm \
      confluentinc/cp-kafka:|release| \
      bash -c "seq 1000 | kafka-console-producer --request-required-acks 1 --broker-list localhost:9092 --topic foo && echo 'Produced 1000 messages.'"

   This command will use the built-in Kafka Console Producer to produce 100 simple messages to the topic. Upon running it, you should see the following:

   .. codewithvars:: bash

    Produced 1000 messages.

#. Now create the connector using the Kafka Connect REST API.  First, let's exec into the Connect container.

   .. codewithvars:: bash

    docker-compose exec connect-host-1 bash

   You should see a bash prompt now. We will call this the ``docker exec`` command prompt:

   .. codewithvars:: bash

    root@confluent:/#

   The next step is to create the Replicator connector. Run the following command on the ``docker exec`` command prompt.

   .. codewithvars:: bash

    curl -X POST \
         -H "Content-Type: application/json" \
         --data '{
            "name": "replicator-src-a-foo",
            "config": {
              "connector.class":"io.confluent.connect.replicator.ReplicatorSourceConnector",
              "key.converter": "io.confluent.connect.replicator.util.ByteArrayConverter",
              "value.converter": "io.confluent.connect.replicator.util.ByteArrayConverter",
              "src.zookeeper.connect": "localhost:22181",
              "src.kafka.bootstrap.servers": "localhost:9092",
              "dest.zookeeper.connect": "localhost:42181",
              "topic.whitelist": "foo",
              "topic.rename.format": "${topic}.replica"}}'  \
         http://localhost:28082/connectors

   Upon running the command, you should see the following output in your ``docker exec`` command prompt:

   .. codewithvars:: bash

    {"name":"replicator-src-a-foo","config":{"connector.class":"io.confluent.connect.replicator.ReplicatorSourceConnector","key.converter":"io.confluent.connect.replicator.util.ByteArrayConverter","value.converter":"io.confluent.connect.replicator.util.ByteArrayConverter","src.zookeeper.connect":"localhost:22181","src.kafka.bootstrap.servers":"localhost:9092","dest.zookeeper.connect":"localhost:42181","topic.whitelist":"foo","topic.rename.format":"${topic}.replica","name":"replicator-src-a-foo"},"tasks":[]}

   Before moving on, let's check the status of the connector using curl on the ``docker exec`` command prompt.

   .. codewithvars:: bash

    curl -X GET http://localhost:28082/connectors/replicator-src-a-foo/status

   You should see the following output including the ``state`` of the connector as ``RUNNING``:

   .. codewithvars:: bash

    {"name":"replicator-src-a-foo","connector":{"state":"RUNNING","worker_id":"localhost:38082"},"tasks":[{"state":"RUNNING","id":0,"worker_id":"localhost:28082"}]}

  Exit the ``docker exec`` command prompt by typing ``exit`` on the prompt.

  .. codewithvars:: bash

    exit

#. Now that the connector is up and running, it should replicate data from ``foo`` topic on ``source-a`` cluster to ``foo.replica`` topic on the ``dest`` cluster.

   Read a sample of 1000 records from the ``foo.replica`` topic to check if the connector is replicating data to the destination Kafka cluster, as expected. Run the following command on your terminal (Make sure you have exited the ``docker exec`` command prompt):

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm \
      confluentinc/cp-kafka:|release| \
      kafka-console-consumer --bootstrap-server localhost:9072 --topic foo.replica --from-beginning --max-messages 1000

   If everything is working as expected, each of the original messages we produced should be written back out:

   .. codewithvars:: bash

    1
    ....
    1000
    Processed a total of 1000 messages

   You will now verify that the destination topic is created with correct replication factor and partition count.

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm confluentinc/cp-kafka:|release| \
      kafka-topics --describe --topic foo.replica --zookeeper localhost:42181

   You should see that the topic ``foo.replica`` is created with 3 partitions and 2 replicas, same as the original topic ``foo``.

   .. codewithvars:: bash

    Topic:foo.replica      	PartitionCount:3       	ReplicationFactor:2    	Configs:message.timestamp.type=CreateTime
    Topic: foo.replica     	Partition: 0   	Leader: 1002   	Replicas: 1002,1001    	Isr: 1002,1001
    Topic: foo.replica     	Partition: 1   	Leader: 1001   	Replicas: 1001,1002    	Isr: 1001,1002
    Topic: foo.replica     	Partition: 2   	Leader: 1002   	Replicas: 1002,1001    	Isr: 1002,1001

#. Now, we will replicate another topic from a different source cluster.

   First, create a new topic on the cluster ``source-b`` and add some data to it. Run the following commands to create and verify the topic. You should see output similar to steps 4 and 5 above:

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm confluentinc/cp-kafka:|release| \
      kafka-topics --create --topic bar --partitions 3 --replication-factor 2 --if-not-exists --zookeeper localhost:32181

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm confluentinc/cp-kafka:|release| \
      kafka-topics --describe --topic bar --zookeeper localhost:32181

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm \
      confluentinc/cp-kafka:|release| \
      bash -c "seq 1000 | kafka-console-producer --request-required-acks 1 --broker-list localhost:9082 --topic bar && echo 'Produced 1000 messages.'"

   Now ``exec`` into the Kafka Connect container and run the replicator connector. Enter the following commands on your terminal. You should see output similar to step 6 above.

   Run the following to into the container to get ``docker exec`` command prompt.

   .. codewithvars:: bash

    docker-compose exec connect-host-1 bash

   Run the following command on the ``docker exec`` command prompt.

   .. codewithvars:: bash

    curl -X POST \
         -H "Content-Type: application/json" \
         --data '{
            "name": "replicator-src-b-bar",
            "config": {
              "connector.class":"io.confluent.connect.replicator.ReplicatorSourceConnector",
              "key.converter": "io.confluent.connect.replicator.util.ByteArrayConverter",
              "value.converter": "io.confluent.connect.replicator.util.ByteArrayConverter",
              "src.zookeeper.connect": "localhost:32181",
              "src.kafka.bootstrap.servers": "localhost:9082",
              "dest.zookeeper.connect": "localhost:42181",
              "topic.whitelist": "bar",
              "topic.rename.format": "${topic}.replica"}}'  \
         http://localhost:28082/connectors

   .. codewithvars:: bash

    curl -X GET http://localhost:28082/connectors/replicator-src-b-bar/status


   Exit the ``docker exec`` command prompt by typing ``exit`` on the prompt.

   .. codewithvars:: bash

    exit

#. Now that the second replicator connector is up and running, it should replicate data from ``bar`` topic on ``source-b`` cluster to ``bar.replica`` topic on the ``dest`` cluster.

   Read data from ``bar.replica`` topic to check if the connector is replicating data properly followed by describing the topic to verify that the destination topic was created properly. You should see output similar to step 7 above. as expected.

   Run the following commands on your terminal (Make sure you have exited the ``docker exec`` command prompt):

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm \
      confluentinc/cp-kafka:|release| \
      kafka-console-consumer --bootstrap-server localhost:9072 --topic bar.replica --from-beginning --max-messages 1000

   .. codewithvars:: bash

    docker run \
      --net=host \
      --rm confluentinc/cp-kafka:|release| \
      kafka-topics --describe --topic bar.replica --zookeeper localhost:42181

#. Feel free to experiment with the replicator connector on your own now. When you are done, use the following commands to shutdown all the components.

   .. codewithvars:: bash

    docker-compose stop

   If you want to remove all the containers, run:

   .. codewithvars:: bash

    docker-compose rm
