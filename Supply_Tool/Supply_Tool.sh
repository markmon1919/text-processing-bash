#!/bin/bash

BRED='\033[1;91m'; YEL='\033[1;33m'; CYA='\033[0;36m'
LGRE='\033[1;32m'; ORA='\033[0;33m'; GRE='\033[0;32m'
LPUR='\033[1;35m'; PUR='\033[0;35m'; DGRA='\033[1;30m'
LBLU='\033[1;34m'; U='\e[4m'; IN='\e[7m'
NT='\e[0m'; NC='\033[0m'

echo -e "${YEL}\n+-----------+-----------+"
echo -e " ${BRED}Supply Automation Tool${NC} \n by ${LGRE}Mark Mon Monteros"
echo -e "${YEL}+-----------+-----------+"
echo -e " ${CYA}### Coded in Bash ###${NC}\n"

### OLD ###
# Filter the “IG and Resources Reqd From” column to: SFDC IPS, Oracle IPS, Workday IPS.  
# Remove all the “Contractors” from the “Personnel No” column.  
# If possible, delete all the columns from the attachment (Supply To Be Deleted) to the HC report.  
# Save file as .csv (Comma Delimited) for Data Loader upload.  

#Step 1 - convert first to Tab Delimited
#TOTAL RECORDS = 27,545

### NEW ###
# Filter IG to: “SFDC IPS, Workday IPS and Oracle IPS”.
# Filter Resources Reqd From to: “Salesforce IPS, Oracle IPS and Workday IPS”.
# Include “Contractors” from Personnel No. column after two filers (#1 & #2 step).
# Get the “Technology” column of the 1st attachment (Consolidated HC Report) to the “Technology” column of the Supply extract file.
# Delete all the columns based from the 2nd attachment (Supply To Be Deleted) file to the Supply extract file.

echo -e "		${BRED}${IN}<-- I N S T R U C T I O N S -->${NT}${NC}"
echo -e "[${LBLU}1${NC}] ${ORA}Open files Supply To Be Deleted.xls --> Save As to${NC} ${CYA}Tab Delimited${NC}"
echo -e "[${LBLU}2${NC}] ${ORA}Open Consolidated HC Report.xls --> Save As to${NC} ${CYA}Tab Delimited${NC}"
echo -e "[${LBLU}3${NC}] ${ORA}Open Consolidated HC Report.xls again --> Save As to${NC} ${CYA}CSV UTF-8${NC}"
echo -e "[${LBLU}4${NC}] ${ORA}Open Consolidate for reporting.xls --> Save As to${NC} ${CYA}Tab Delimited${NC}"
echo -e "[${LBLU}5${NC}] ${ORA}Open Consolidated for reporting.xls again --> Save As to${NC} ${CYA}CSV UTF-8${NC}"
echo -e "[${LBLU}6${NC}] ${ORA}Execute Script${NC}"
echo -e "[${LBLU}7${NC}] ${ORA}Open output file and Replace all${NC} ${YEL}'${NC}${PUR}Ã±${NC}${YEL}'${NC} ${ORA}characters to${NC} ${YEL}'${NC}${PUR}ñ${NC}${YEL}'${NC}"

path=$(pwd)

#Rename Sheets filename (remove whitespaces)
echo -e "\nRemoving whitespaces..."
sleep 1
echo -e "Renaming Sheet filenames..."
for i in *\ *; do 
	mv "$i" "${i// /_}" > /dev/null 2>&1
done

#GET CSV UTF-8 FILE
supplyHeader=$(ls "$path" | grep -e ".txt$" | grep -e "Supply_To_Be_Deleted*")
hcReportCSV=$(ls "$path" | grep -e ".csv$" | grep -e "HC")
hcReportTAB=$(ls "$path" | grep -e ".txt$" | grep -e "HC")
forReportingCSV=$(ls "$path" | grep -e ".csv$" | grep -v "$supplyHeader" | grep -v "$hcReportCSV")
forReportingTAB=$(ls "$path" | grep -e ".txt$" | grep -v "$supplyHeader" | grep -v "$hcReportTAB")

