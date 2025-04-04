#!/bin/bash
activateSpartan()
{
	chmod +x /etc/SPARTAN/core
	systemctl enable spartan
	systemctl start spartan
	echo "Spartan Enabled"
}
if [ $EUID -ne 0 ]; then
    echo "Must be run as root"
	exit
fi
if [[ -z $1 ]]; then
	echo "Invalid usage."
	exit
fi
case "$1" in
	"1")
		cp /etc/SPARTAN/coreEasy.sh /etc/SPARTAN/core
		;;
	"easy")
		cp /etc/SPARTAN/coreEasy.sh /etc/SPARTAN/core
		;;
	"2")
		cp /etc/SPARTAN/coreMedium.sh /etc/SPARTAN/core
		;;
	"medium")
		cp /etc/SPARTAN/coreMedium.sh /etc/SPARTAN/core
		;;
	"3")
		cp /etc/SPARTAN/coreHard.sh /etc/SPARTAN/core
		;;
	"hard")
		cp /etc/SPARTAN/coreHard.sh /etc/SPARTAN/core
		;;
	*)
		echo "Invalid usage."
		exit
		;;
esac
activateSpartan