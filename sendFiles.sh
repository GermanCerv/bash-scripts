#!/usr/bin/expect -f
# Variables passed as arguments
set username [lindex $argv 0]
set serverip [lindex $argv 1]
set password [lindex $argv 2]
set filename [lindex $argv 3]
set DestinationPathOnServer [lindex $argv 4]

#Using variables
spawn scp -o StrictHostKeyChecking=no -o LogLevel=ERROR $filename $username@$serverip:$DestinationPathOnServer

expect "assword:"
send "$password\r"


#fin de spawn
expect eof
