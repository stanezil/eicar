#!/bin/bash

function validations() {

	[[ "$EUID" -ne 0 ]] && { echo; echo -e "\e[4mAttention\e[24m: please login as ROOT."; echo; exit; }

	[[ -z $(slk status) || $(slk status | grep -i "management server status" | awk -F: '{print $2}') != " connected" ]] && { echo; echo -e "\e[4mAttention\e[24m: Aqua installation is not detected OR the Agent is not connected to its Server."; echo; exit; }

}


function dnsReputation() {

	DNS=($(slk restricted_dns show | sed -r '/^\s*$/d' | sed -r '1d;$d' | awk 'BEGIN {srand()} !/^$/ { if (rand() <= .05) print $0}'))

	dnsStatus=0

		for d in "${DNS[@]}"; do
			curl -k -m 5 "$d" >/dev/null 2>&1
				[[ $? -eq 28 ]] && ((dnsStatus++))
				[[ $dnsStatus -gt 0 ]] && { DNS="$d"; return; }
		done

}


function ipReputation() {

	IP=($(slk restrictedips show | sed -r '/^\s*$/d' | sed -r '1d;$d' | awk 'BEGIN {srand()} !/^$/ { if (rand() <= .05) print $0}'))

	ipStatus=0

	if [[ -z "${IP[5]}" ]]
		then { IP="
Dev-CyberCenter is detected.
Follow these steps to get the list of Blocked IP's:
1- Login to the Console.
2- Goto 'Settings ==> Aqua CyberCenter'.
3- Replace the existing URL with https://cybercenter5.aquasec.com and save."; return; }
		else
			for i in "${IP[@]}"; do
				curl -k -m 5 "$i" >/dev/null 2>&1
					[[ $? -eq 28 ]] && ((ipStatus++))
					[[ $ipStatus -gt 0 ]] && { IP="$i"; return; }
			done
	fi

}


function cryptoMining() {

	CMR=($(slk restricted_crypto_mining_dns show | sed -r '/^\s*$/d' |sed -r '1d;$d' | awk 'BEGIN {srand()} !/^$/ { if (rand() <= .05) print $0}'))

	cmrStatus=0

		for c in "${CMR[@]}"; do
			curl -k -m 5 "$c" >/dev/null 2>&1
				[[ $? -eq 28 ]] && ((cmrStatus++))
				[[ $cmrStatus -gt 0 ]] && { CMR="$c"; return; }
		done

}


#MAIN
validations

clear
echo "##############################################################################"
echo "##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++##"
echo "##+                                                                        +##"
echo "##+   This script provides one example of valid IP/DNS/Cryptomining        +##"
echo -e "##+   resource for demo or \e[4minternal\e[24m testing purposes.                      +##"
echo "##+   Before execution make sure that the Host Protection RT controls      +##"
echo "##+   set to Enabled, the Host you run the script on is in the Runtime     +##"
echo "##+   Policy scope, and the Policy with \"DNS/IP Reputation\" and            +##"
echo "##+   \"Block Cryptocurrency Mining\" controls is in the Enforcement Mode.   +##"
echo "##+                                                                        +##"
echo "##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++##"
echo "##############################################################################"
echo
read -r -p "Ready to proceed? [yes/no]: " input
echo

[[ "$input" != "yes" ]] && { echo "Process aborted."; exit; }


echo "~~~~~~~~~~~~~~~~~~~~"
echo " Fetching valid \"Cryptomining URL\" example"
while true
	do echo -n .
		sleep 0.5
	done & cryptoMining && echo && echo "	Cryptomining URL for testing is: "$CMR""
kill $!; trap 'kill $!' SIGTERM

echo && echo "~~~~~~~~~~~~~~~~~~~~"
echo " Fetching valid \"Bad DNS\" example"
while true
	do echo -n .
		sleep 0.5
	done & dnsReputation && echo && echo "	Bad DNS for testing is: "$DNS""
kill $!; trap 'kill $!' SIGTERM

echo && echo "~~~~~~~~~~~~~~~~~~~~"
echo " Fetching valid \"Bad IP\" example"
while true
	do echo -n .
		sleep 0.5
	done & ipReputation && echo && echo "	Bad IP for testing is: $(echo "$IP")"
kill $!; trap 'kill $!' SIGTERM
echo