#GET LINE COUNT FROM TAB DELIMITED
echo "Counting Lines..."
hcLines="sed -n 1,"
hcLines+=$(cat "$path"/"$hcReportTAB" | wc -l)
hcLines+="p"
forLines="sed -n 1,"
forLines+=$(cat "$path"/"$forReportingTAB" | wc -l)
forLines+="p"

#ARRANGE SHEETS
echo -e "\nArranging Sheets..."
#HC REPORT -- 1,058 lines
echo -e "[${BRED}*${NC}]${GRE}$hcReportCSV${NC}"
cat "$path"/$hcReportCSV | sed -e 's/,\s/~/g' | tr ' ' '~' | tr ',' '\t' | awk '{print$2}' | $hcLines > "$path"/hcNames
echo -e "[${BRED}*${NC}]${GRE}$hcReportTAB${NC}"
cat "$path"/$hcReportTAB | sed -e 's/, /~/g' -e 's/,/~/g' | tr ' ' '~' | tr '\t' ',' | sed -e 's/^,/NULL,/' -e 's/,,/,NULL,/g' -e 's/,$/,NULL/' | sed -e 's/,,/,NULL,/g' | tr ',' '\t' > "$path"/hcOthers
cat "$path"/hcOthers | tr '\t' ',' | cut -d, -f2 --complement > "$path"/hcOthers2
paste -d, <(cut -d, -f1 "$path"/hcOthers2) <(cut -d, -f2 "$path"/hcNames) <(cut -d, -f1 --complement "$path"/hcOthers2) | tr ',' '\t' > "$path"/hcReport.csv
rm "$path"/hcNames "$path"/hcOthers "$path"/hcOthers2
#FOR REPORT -- 27,684 lines
echo -e "[${BRED}*${NC}]${GRE}$forReportingCSV${NC}"
cat "$path"/$forReportingCSV | sed -e 's/,\s/~/g' | tr ' ' '~' | tr ',' '\t' | awk '{print$2}' | $forLines > "$path"/forNames
echo -e "[${BRED}*${NC}]${GRE}$forReportingTAB${NC}"
cat "$path"/$forReportingTAB | sed -e 's/, /~/g' -e 's/,/~/g' | tr ' ' '~' | tr '\t' ',' | sed -e 's/^,/NULL,/' -e 's/,,/,NULL,/g' -e 's/,$/,NULL/' | sed -e 's/,,/,NULL,/g' | tr ',' '\t' > "$path"/forOthers
cat "$path"/forOthers | tr '\t' ',' | cut -d, -f2 --complement > "$path"/forOthers2
paste -d, <(cut -d, -f1 "$path"/forOthers2) <(cut -d, -f2 "$path"/forNames) <(cut -d, -f1 --complement "$path"/forOthers2) | tr ',' '\t' > "$path"/forReporting.csv
rm "$path"/forNames "$path"/forOthers "$path"/forOthers2

#GET HEADERS
echo -e "\nGet Headers..."
echo -e "[${BRED}*${NC}]${GRE}$supplyHeader${NC}"
cat "$path"/$supplyHeader | tr ' ' '~' | tr ',' '\t' > "$path"/supplyHeader.csv
declare SUPPLY_HEADER=(`cat "$path"/supplyHeader.csv`)
cat "$path"/hcReport.csv | head -n 1 > "$path"/hcReportHeader.csv
declare HCREPORT_HEADER=(`cat "$path"/hcReportHeader.csv`)
cat "$path"/forReporting.csv | head -n 1 > "$path"/forReportingHeader.csv
declare FORREPORT_HEADER=(`cat "$path"/forReportingHeader.csv`)

#GET IG Column AS(#45--1,422) && Reqd Column BA(#53--1,236) = 1,477 total
#MAKE DYNAMIC IN FUTURE
echo -e "\nFiltering IG and Reqd Columns..."
cat "$path"/forReporting.csv | sed -e '1d' | awk '{if ($45 == "SFDC~IPS" || $45 == "Oracle~IPS" || $45 == "Workday~IPS" || $53 == "Salesforce~IPS" || $53 == "Oracle~IPS" || $53 == "Workday~IPS") print$0}' | tr ' ' ',' > "$path"/draft.csv
rm "$path"/forReporting.csv
cat "$path"/forReportingHeader.csv "$path"/draft.csv > "$path"/forReporting.csv
rm "$path"/draft.csv

