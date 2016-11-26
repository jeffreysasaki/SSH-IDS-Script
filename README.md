Intrusion Detection and Prevention Script
===============================================================================

Description:
-------------------------------------------------------------------------------
- The purpose of this script is to monitor the SSH log file and block
  any incoming IP that fails to log in for a specified number of times.

Usage:
-------------------------------------------------------------------------------
1.) Configure SSHLOG based on the distribution
```
SSHLOG="/var/log/secure"   # For RPM-based distro (eg. Fedora)
SSHLOG="/var/log/auth.log" # For Debian-based distro (eg. Ubuntu)
```
2.) Run script by using the following command:
```
./ids.sh
```