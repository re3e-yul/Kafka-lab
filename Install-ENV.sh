#! /bin/bash
export ProdZK="localhost:61181"
if [[ -z $(id | grep root ) ]]
then 
	echo "Please run this as root
	exit
fi

clear
echo -e "Portable Confluent Kafka lab 1"
if [ $(dpkg -l docker | tail -n 1 | grep -c docker) -eq 0 ]
then 
	echo -e "installing dockers " && apt-get install -y docker.io 
else
	echo -e "docker engine already installed"
fi
if [ $(dpkg -l docker-compose | tail -n 1 | grep -c docker) -eq 0 ]
then 
        echo -e "installing docker-compose " && apt-get install -y docker-composer 
else
        echo -e "docker-compose already installed"
fi
if [ $(dpkg -l git | tail -n 1 | grep -c git) -eq 0 ]
then 
        echo -e "installing Git " && apt-get install -y git 
else
        echo -e "Git already installed"
fi
if [ $(dpkg -l netcat-openbsd | tail -n 1 | grep -c netcat-openbsd) -eq 0 ]
then 
        echo -e "installing netcat " && apt-get install -y netcat-openbsd
else
        echo -e "netcat already installed"
fi

LabHome=$(find  /home  -name Kafka-Lab-1)
clear
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
while [[ $Zks -ne 3 ]]
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
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic BANKING_ACCOUNT_CHANGE"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic BANKING_ACCOUNT_CHANGE_Poison"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic BNC_INVESTMENT_CHANGE"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic BNI_INVESTMENT_CHANGE"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CDBN_INVESTMENT_BALANCE_CHANGE"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CDBN_INVESTMENT_CHANGE"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CO_Account_Balance"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CO_Ordered_Transactions"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CO_Ordered_Transactions_Poison"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CO_Synchronized_Account_Balance_Poison"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CO_Synchronized_Transactions_Poison"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CO_Transactions"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CO_Transactions_Poison"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CP_Account_Balance"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CP_Ordered_Transactions"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CP_Ordered_Transactions_Poison"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CP_Synchronized_Account_Balance_Poison"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CP_Synchronized_Transactions_Poison"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CP_Transactions"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic CP_Transactions_Poison"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic FBN_INVESTMENT_BALANCE_CHANGE"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic FBN_INVESTMENT_CHANGE"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic FERR_INVESTMENT_CHANGE"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic LOAN_ACCOUNT_CHANGE"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic LOAN_ACCOUNT_CHANGE_Poison"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic MASTERCARD_ACCOUNT_CHANGE"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic MASTERCARD_ACCOUNT_CHANGE_Poison"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic MORTGAGE_ACCOUNT_CHANGE"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic MORTGAGE_ACCOUNT_CHANGE_Poison"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic Realtime_AccountSynchroData_Monitoring"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic Realtime_AccountSynchroSummary_Monitoring"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic Realtime_Transaction_Monitoring"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic TBN_INVESTMENT_CHANGE"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic notificationTopic"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic resynchronizeChannel"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic sherif"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic springCloudBus"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic springCloudHystrixStream"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic synchronizeChannel"
docker exec -it PROD-broker-1 sh -c "kafka-topics --create --if-not-exists --zookeeper $ProdZK --partitions 5 --replication-factor 3 --topic turbineStreamInput"
sleep 2
clear
cat ./dockerps 
echo -e ""
echo -e ""
echo -e "Topics on Prod cluster: "
docker exec -it PROD-broker-1 sh -c "kafka-topics --list --zookeeper $ProdZK" | grep -v "__"

echo "Creating sink producer for local syslog to PROD-topic1"
sudo kafka-console-producer --broker-list localhost:17092 --topic sherif  < /var/log/syslog 
echo -e ""
echo -e ""
clear
cat ./dockerps 
echo -e ""
echo -e ""
echo -e "Topics on Prod cluster: "
docker exec -it PROD-broker-1 sh -c "kafka-topics --list --zookeeper $ProdZK" | grep -v "__"

echo "sink producer for local syslog to sherif CREATED"
echo "Creating consumer for remote syslog from  sherif"
sudo kafka-console-consumer --bootstrap-server localhost:17092 --topic sherif -group syslog --from-beginning
rm -f ./dockerps