#REMOVING HEADERS FROM SUPPLY
#get header
echo -e "Finding Headers from Supply Sheet..."
touch "$path"/delCol_num

for (( i=0; i<${#SUPPLY_HEADER[@]}; i++ )); do
	for (( j=0; j<${#FORREPORT_HEADER[@]}; j++ )); do
		position=$(( $j + 1 ))
		if [[ ${SUPPLY_HEADER[i]} == ${FORREPORT_HEADER[j]} ]]; then
			echo $position >> "$path"/delCol_num 
		fi
	done
done
#cut header
declare DELCOL_NUM=$(cat "$path"/delCol_num)
echo ${DELCOL_NUM[@]} | tr ' ' ',' > "$path"/delCol
delCol=$(cat "$path"/delCol)
echo -e "Cutting Columns..."
cat "$path"/forReporting.csv | tr '\t' ',' | cut -d, -f$delCol --complement | tr ',' '\t' > "$path"/header.csv
rm "$path"/delCol "$path"/delCol_num
#Setting new output header
echo -e "Setting New Output Headers..."
rm "$path"/forReporting.csv "$path"/forReportingHeader.csv "$path"/supplyHeader.csv
mv "$path"/header.csv "$path"/forReporting.csv
unset FORREPORT_HEADER
declare FORREPORT_HEADER=(`cat "$path"/forReporting.csv | head -n 1`)
cat "$path"/forReporting.csv | head -n 1 > "$path"/forReportingHeader.csv

#GET NAMES
touch "$path"/hcNames_num
touch "$path"/forNames_num
#find Names Column Number in Header
echo -e "Finding Name Column..."
for (( i=0; i<${#HCREPORT_HEADER[@]}; i++ )); do
	position=$(( $i + 1 ))
	if [[ ${HCREPORT_HEADER[i]} == "Name" ]]; then
		echo $position >> "$path"/hcNames_num
	fi
done

for (( i=0; i<${#FORREPORT_HEADER[@]}; i++ )); do
	position=$(( $i + 1 ))
	if [[ ${FORREPORT_HEADER[i]} == "Name" ]]; then
		echo $position >> "$path"/forNames_num
	fi
done

#MATCH Names Column
hcNames_num=$(cat "$path"/hcNames_num | head -n 1)
forNames_num=$(cat "$path"/forNames_num | head -n 1)

#GET Technology Column Number @ HC_REPORT SHEET
touch "$path"/hcTech_num
#find Technology Column Number in Header
echo -e "\nGet Technology Column..."
echo -e "Finding Technology Column..."
for (( i=0; i<${#HCREPORT_HEADER[@]}; i++ )); do
	position=$(( $i + 1 ))
	if [[ ${HCREPORT_HEADER[i]} == "Technology" ]]; then
		echo $position >> "$path"/hcTech_num
	fi
done
#cut Technology Column
echo -e "Cutting Technology Column..."
hcTech_num=$(cat "$path"/hcTech_num | head -n 1)
cat "$path"/hcReport.csv | sed -e '1d' | tr '\t' ',' | cut -d, -f$hcTech_num > "$path"/hcTech_col
#replace NULL to Non-Cloud
echo -e "Replacing N/A values to Non-Cloud..."
sed -e 's/^\s/Non-Cloud/g' -i "$path"/hcTech_col

#cut Names and Technology Column
echo -e "Cutting Name and Technology Columns..."
#1057 lines for HC
cat "$path"/hcReport.csv | sed -e '1d' | tr '\t' ',' | cut -d, -f$hcNames_num | tr ',' '\t' > "$path"/hcNames_col 
echo -e "Matching Name Column..."
#1477 lines for FOR
cat "$path"/forReporting.csv | sed -e '1d' | tr '\t' ',' | cut -d, -f$forNames_num > "$path"/forNames_col 

#VLookup Names HC and FOR Reports
echo -e "VLOOKUP Names..."

declare HC_NAMES=(`cat "$path"/hcNames_col`)
declare FOR_NAMES=(`cat "$path"/forNames_col`)

touch "$path"/names_match
for (( i=0; i<${#HC_NAMES[@]}; i++ )); do
	for (( j=0; j<${#FOR_NAMES[@]}; j++ )); do
		if [[ ${HC_NAMES[i]} == ${FOR_NAMES[j]} ]]; then
			echo ${HC_NAMES[i]} >> "$path"/names_match
			break
		fi
	done
done	

cat "$path"/forReporting.csv | grep -f "$path"/names_match | awk '{print$2}' > "$path"/forGrepNames
cat "$path"/forGrepNames | grep -f "$path"/hcNames_col > "$path"/hcGrepNames

declare HCGREP_NAMES=(`cat "$path"/hcGrepNames`)
declare HC_NAMES=(`cat "$path"/hcNames_col`)
declare HC_TECH=(`cat "$path"/hcTech_col`)
touch "$path"/insert

for (( i=0; i<${#HCGREP_NAMES[@]}; i++ )); do
	for (( j=0; j<${#HC_NAMES[@]}; j++ )); do
		if [[ ${HCGREP_NAMES[i]} == ${HC_NAMES[j]} ]]; then
			echo ${HC_TECH[j]} >> "$path"/insert
			break
		fi
	done
done

#should get 1,022 records
#FILTER NAME and TECHNOLOGY Columns -- 1,025 records
echo -e "Filtering Name and Technology Columns..."
#OUTPUT should be 1,022 records
cat "$path"/forReporting.csv | grep -f "$path"/hcGrepNames > "$path"/draft.csv

echo Technology > "$path"/techHeader
cat "$path"/techHeader "$path"/insert > "$path"/insert_col4
rm "$path"/insert "$path"/techHeader "$path"/forGrepNames "$path"/forNames_col "$path"/forNames_num "$path"/hcGrepNames "$path"/hcNames_col "$path"/hcNames_num "$path"/hcTech_num "$path"/hcTech_col

#EDIT FINAL OUTPUT SHEET
echo -e "\nEditing Output Sheet"
#inserting header
cat "$path"/forReportingHeader.csv "$path"/draft.csv > "$path"/output.csv

#insert Technology to Column #4
echo -e "Inserting Technology Columns"
cat "$path"/output.csv | tr '\t' ',' | cut -d, -f1-3 > "$path"/first3_col
cat "$path"/output.csv | tr '\t' ',' | cut -d, -f1-3 --complement > "$path"/other_col
paste -d, <(cut -d, -f1-3 "$path"/first3_col) <(cut -d, -f1 "$path"/insert_col4) <(cut -d, -f1 --complement "$path"/other_col) > "$path"/final.csv
rm "$path"/names_match "$path"/insert_col4 "$path"/other_col "$path"/output.csv "$path"/first3_col

#Fixing Output Sheet
echo -e "Fixing Output Sheet..."
cat "$path"/final.csv | head -n 1 | tr '~' ' ' > "$path"/header.csv
cat "$path"/final.csv | sed -e '1d' | sed -e 's/~/, /' | tr '~' ' ' | sed -e 's/NULL//g' > "$path"/body.csv
rm "$path"/draft.csv "$path"/final.csv
cat "$path"/header.csv "$path"/body.csv > "$path"/final_output.csv
rm "$path"/header.csv "$path"/body.csv "$path"/forReporting.csv "$path"/hcReport.csv "$path"/forReportingHeader.csv "$path"/hcReportHeader.csv

#Saving...
echo -e "\n${PUR}${IN}Enter output filename: ${NT}${NC}"
read filename
mv "$path"/final_output.csv "$path"/"$filename".csv

echo -e "\n${ORA}Saving file as..."
echo -e "${LBLU}$path/${GRE}$filename".csv${NC}
echo -e "\n${CYA}${IN} D ${LGRE} O ${YEL} N ${PUR}${IN} E ${NC}!!!"