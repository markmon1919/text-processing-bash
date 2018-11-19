#!/bin/bash

BRED='\033[1;91m'; YEL='\033[1;33m'; CYA='\033[0;36m'
LGRE='\033[1;32m'; ORA='\033[0;33m'; GRE='\033[0;32m'
LPUR='\033[1;35m'; PUR='\033[0;35m'; DGRA='\033[1;30m'
LBLU='\033[1;34m'; U='\e[4m'; IN='\e[7m'
NT='\e[0m'; NC='\033[0m'

echo -e "${YEL}\n+-----------+-----------+"
echo -e " ${BRED}Demand Automation Tool${NC} \n  by ${LGRE}Mark Mon Monteros"
echo -e "${YEL}+-----------+-----------+"
echo -e " ${CYA}### Coded in Bash ###${NC}\n"

path=$(pwd)

#Rename CSV file (remove whitespaces)
echo -e "\nRemoving whitespaces..."
sleep 1
echo -e "Renaming CSV files..."
for i in *\ *; do 
	mv "$i" "${i// /_}" > /dev/null 2>&1
done

#START
declare CSVFILES=(`ls "$path" | grep -e .csv$ | grep -v "ATCP_keymatch_results_combined*"`)
cat "$path"/"ATCP_keymatch_results_combined".csv | grep -o R[0-9]* | egrep '^.{7,7}$' > "$path"/atcp_rrd

#MATCH ALL ATCP_RRD to CSV RRD
touch "$path"/dcso_out.csv
for i in ${CSVFILES[*]}; do
	cat "$path"/$i | grep -f "$path"/atcp_rrd >> "$path"/dcso_out.csv
	echo -e "[${BRED}*${NC}] ${GRE}$i${NC}"
done

#APPEND Nice to Have Skills to header
cat "$path"/"ATCP_keymatch_results_combined".csv | head -n 1 | tr ' ' '~' | tr ',' ' ' | awk 'BEGIN { OFS = "\t" } { $152 = "Additional~Skills~(Nice~to~have~this)" $152; print }' | tr '\t' ',' | tr '~' ' ' > "$path"/header.csv

#GET Additional Skills from DCSO
declare DCSO_ADDSKILLS=(`cat "$path"/dcso_out.csv | tr ' ' '~' | sed -e 's/^,/NULL,/g' -e 's/,,/,NULL,/g' -e 's/,$/,NULL/g' -e 's/,,/,NULL,/g' | cut -d, -f1-8 --complement | tr ',' ' ' | awk '{print$1}'`)
declare DCSO_RRD=(`cat "$path"/dcso_out.csv | tr ' ' '~' | sed -e 's/^,/NULL,/g' -e 's/,,/,NULL,/g' -e 's/,$/,NULL/g' -e 's/,,/,NULL,/g' | cut -d, -f1-8 --complement | tr ',' ' ' | awk '{print$27}'`)

touch "$path"/append.csv

for (( i=0; i<${#DCSO_RRD[*]}; i++ )); do
	cat "$path"/"ATCP_keymatch_results_combined".csv | grep ${DCSO_RRD[i]} | tr ' ' '~' | sed -e 's/,$//' -e 's/^,/NULL,/g' -e 's/,,/,NULL,/g' -e 's/,$/,NULL/g' -e 's/,,/,NULL,/g' -e 's/,~/?/g' | tr ',' ' '| awk -v var="${DCSO_ADDSKILLS[i]}" 'BEGIN { OFS = "\t" } { $152 = var $152; print }' | tr '\t' ',' | sed -e 's/,$//' -e 's/^,/NULL,/g' -e 's/,,/,NULL,/g' -e 's/,$/,NULL/g' -e 's/,,/,NULL,/g' >> "$path"/append.csv
done

echo -e "${DGRA}Number of parsed CSV files: ${#CSVFILES[*]}\n${NC}"

cat "$path"/append.csv | tr '~' ' ' >> "$path"/header.csv

#Saving output file
echo -e "\n${PUR}${IN}Enter output filename: ${NT}${NC}"
read filename
cat "$path"/header.csv | sed -e 's/?/,~/g' -e 's/NULL//g' | tr '~' ' ' > "$path"/"$filename".csv

#FILTER ALL ATCP_RRD to CSV RRD
cat "$path"/"$filename".csv | grep -o R[0-9]* | egrep '^.{7,7}$' > "$path"/filter
cat "$path"/"ATCP_keymatch_results_combined".csv | sed -e '1d' | grep -vf "$path"/filter >> "$path"/"$filename".csv

rm "$path"/atcp_rrd "$path"/filter "$path"/dcso_out.csv "$path"/append.csv "$path"/header.csv
echo -e "\n${ORA}Saving file as..." 
echo -e "${LBLU}$path/${GRE}$filename".csv${NC}
echo -e "\n${CYA}${IN} D ${LGRE} O ${YEL} N ${PUR}${IN} E ${NC}!!!"