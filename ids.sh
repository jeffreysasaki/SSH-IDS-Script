#!/usr/bin/bash
#!/usr/bin/iptables
#!/usr/bin/crontab

###############################################################################
# SSH IDS script
# By: Jeffrey Sasaki
# 
# This script will block a user's IP if the user fails to login after a given
# defined number of attempts.
###############################################################################

# User Defined Parameters
NUMBER_OF_ATTEMPTS="3"     # Number of failed login attempts from a single IP
SSHLOG="/var/log/secure"   # For RPM-based distro (eg. Fedora)
#SSHLOG="/var/log/auth.log" # For Debian-based distro (eg. Ubuntu)


# Implementation
# Starting point - Check if the user is root
check_su()
{
	clear
		echo "Welcome to the IDS shell script"
		if [ "$(id -u)" != "0" ]; then
			echo "You must be in root to run this script" 1>&2
				exit 1
				fi
				echo "#################Initializing IDS#################"
}

# Ban IP given as an argument
ipban()
{
	for OUTPUT in $(grep -i 'invalid\|failed' $SSHLOG | grep -oEw --color '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep $1 |
			awk 'NF{ count[$0]++ }END{ for ( ip in count ) { print ip"X" count[ip] };}')
	do
		IP=$(echo $OUTPUT | awk -F'X' '{print $1}')
		COUNT=$(echo $OUTPUT | awk -F'X' '{print $2}')
	done
	if [ "$COUNT" -ge "$NUMBER_OF_ATTEMPTS" ]
	then
		# Check if the IP is in the table already
		if ! iptables -L INPUT -n | grep -q $IP
		then
			echo "Banning $IP after $COUNT failed login attempts"
			iptables -A INPUT -s $IP -j DROP
			#crontab -l; echo "* $hour $day_of_month $month $day_of_week (echo \"$message\"; uuencode $attachment) | /usr/bin/mail -s \"$subject\" $email_address") | crontab -
		fi
	fi
}

# Filter out ip's with failed login attempts, then initiate ipban function
filter()
{
	echo "################Listening Failed Login Attempts#################"
	tail -f -n0 $SSHLOG |
	while read line ; do
		if echo $line | grep -i 'failed' | grep -oEw --color '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
		then
			OUTPUT=$(echo $line | grep -i 'failed' | grep -oEw --color '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
			ipban $OUTPUT
		fi
	done
}

# Main
check_su
filter
