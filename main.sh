#!/bin/sh

filename="fileToSend.txt"

#Already existing path
DestinationPathOnServer="~"

#contains destination IP address, username and pass
destinationsFile="destination.csv"


#If CSV file exist and it's not empty
if [ -e "$destinationsFile" ] && [ $(cat $destinationsFile | wc -l) -gt 0 ]
then
	##Header
        echo "========================================================================"
        echo "Initializing file sending"
        echo "========================================================================"

	rowNumber=1


	##CSV File separator vars
	OIFS=$IFS
	IFS=,    #field separator
	
	##CSV data

        while read serverip username password
        # in the upper line as much variables as you need
        # if th read command contains less variables than your csv-file contains fields,
        # then the last declared variable contains the whole rest of the line

        do
	echo
	echo "Server #"$rowNumber

        #Information extracted from CSV file
        echo "Server address: "$serverip
	echo "Username: "$username

	#Hiding sensitive information
	sensitivePass=${password:0:1} #first char
	for (( c=2; c<${#password}; c++ ))
	do
		sensitivePass="${sensitivePass}*" #******
	done
	sensitivePass="${sensitivePass}${password: -1}" #last char
	echo "Pass: "$sensitivePass
	echo

	expect -f sendFiles.sh $username $serverip $password $filename $DestinationPathOnServer
	echo
	echo "------------------------------"

	rowNumber=$((rowNumber+1))

	done < $destinationsFile
        IFS=$OIFS

	##Footer
        echo "========================================================================"
        echo "Finishing file sending"
        echo "========================================================================"


else
        echo "ERROR: File $destinationsFile doesn't exist or it's EMPTY"
fi
