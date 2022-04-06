# bash-scripts

Ths BASH script send the "fileToSend.txt" file to a list of Linux servers (destination.csv) in a specific path.

This script was tested on Linux CENTOS Stream 8, 

NOTE: BEFORE EXECUTE main.sh please install expect command by typing 
sudo yum install expect -y

---

Execution:
To execute this DEMO we have to fill the list of Linux servers along with username and passwords (this could be changed to a SQL request ;) or a different source to hide sensitive information) and execute main.sh script typing the next command:
./main.sh

---

Files description:
- main.sh : script that reads de CSV file and calls sendFile.sh each time a file is required to be sent
- sendFiles.sh : Use de command expect to get the file sent
- fileToSend.txt : This is the expected file to be sent
- destination.csv : contains a list of address, username and passwords, information used on main.sh

