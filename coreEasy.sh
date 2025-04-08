#!/bin/bash
whitelistUsers=()
passwordWordList=("Crimson","Echo","Zephyr","Jungle","Quartz","Falcon","Nimbus","Vortex","Frosty","Glimmer","Onyx","Tundra","Cipher","Basilisk","Rocket","Hollow","Pixel","Rogue","Ivory","Cobalt")
symbolList=("!","$","%","-")
genRandPercent()
{
	PERCENT_CHANCE=$((1 + $RANDOM % 100))
}
newPassGen() #Generates into variable $NEW_PASS
{
	local conflict=$false
	local passNum="$((RANDOM % 10))"
	local wordIndex1=$((RANDOM % 20))
	local wordIndex2=$((RANDOM % 20))
	while [[ $wordIndex1 -eq $wordIndex2 ]]; do
		wordIndex2=$((RANDOM % 20))
	done
	local word1="${passwordWordList[$wordIndex1]}"
	local word2="${passwordWordList[$wordIndex2]}"
	local symbol="${symbolList[$((RANDOM % 4))]}"
	NEW_PASS=""
	
	NEW_PASS="$word1" + "$symbol" + "$word2" + "$passNum"
}
processPasswordReset()
{
	local username="$1"
	newPassGen
	echo "$username:$NEW_PASS" | chpasswd
}
getFileContAsArray() #usage: "getFileCont {file name} {array variable name}"
{
	local fileName="$1"
	local -n arr="$2"
	if [[ ! -f "$fileName" ]]; then
		return 1
	fi
	mapfile -t arr < "$fileName"
}
getFileContAsStr()
{
	local fileName="$1"
	local -n fileCont="$2"
	if [[ ! -f "$fileName" ]]; then
        fileCont=""
	else
		fileCont=$(<"$fileName")
    fi
}
userInWhitelist() 
{
    local user="$1"
	local -n result="$2"
	result="4"
    for entry in "${whitelistUsers[@]}"; do
        if [[ "$entry" == "$user" ]]; then
            result="2"
        fi
    done
    if [[ ! $result == "2" ]]; then
		result="3"
	fi
}
checkForRemoteLogins()
{
	mapfile -t loginList < <(who)
	for login in "${loginList[@]}"; do
		IFS=" " read -ra loginSplit <<< "$login"
		if [[ "${#loginSplit[@]}" == 5 ]]; then
			IFS="." read -ra ipList <<< "${loginSplit[4]}"
			if [[ "${#ipList}" == 4 ]]; then
				user="${loginSplit[0]}"
				seat="${loginSplit[1]}"
				echo "Nice try." | write $user $seat
				pkill -KILL -t $seat
				date="${loginSplit[2]}"
				time="${loginSplit[3]}"
				remoteIP="${loginSplit[4]}"
				current_time=$(date +"%H:%M:%S")
				log="[ $current_time ] - A remote login was detected. User: $user was logged into at $date : $time from address: $remoteIP using seat: $seat"
				echo $log >> /etc/SPARTAN/spartan.log
				userInWhitelist $user isInWhitelist
				if [[ $isInWhitelist == "3" ]]; then
					genRandPercent
					if [[ $PERCENT_CHANCE -lt 31 ]]; then
						userdel -f $user
						current_time=$(date +"%H:%M:%S")
						log="[ $current_time ] - An unknown user tried to remote in to this machine: $user"
						echo $log >> /etc/SPARTAN/spartan.log
					fi
				else
					processPasswordReset "$user"
				fi
			fi
		fi
	done
}
checkForUnknownUsers()
{
	getFileContAsArray "/etc/passwd" passwdConts
	for line in "${passwdConts[@]}"; do
		IFS=":" read -ra userInfo <<< "$line"
		username=${userInfo[0]}
		declare -i uid=${userInfo[2]}
		declare -i gid=${userInfo[3]}
		userInWhitelist $username isInWhitelist
		if [[ $isInWhitelist == "3" ]]; then
			userdel -f $username
			current_time=$(date +"%H:%M:%S")
			log="[ $current_time ] - An unknown user with UID/GID $uid : $gid was found and removed: $username"
			echo $log >> /etc/SPARTAN/spartan.log
		fi
	isInWhitelist=""
done
}
checkCrontab()
{
	getFileContAsStr "/etc/crontab" crontabCont
	if [[ ! "${#crontabCont}" == 0 ]]; then
		if [[ ! "$crontabCont" == "\n" ]]; then
			echo "" > /etc/crontab
			current_time=$(date +"%H:%M:%S")
			log="[ $current_time ] - Changes were detected in /etc/crontab and removed: $crontabCont"
			echo $log >> /etc/SPARTAN/spartan.log
		fi
	fi
}
doInitialHardening()
{
	newPassGen
	echo "root:$NEW_PASS" | chpasswd
	newPassGen
	echo "sysadmin:$NEW_PASS" | chpasswd
	echo "" > /etc/crontab
	getFileContAsArray "/etc/passwd" passwdConts
	for line in "${passwdConts[@]}"; do
		IFS=":" read -ra userInfo <<< "$line"
		username=${userInfo[0]}
		whitelistUsers+=("$username")
	done
}
# If checking for remote logins and finds one, reset password of user that was found, possibly delete if it's not known
# At any given time - 20% to check users, 40% to check crontab, 40% to check remote logins
# Wait between 30 secs and 5 minutes
if ! [[ -f /etc/SPARTAN/HARDEN_COMPLETE.flag ]]; then
	doInitialHardening
fi
while true; do
	genRandPercent
	if [[ $PERCENT_CHANCE -lt 21 ]]; then
		checkForUnknownUsers
	elif [[ $PERCENT_CHANCE -lt 61 ]]; then
		checkCrontab
	else
		checkForRemoteLogins
	fi
	
	sleep $((30 + $RANDOM % 271))
done