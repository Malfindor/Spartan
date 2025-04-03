#!/bin/bash
printBanner()
{
	echo " ######  ########     ###    ########  ########    ###    ##    ##"
	echo "##    ## ##     ##   ## ##   ##     ##    ##      ## ##   ###   ##"
	echo "##       ##     ##  ##   ##  ##     ##    ##     ##   ##  ####  ##"
	echo " ######  ########  ##     ## ########     ##    ##     ## ## ## ##"
	echo "      ## ##        ######### ##   ##      ##    ######### ##  ####"
	echo "##    ## ##        ##     ## ##    ##     ##    ##     ## ##   ###"
	echo " ######  ##        ##     ## ##     ##    ##    ##     ## ##    ##"
	echo "------------------------------------------------------------------"
	echo "--01010011 01110000 01100001 01110010 01110100 01100001 01101110--"
	echo "------------------------------------------------------------------"
}
printHelp()
{
	echo "Commands:"
	echo ""
	echo "exit - quit controller"
}
if [ $EUID -ne 0 ]; then
    echo "Must be run as root"
	exit
fi
while true; do
	clear
	printBanner
	read -p "Enter command: " command
	case "$command" in
		"exit")
			exit
			;;
		*)
			printHelp
			;;

done