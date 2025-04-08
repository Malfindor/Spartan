#!/bin/bash
whitelistUsers=()
genRand()
passwordWordList=("Crimson","Echo","Zephyr","Jungle","Quartz","Falcon","Nimbus","Vortex","Frosty","Glimmer","Onyx","Tundra","Cipher","Basilisk","Rocket","Hollow","Pixel","Rogue","Ivory","Cobalt")
symbolList=("!","$","%","-")
{
	PERCENT_CHANCE=$((1 + $RANDOM % 100))
}
newPassGen()
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
	if [[ $uid -gt $UID_GID_LIMIT || $gid -gt $UID_GID_LIMIT ]] && [[ $isInWhitelist == "3" ]]; then
		userdel -f $username
		current_time=$(date +"%H:%M:%S")
		log="[ $current_time ] - An unknown user with UID/GID above $UID_GID_LIMIT was found and removed: $username"
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
#If checking for remote logins and finds one, reset password of user that was found, possibly delete if it's not known