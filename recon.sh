#!/bin/bash
domain=$1 threads=$2

enum(){
        assetfinder -subs-only "${domain}" | tee -a domains
        cat domains | anew domains.txt
	amass enum -brute -active --passive -d "${domain}" -o domains -config ~/.config/amass/config.ini
        cat domains | anew domains.txt
        rm domains
        subfinder -silent -d "${domain}" -o domains
        cat domains | anew domains.txt
        rm domains
        cat domains.txt | httpx -silent | tee -a hosts.txt
        cat domains.txt | aquatone -out screens -scan-timeout 200 -screenshot-timeout 60000 -ports xlarge
        naabu -silent -iL domains.txt > portscan.txt
        subjack -w domains.txt -t 100 -timeout 20 -o subjack_out.txt --ssl -c ~/fingerprints.json
	nuclei -l hosts.txt -t cves/ | tee -a vuln.txt
	jaeles scan -s ~/.jaeles/ -U hosts.txt
	for i in $(cat hosts.txt); do ffuf -u $i/FUZZ -w ~/Documents/bugbounty/wordlist/dir.txt -ac -c -e php,txt,asp,html,aspx; done
}

main()
{

	mkdir "${domain}" && cd "${domain}"
	echo "Starting Recon on ${domain}"
	echo "Threads consumed : ${threads}"

	echo "Enumration + Content Discovery starting..."
	enum
	
}

main
