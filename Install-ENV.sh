#! /bin/bash
clear
echo "Portable Confluent Kafka lab 1"
if [ $(dpkg -l docker | tail -n 1 | grep -c docker) -eq 0 ]
> then 
> echo "installing dockers " && apt-get install -y docker 
> else
> echo "already installed"
> fi
LabHome=$(find  /home  -name Kafka-Lab-1)
if [[ -z $LabHome ]]
then
	git clone https://github.com/confluentinc/cp-docker-images.git ~/Kafka-Lab-1
	git clone https://github.com/re3e-yul/Kafka-lab.git ~/Kafka-Lab-1-scripts
        rm -rf ~/Kafka-Lab-1/examples

for CID in $(docker container ls -a | awk -F" " '{print $1}' | grep -v "CONTAINER")
do 
	name=$(docker container ls -a | grep $CID | awk '{print $NF}' )
	echo "Killing: "$name
	docker container stop $CID &>/dev/null
	docker container rm  $CID &>/dev/null
done

export ProdZK="localhost:61181"
docker-compose up -d
echo "Wait for infra to come up"
Brokers=$(echo dump | nc $(echo $ProdZK | tr ':' ' ') | grep -c "broker")
while [[ $Brokers -ne "3" ]]
do
	Brokers=$(echo dump | nc $(echo $ProdZK | tr ':' ' ') | grep -c "broker")
	echo $Brokers " Brokers are up"
	sleep 5
done
echo "create Topics"
sudo docker exec -it PROD-broker-1 sh -c "ProdZK=localhost:61181"
sudo docker exec -it PROD-broker-2 sh -c "ProdZK=localhost:62181"
sudo docker exec -it PROD-broker-3 sh -c "ProdZK=localhost:63181"
sudo docker exec -it PROD-broker-1 sh -c "kafka-topics --create --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic PROD-1"
sudo docker exec -it PROD-broker-1 sh -c "kafka-topics --create --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic PROD-2"
sudo docker exec -it PROD-broker-1 sh -c "kafka-topics --create --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic PROD-3"

sudo docker exec -it PROD-broker-1 sh -c "kafka-topics --list --zookeeper $ProdZK" | grep -v "__"
