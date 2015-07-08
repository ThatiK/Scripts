#!/bin/bash


#VARIABLES
HOSTNAME_NEW=
IP_VAL=

#FUNCTIONS
function set_root_pwd(){
	echo "Change root password"
	echo "Please enter the new password:"
	read -s password1
	echo "Please repeat the new password:"
	read -s password2

	# Check both passwords match
	if [ $password1 != $password2 ]; then
	    	echo "Passwords do not match"
	        exit    
	fi

	# Change password
	echo -e "$password1\n$password1" | passwd root
	if [ $? -eq 0 ]; then
		echo "root password successfully set"
	else
		echo "password did not set"
		exit
	fi
}

function set_iptables_off(){
	echo ""
	chkconfig iptables --list
	echo "iptables off -- start"
	chkconfig iptables off
	if [ $? -eq 0 ]; then
		chkconfig iptables --list
                echo "iptables off -- success"
        else
                echo "iptables not set to off"
                exit
        fi

}

function disable_selinux(){
	echo "back up selinux -- start"
	PATH_SELINUX='/etc/sysconfig/selinux'
	cp "$PATH_SELINUX" /etc/sysconfig/selinux-backup
	
	if [ $? -eq 0 ]; then
                echo "backup selinux -- success"
        else
                echo "backup selinux -- failed"
                exit
        fi
	
	SELINUX_VAL=$(grep -i '^SELINUX=' "$PATH_SELINUX" | awk -F'=' '{print $2}')
	echo "SELINUX value is $SELINUX_VAL"

	if [[  "$SELINUX_VAL" != 'disabled' ]]; then
		sed -i "s/SELINUX=$SELINUX_VAL/SELINUX=disabled/" "$PATH_SELINUX"
		echo "SELINUX value set to disabled"
	fi
}

function set_staticIP(){
	echo "back up ifcfg-eth0 -- start"
	cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0-backup
	echo "back up ifcfg-etho1 -- success"

	FILE_PATH='/etc/sysconfig/network-scripts/ifcfg-eth0'

	IP_ADDR_KEYVAL=$(ifconfig | grep Bcast | awk '{print $2}')
	IP_VAL=$(echo $IP_ADDR_KEYVAL | awk -F':' '{print $2}')
	echo "Machine IP id $IP_VAL"
	
	echo "Set STATIC IP -- start"
	sed -i "s/^\(BOOTPROTO=\).*/\1\"static\"/" $FILE_PATH
	sed -i "s/^\(IPV6INIT=\).*/\1\"no\"/" $FILE_PATH
	sed -i "s/^\(IPV6_AUTOCONF=\).*/\1\"no\"/" $FILE_PATH
	sed -i "s/^\(NM_CONTROLLED=\).*/\1\"no\"/" $FILE_PATH
	echo IPADDR=\"$IP_VAL\" >> $FILE_PATH
	echo 'NETMASK="255.255.240.0"' >> $FILE_PATH
	echo 'GATEWAY="172.17.0.1"' >> $FILE_PATH
	echo 'DNS1="8.8.8.8"' >> $FILE_PATH
	echo "Set STATIC IP -- success"
	
	echo "################################"
	cat "$FILE_PATH"
	echo "################################"
}

function set_hostname(){
	PATH_NETWORK='/etc/sysconfig/network'

	echo "backup network -- start"
	cp /etc/sysconfig/network /etc/sysconfig/network-backup
	echo "backup network -- sucess"

	echo "changing hostname"
	HOSTNAME_CURR=$(grep -i '^HOSTNAME=' "$PATH_NETWORK" | awk -F'=' '{print $2}')

        echo "Current hostname is $HOSTNAME_CURR"
        sed -i "s/HOSTNAME=$HOSTNAME_CURR/HOSTNAME=$HOSTNAME_NEW/" "$PATH_NETWORK"
	if [ $? -eq 0 ]; then
		echo "replaced value in network file with new hostname as $HOSTNAME_NEW"
	fi

	hostname "$HOSTNAME_NEW"	
	if [ $? -eq 0 ]; then
		echo "Also changed hostname temporarily. No need to reboot"
	fi	
	
}

function add_host(){
	PATH_HOSTS=/etc/hosts
	echo "backup hosts -- start"
	cp "$PATH_HOSTS" /etc/hosts-backup
	echo "backup hosts -- success"

	echo "$IP_VAL	$HOSTNAME_NEW" >> "$PATH_HOSTS"
	if [ $? -eq 0 ]; then
                echo "$IP_VAL	$HOSTNAME_NEW added to hosts"
        fi
}

function restart_network(){
	/etc/init.d/network restart
}

function usage(){
	script=$0
	cat <<USAGE
Syntax
`basename ${script}` -h
-h: specify the hostname you would like to assign for this machine
USAGE
	exit 1
}

function main(){
	echo "Hostname provided : $HOSTNAME_NEW"
	read -p "Are you sure? [y/n] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		set_root_pwd
		set_iptables_off
		disable_selinux
		set_staticIP
		restart_network
		set_hostname
		add_host
	else
		exit 1
	fi

}

while getopts h:help: opt; do
	case "${opt}" in
	h) 
		HOSTNAME_NEW=$OPTARG
		main
		;;
	help)	
		usage
		;;
	\?)
		usage
		;;
	esac
done

if [ $# -eq 0 ]; then
    usage
fi
