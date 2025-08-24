#! /bin/bash

#Launch an instance with port 9000 and t2.medium

sudo apt install openjdk-17-jdk -y
java -version

#Download & Extract SonarQube 25.8.0.112029(change version as per need)

cd /opt
sudo apt install wget unzip -y

sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-25.8.0.112029.zip
sudo unzip sonarqube-25.8.0.112029.zip

sudo rm sonarqube-25.8.0.112029.zip
sudo mv sonarqube-25.8.0.112029 sonarqube

#Create SonarQube User

sudo adduser --system --no-create-home --group --disabled-login sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube

#Increase Linux Limits (needed for startup)
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536

#Start Sonarqube by running below command manually
#sh /opt/sonarqube/bin/linux/sonar.sh start
