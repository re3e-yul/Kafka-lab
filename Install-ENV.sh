#! /bin/bash
export ProdZK="localhost:61181"
clear
echo -e "Portable Confluent Kafka lab 1"
if [ $(dpkg -l docker | tail -n 1 | grep -c docker) -eq 0 ]
then 
	echo -e "installing dockers " && apt-get install -y docker 
else
	echo -e "docker engine already installed"
fi
if [ $(dpkg -l docker-compose | tail -n 1 | grep -c docker) -eq 0 ]
then 
        echo -e "installing dockers " && apt-get install -y docker 
else
        echo -e "docker-compose already installed"
fi
if [ $(dpkg -l git | tail -n 1 | grep -c git) -eq 0 ]
then 
        echo -e "installing Git " && apt-get install -y git 
else
        echo -e "Git already installed"
fi
LabHome=$(find  /home  -name Kafka-Lab-1)

if [[ -z $LabHome ]]
then
	cd ~
	clear
	echo -e "Portable Confluent Kafka lab 1"
	echo -e "docker engine already installed"
	echo -e "docker-compose already installed"
        echo -e "Git already installed"
	git clone https://github.com/re3e-yul/Kafka-lab.git ~/Kafka-Lab-1
	cd Kafka-Lab-1
	LabHome=$(find  /home  -name Kafka-Lab-1)
else
	cd $LabHome
        echo -e "Portable Confluent Kafka lab 1"
        echo -e "docker engine already installed"
        echo -e "docker-compose already installed"
        echo -e "Git already installed"
	echo -e "Lab docker directory is : " $LabHome
fi



for CID in $(docker container ls -a | awk -F" " '{print $1}' | grep -v "CONTAINER")
do 
	name=$(docker container ls -a | grep $CID | awk '{print $NF}' )
	echo -e "Killing: "$name
	docker container stop $CID &>/dev/null
	docker container rm  $CID &>/dev/null
done

clear
echo -e "Portable Confluent Kafka lab 1"
echo -e "docker engine already installed"
echo -e "docker-compose already installed"
echo -e "Git already installed"
echo -e "Lab docker directory is : " $LabHome
echo -e "starting docker machines"
docker-compose up -d
clear
docker ps > ./dockerps
echo -e "Portable Confluent Kafka lab 1"
echo -e "docker engine already installed"
echo -e "docker-compose already installed"
echo -e "Git already installed"
echo -e "Lab docker directory is : " $LabHome
echo -e ""
echo -e ""
cat ./dockerps
echo -e "Waiting for infra to come up"
echo -e ""
echo -e ""
Zks=0
while [[ $Zks -lt 3 ]]
do
	clear
	echo -e "Portable Confluent Kafka lab 1"
	echo -e "docker engine already installed"
	echo -e "docker-compose already installed"
        echo -e "Git already installed"
	echo -e "Lab docker directory is : " $LabHome
	echo -e ""
	echo -e ""
	cat ./dockerps
	echo -e "Waiting for infra to come up"
	echo -e ""
	echo -e ""
	for port in 61181 62181 63181
	do
		mode=$(echo -e mntr | nc localhost $port | grep "zk_server_state")
		if [[ ! -z $mode ]]
		then
			((Zks++))
			ZKprint=$ZKprint$(echo  "server localhost:"$port" is "$(echo $mode | awk -F" " '{print $2}')"\n")
		fi
	done
	echo -e "Zookeeper server: " $Zks ;echo  -e $ZKprint
	sleep 1
done
Brokers=$(echo -e dump | nc $(echo -e $ProdZK | tr ':' ' ') | grep -c "broker")
while [[ $Brokers -ne "3" ]]
do
	clear
	Brokers=$(echo -e dump | nc $(echo -e $ProdZK | tr ':' ' ') | grep -c "broker")
        echo -e "Portable Confluent Kafka lab 1"
        echo -e "docker engine already installed"
        echo -e "docker-compose already installed"
        echo -e "Git already installed"
        echo -e "Lab docker directory is : " $LabHome
        echo -e ""
        echo -e ""
        cat ./dockerps
        echo -e "Waiting for infra to come up"
        echo -e ""
        echo -e ""
	echo -e "Zookeeper server: " $Zks "\n"$ZKprint
	echo -e $Brokers " Brokers are up"
	sleep 1
done
echo -e "creating Topics"
docker exec -it PROD-broker-1 sh -c "ProdZK=localhost:61181"
docker exec -it PROD-broker-2 sh -c "ProdZK=localhost:62181"
docker exec -it PROD-broker-3 sh -c "ProdZK=localhost:63181"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic PROD-1"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic PROD-2"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic PROD-3"
sleep 2
clear
cat ./dockerps 
rm -f ./dockerps
echo -e ""
echo -e ""
echo -e "Topics on Prod cluster: "
docker exec -it PROD-broker-1 sh -c "kafka-topics --list --zookeeper $ProdZK" | grep -v "__"

echo "Creating sink producer for local syslog to PROD-topic1"
sudo kafka-console-producer --broker-list localhost:17092 --topic PROD-1  < /var/log/syslog 
echo -e ""
echo -e ""
echo "Creating consumer for remote syslog from  PROD-topic1"
sudo kafka-console-consumer --bootstrap-server localhost:17092 --topic PROD-1 -group syslog --from-beginning
