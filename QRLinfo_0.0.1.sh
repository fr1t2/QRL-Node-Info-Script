#!/bin/bash

## QRL Node Information Script
#
#
#
# Variables
workingDIR=`pwd`;
scriptName=`basename "$0"`;
hostname=`hostname -A` 2> /dev/null;
OS=`uname`;
debianVersion=$(cat /etc/debian_version);
distro=$(awk -F= 'END { print $2 }' /etc/lsb-release);
user=`whoami`;
isUserSudo=$(awk -F':' '{ print $1}' /etc/passwd |grep $user);
goMinimumVersion=1.10;
qrlDir=/home/$user/.qrl;
LSB=/usr/bin/lsb_release



################################
#     Formatting Functions     #
################################

# Header message
function header(){
  local h="$@"
  echo -e "-------------------------------------"
  echo -e "  ${h}"
  echo -e "-------------------------------------\n"
}

# Footer message
function footer(){
  local h="$@"
  echo -e "\n-------------------------------------"
  echo -e "  ${h}"
  echo -e "-------------------------------------"
}

# Sub Header
function subHeader(){
  local h="$@"
  #echo -e "\n###########################################"
  echo -e "\n#######__ ${h} __#######\n"
  #echo -e "######################################"
}

# SubSub Header
function subSubHeader(){
local h="$@"
echo -e "\n#######__ ${h} __#######"
}

# space out
function spacer(){
echo -e "\n**********************************************\n"
}

# Error Header
function errHeader(){
  local h="$@"
  echo -e "\n**********************************************"
  echo -e "*** ! ${h} ! ***"
  echo -e "**********************************************\n"
}


################################
#     Script Dependencies      #
################################


# Sudo/ROOT check
function IsSudo(){
  #check if the user is in the /etc/passwd file, if so we have sudo!
  if [ "$isUserSudo" ]; 
    then 
      SUDO=true;  
    else 
      SUDO=false;  
  fi
  #Check if the script is run by root?
  if [ "$EUID" -ne 1000 ];
    then
      ROOT=true;
    else
      ROOT=false;
  fi
}

# go Check
function check_go(){
  if [ -x "$(command -v go)" ]; 
   then 
     #go version
      goVersion=`go version |sed -n 's/.*\([0-9]\.[0-9][0-9]*\).*/\1/p'` 2> /dev/null;
      goInstalled=true;
      if (( $(echo "$goVersion >= $goMinimumVersion" | bc -l) )); 
      then 
        goOK=true;
      else 
        goOK=false;
      fi
    else  
       goInstalled=false;
  fi
}

# python Check
function check_py(){
  if  [ -x "$(command -v python3)" ]; 
    then 
      pyVersion=`python3 --version |sed -n 's/.*\([0-9]\.[0-9]\.[0-9]*\).*/\1/p'` 2> /dev/null;
      pyInstalled=true;
      if  [ -x "$(command -v pip3)" ];
      then
        pip3Version=`pip3 -V |sed -n 's/.*\([0-9]\.[0-9]\.[0-9]*\).*/\1/p'` 2> /dev/null;
        pip3Installed=true;
      else
        pip3Installed=false;       
      fi
    else
      pyInstalled=false;
  fi
}

#check for jq to format the output of the script. 
function check_jq() {
  if  [ -x "$(command -v jq)" ]; 
    then
      jqVersion=`jq --version` 2> /dev/null;
      jqInstalled=true;
    else
      jqInstalled=false;
  fi
}


















## To Do - assign variables here and later return the data formatted.
function check_os_info(){
  # find release info
  DistributorID=`$LSB -i|sed 's/.*://'`;
  Codename=`$LSB -c |sed 's/.*://'`;
  Release=`$LSB -r |sed 's/.*://'`;
  Description=`$LSB -d |sed 's/.*://'`;


  # Print data to terminal
  subHeader " System information "
  printf "%-35s %s\n" "OS:"  "  \"$OS\""  
  printf "%-35s %s\n" "DistributorID:"  "  \"$DistributorID\""  
  printf "%-35s %s\n" "Codename:"  "  \"$Codename\""  
  printf "%-35s %s\n" "Release:"  "  \"$Release\""  
  printf "%-35s %s\n" "Description:"  "  \"$Description\""  
  printf "%-35s %s\n" "Debian Version:"  "  \"$debianVersion\""  
}


## To Do - assign variables here and later return the data formatted.
function check_host_info(){
 # header " Host INFO "
  printf "%-35s %s\n" "Hostname:"  "  \"$(hostname)\""  
  printf "%-35s %s\n" "UserName:"  "  \"$(whoami)\""  
  printf "%-35s %s\n" "ServerTime:"  "  \"$(date)\""  
  printf "%-35s %s\n" "Uptime:"  "  \"$(uptime -p)\""  
  printf "%-35s %s\n" "Up Since:"  "  \"$(uptime -s)\""  
# Print verbose information to output  
  if [ "$verbose" = true ]; 
  then
    local dnsips=$(sed -e '/^$/d' /etc/resolv.conf | awk '{if (tolower($1)=="nameserver") print $2}')
    subHeader "Verbose Net"
    printf "%-35s %s\n" "FQDN (DNS):"  "  \"$(hostname -f)\""  
    printf "%-35s %s\n" "DNS domain:"  "  \"$(hostname -d)\""  
    printf "%-35s %s\n" "Public IPv4:"  "  \"$(curl -s 'icanhazip.com')\""  
    printf "%-35s %s\n" "Local IP:"  "  \"$(hostname -i)\""  
    printf "%-35s %s\n" "DNS (DNS IP):"  "  \"$dnsips\""  
    subHeader end Verbose
  fi
}
## To Do - assign variables here and later return the data formatted.
function check_net_info(){
  devices=$(netstat -i | cut -d" " -f1 | egrep -v "^Kernel|Iface|lo")
  
  header " Network information "

  printf "%-35s %s\n" "# of interfaces:"  "  \"$(wc -w <<<${devices})\""  
  if ping -c 1 theqrl.org &> /dev/null;
  then
    connection=true;
    printf "%-35s %s\n" "Connection:"  "  \"$connection\""  ;
  else
    connection=false
    printf "%-35s %s\n" "Connection:"  "  \"$connection\""  
  fi

  if [ "$verbose" = true ]; 
  then
    subSubHeader " IP Route "
    netstat -r

    subSubHeader " TCP Ports "
    netstat -at

    subSubHeader " netstat -nr "
    netstat -nr

    subSubHeader " Traffic Stats "
    netstat -i
  fi
  #footer End NetInfo
}


## To Do - assign variables here and later return the data formatted.
function check_user_info(){
    who=$(who -u |sed 's/^\([A-Za-z0-9]*\).*/\1/');
    printf "%-35s %s\n" "User:"  "  \"$who\""  
    if [ "$verbose" = true ];
    then
      # Give verbose info about the user here
      subHeader Verbose User Info
      local User_ID=$(id);
      local List_Logins=$(lslogins -e -o USER,SHELL,PROC |grep $who);
      printf "%-35s %s\n" "User ID:"  "  \"$User_ID\""  
      printf "%-35s %s\n" "List_Logins:"  "  \"$List_Logins\""  
      header " List of last logged in users "; 
      last -ad; 
    fi
}


## To Do - assign variables here and later return the data formatted.
function check_mem_info(){
  header " Free and used memory "
  free -th

  if [ "$verbose" = true ];
  then
  subHeader " MEM STATS "
  vmstat
  subHeader " Top 10 "
  ps aux --sort -rss | head
    header " ADVANCED MEM STATS "
    subHeader " AVAIL MEM"
    free -th
    subHeader "MEM STATS"
    vmstat -s
    if [ "$debug" = true ];
    then
      subHeader "Debuging MEM"
      debugMem=`cat /proc/meminfo`
      echo -e "$debugMem"
    fi
  fi
}


function GetCPU_Info(){
cpuInfo=`lscpu -J`
isAES=$(lscpu |grep aes)
if [ "$isAES" ];
then
  AESenabled=true
else
  AESenabled=false;
fi
}


# Get uptime
function GetUptime(){
if [ -f "/proc/uptime" ]; then
uptime=`cat /proc/uptime`
uptime=${uptime%%.*}
seconds=$(( uptime%60 ))
minutes=$(( uptime/60%60 ))
hours=$(( uptime/60/60%24 ))
days=$(( uptime/60/60/24 ))
uptime="$days days, $hours hours, $minutes minutes, $seconds seconds"
else
uptime=""
fi
}


################################
# QRL Functions                #
################################

#Check for go-lang qrl installation
function check_for_gqrl(){ 
  if [ -x "$(command -v gqrl)" ]; 
  then
    qrlBase="go";
    gqrlInstalled=true;
    #using pgrep to find the process id.
    if pgrep -x "gqrl" > /dev/null;
    then
      gqrlRuns=true;
      gqrlProcess=`pgrep -x gqrl`;
    fi;
  else
    gqrlInstalled=false;
    gqrlRuns=false;
  fi;
}
# Check for python qrl installation
function check_for_pyqrl(){
  if [ -x "$(command -v qrl)" ]; 
    then
      qrlBase="python"; 
      py_qrlInstalled=true;
      py_qrlVersion=`qrl --version |sed -n 's/.*\([0-9]\.[0-9][0-9]*\).*/\1/p'`; 
      if pgrep -x start_qrl > /dev/null;
        then 
          py_qrlRuns=true;
          py_qrlProcess=`pgrep -x start_qrl`;
        else
          py_qrlRuns=false;
        fi;
    else 
    py_qrlRuns=false;
    py_qrlInstalled=false;
  fi;
}

# Use to set the state of the node. Type and process
function check_qrl(){
  check_for_pyqrl;
  check_for_gqrl;
  if [ "$gqrlRuns" = true ] || [ "$py_qrlRuns" = true ];
  then
    qrlRuns=true;
  else
    qrlRuns=false;
  fi
}


function check_qrl_testnet(){
  if [ "$qrlGenesis" = true ];
  then
    check_Testnet=$(qrl state |grep Testnet |sed 's/.*://' | sed 's|[\",]||g');
    if [ "$check_Testnet" = true ]; then
      qrlTestnet=true;
    else
      qrlTestnet=false;
    fi;
  else
    qrlTestnet=false;
fi;
}

function check_qrl_genesis(){
  if [ -f "$qrlDir/genesis.yml" ]; 
  then
    #Genesis file exsists. Set to true and grab contents
    qrlGenesis=true;
    qrlGenesisFile=$(cat "$qrlDir/genesis.yml");
  else
    qrlGenesis=false;
  fi;
  }

# Check for and print the config file. Only PYTHON currently
# depends on check_qrl...
function check_qrl_config(){
  qrlConfigFile=$qrlDir/config.yml
  if [ -f "$qrlConfigFile" ];
  then
    qrlConfigSet=true;
    if [ "$qrlBase" = python ]; 
    then
      qrlConfig=$(cat $qrlDir/config.yml)
    else
      qrlConfigSet=false;
    fi
  else
    qrlConfigSet=false;
fi
}

# Get Known Peers list from node
function check_qrl_knownpeers(){
  qrlPeersFile=$qrlDir/data/known_peers.json
  if [ -f "$qrlPeersFile" ];
  then
    qrlPeers=$(jq '.[]' $qrlPeersFile)
  else
    echo -e "No Peers File Found...";
  fi
}

function check_qrl_bannedpeers(){
  qrlBannedPeersFile=$qrlDir/banned\_peers.qrl
  if [ "$qrlBannedPeersFile" = true ];
  then
    qrlBannedPeersFound=true;
    qrlBannedPeers=$(cat $qrlBannedPeersFile |jq .);
  else
    qrlBannedPeersFound=false;
  fi
}

# qrl wallet Check
function check_qrl_wallet(){
    # check for running qrl
  if [ "$qrlRuns" = true ];
  then
    qrlWalletInfo=$(locate -c wallet.json)
    #check if python version is installed
    if [ "$qrlWalletInfo" -gt 0 ];
    then
      qrlWallet=true;
      qrlWalletCount=$(locate -c wallet.json);
      qrlWalletLocation=$(locate wallet.json);
    else
      qrlWallet=false;
      qrlWalletCount=$(locate -c wallet.json);
    fi;
  fi;
}



##########################
# Final Dependency Check #
##########################

function Dep_Check(){
  header "--- QRLinfo Dependency Check ---"
  echo "Checking for all required software and packages."
  echo "This script will exit and complain if you are missing any."
  echo "Please make sure to follow the README file before running"
 # Add all required checks here, exit if needed!
  subHeader "User Privilege"
  # Check for sudo/root. Continues if fails 
  IsSudo;
  # SUDO
  if [ "$SUDO" = true ];
  then
    printf "%-35s %s\n" "User is in sudo group:"  "  \"$SUDO\""
    #echo -e "User is sudo: \"$SUDO\""
  else
    printf "%-35s %s\n" "User is in sudo group:"  "  \"$SUDO\""
  fi   
  #ROOT 
  if [ "$ROOT" = true ];
  then
    printf "%-35s %s\n" "Script called as root:"  "  \"$ROOT\""
  else
    printf "%-35s %s\n" "Script called as root:"  "  \"$ROOT\""
  fi    
subHeader "Check Dependencies"
  # Check for go
  check_go;
  if [ "$goInstalled" = true ];
  then
    printf "%-35s %s\n" "go Installed:"  "  \"$goInstalled\""
    printf "%-35s %s\n" "go version:"  "  \"$goVersion\""
    printf "%-35s %s\n" "go OK:"  "  \"$goOK\""
    if [ "$goOK" = false ]; 
    then
      errHeader GO VERSION IS NOT MET
      errHeader UPGRADE TO GOLANG "$goMinimumVersion" to run go-qrl
    printf "%-35s %s\n" "Min Version:"  "  \"$goMinimumVersion\""
    fi
   else
    printf "%-35s %s\n" "go Installed:"  "  \"$goInstalled\""
  fi
  check_py;
  if [ "$pyInstalled" = true ];
  then
    printf "%-35s %s\n" "python Installed:"  "  \"$pyInstalled\"" 
    printf "%-35s %s\n" "python version:"  "  \"$pyVersion\"" 
    if [ "$pipInstalled" = true ];
    then
      printf "%-35s %s\n" "pip3 Installed:"  "  \"$pip3Installed\"" 
      printf "%-35s %s\n" "pip3 Version:"  "  \"$pip3Version\"" 
    else
      printf "%-35s %s\n" "pip3 Installed:"  "  \"$pip3Installed\""       
    fi
  else
    printf "%-35s %s\n" "python Installed:"  "  \"$pyInstalled\"" 
  fi

# Check for jq to output this script properly, 
# multiple checks will fail if not installed
  check_jq;
  if [ ! "$jqInstalled" = true ];
  then
    errHeader JQ Not Installed;
    printf "%-35s %s\n" "jq Installed:"  "  \"$jqInstalled\"";
    echo -e "\nThis script depends on jq to format correctly.";
    echo -e "Please install jq with:";
    echo -e "\n\tsudo apt-get install jq\n";
    echo -e "Then run this script again\n"
    # Wait for user input
    read -n 1 -s -r -p "Press any key to continue..."
    #exit
  fi    
}

function QRL_CHECK(){
  subHeader Check For QRL;
  check_qrl;
    #is go-qrl installed
    if [ "$gqrlInstalled" = true ]; 
    then
      printf "%-35s %s\n" "go-qrl Installed:"  "  \"$gqrlInstalled\""         
#      echo -e "go-qrl Installed: \"$gqrlInstalled\""; 
      if [ "$qgrlRuns" = true ];
      then
        printf "%-35s %s\n" "gqrl Running:"  "  \"$gqrlRuns\""         
        printf "%-35s %s\n" "gqrl PID:"  "  \"$gqrlProcess\""         
        #echo -e "gqrl Running: \"$gqrlRuns\""; 
        #echo -e "gqrl Process ID: \"$gqrlProcess\"";
      else
        printf "%-35s %s\n" "gqrl Running:"  "  \"$gqrlRuns\""                
        #echo -e "gqrl Running: \"$gqrlRuns\""; 
      fi        
    else
      printf "%-35s %s\n" "go-qrl Installed:"  "  \"$gqrlInstalled\""         
    fi

    #IS pyqrl installed
    if [ "$py_qrlInstalled" = true ];
    then
      printf "%-35s %s\n" "py-qrl Installed:"  "  \"$py_qrlInstalled\""         
      printf "%-35s %s\n" "py-qrl Process ID:"  "  \"$py_qrlProcess\""         
      printf "%-35s %s\n" "py-qrl Version:"  "  \"$py_qrlVersion\""      
      if [ "$verbose" = true ]; 
      then
          subSubHeader QRL State;
          qrl state;
         fi   
    else
      printf "%-35s %s\n" "py-qrl Installed:"  "  \"$py_qrlInstalled\""         
    fi
    # Is GoQRL installed?
    if [ "$gqrlInstalled" = true ] || [ "$py_qrlInstalled" = true ];
      then
        qrlInstalled=true;
        printf "%-35s %s\n" "QRL Is Installed:"  "  \"$qrlInstalled\""        
        if [ "$gqrlRuns" = true ] || [ "$py_qrlRuns" = true ]; then
          printf "%-35s %s\n" "QRL Is Running:"  "  \"$qrlRuns\""        
        else
          printf "%-35s %s\n" "QRL Is Running:"  "  \"$qrlRuns\""        
        fi
      else
        qrlInstalled=false;
        printf "%-35s %s\n" "QRL Is Installed:"  "  \"$qrlInstalled\""        
    fi


if pgrep -x "gqrl" > /dev/null;
then
    blockheight=`curl -s 127.0.0.1:19009/api/GetHeight`;
    #lastBlock=`curl -s 127.0.0.1:19009/api/GetLastBlock`;
    printf "%-35s %s\n" "blockheight:"  "  \"$blockheight\"";
    #printf "%-35s %s\n" "lastBlock:"  "  \"$lastBlock\"";       

else
  if pgrep -x start_qrl > /dev/null;
  then
    blockheight=`qrl state |grep block_height`;
    printf "%-35s %s\n" "blockheight:"  "  \"$blockheight\"";
  else 
    errHeader Blockheight not found... ERROR;
  fi
fi

# Check for testnet
  check_qrl_testnet;
  if [ "$qrlInstalled" = true ] && [ "$qrlGenesis" = true ]; 
  then
    printf "%-35s %s\n" "QRL TestNet:"  "  \"$qrlTestnet\""
    printf "%-35s %s\n" "Testnet Version:"  "  \"$check_Testnet\"" 
  else
    printf "%-35s %s\n" "QRL TestNet:"  "  \"$qrlTestnet\""
  fi


  check_qrl_genesis;
  if [ "$qrlInstalled" = true ] && [ "$qrlGenesis" = true ]; 
  then
    printf "%-35s %s\n" "QRL Genesis Found:"  "  \"$qrlGenesis\""
  else
    printf "%-35s %s\n" "QRL Genesis Found:"  "  \"$qrlGenesis\""
  fi

  check_qrl_knownpeers;

  if [ "$qrlInstalled" = true ] && [ "$qrlPeersFile" = true ]; 
  then
    printf "%-35s %s\n" "QRL KnowPeers Found:"  "  \"$qrlPeersFile\""
  else
    printf "%-35s %s\n" "QRL KnowPeers Found:"  "  \"$qrlPeersFile\""
  fi

  check_qrl_config;
  if [ "$qrlConfigSet" = true ]; 
  then
    printf "%-35s %s\n" "QRL Config Found:"  "  \"$qrlConfigSet\""
    #printf "%-35s %s\n" "QRL Config:"  "  \"$qrlConfig\""
    if [ "$verbose" = true ];
    then
    echo -e "QRL Config:\n$qrlConfig"
    fi
  else
    printf "%-35s %s\n" "QRL config Found:"  "  \"$qrlConfigSet\""
  fi


  check_qrl_bannedpeers; #needs help for go
    if [ "$qrlInstalled" = true ] && [ "$qrlBannedPeersFound" = true ]; 
  then
    printf "%-35s %s\n" "QRL Banned Peers Found:"  "  \"$qrlBannedPeersFound\""
  else
    printf "%-35s %s\n" "QRL Banned Peers Found:"  "  \"$qrlBannedPeersFound\""
  fi

  check_qrl_wallet;
  if [ "$qrlWallet" = true ]; 
  then
    printf "%-35s %s\n" "QRL wallet.json Found:"  "  \"$qrlWallet\""
    printf "%-35s %s\n" "Count of all found wallets:"  "  \"$qrlWalletCount\""
    printf "%-35s %s\n" "QRL wallet.json Location:"  "$qrlWalletLocation\n"
  else
    printf "%-35s %s\n" "QRL wallet.json Found:"  "  \"$qrlWallet\""
  fi

#footer end qrl data
}



# Combine all functions into one call
function GetCPUInfo() {
  check_os_info
  check_host_info
#  check_net_info # Need to finish this function, and print useful data.
  check_user_info
  check_mem_info
}


# The meat and potatoes
  if [[ $# -eq 0 ]]; 
  then
      Dep_Check
      GetUptime;
      printf "%-35s %s\n" "Uptime:"  "  \"$uptime\""
      GetCPUInfo
      QRL_CHECK
  fi


while [[ $# -gt 0 ]]; do
  case "$1" in
        --help|-h)
           header QRLinfo Help
           echo -e "Run this script with the additional flags";
           echo -e "Calling the script with no flags will give all output by default";
           spacer;
           printf "%-35s %s\n" "-v | --verbose"  "  \"enable additional output\"";
           printf "%-35s %s\n" "-q | --qrl"  "  \"Check QRL install info\"";
           printf "%-35s %s\n" "-c | --cpu"  "  \"Get CPU information\"";
           exit;
        ;;
        --verbose|-v)
           verbose=true;

#           GetUptime;
#           printf "%-35s %s\n" "Uptime:"  "  \"$uptime\""
#           GetCPUInfo
#           QRL_CHECK

        ;;
        --qrl|-q)
           Dep_Check
           GetUptime;
           printf "%-35s %s\n" "Uptime:"  "  \"$uptime\""
           QRL_CHECK
        ;;        

        --cpu|-c)
           GetCPUInfo
           GetUptime;
           printf "%-35s %s\n" "Uptime:"  "  \"$uptime\""
        ;;
        *) 
           header QRLinfo Help
           echo -e "Run this script with the additional flags";
           echo -e "Calling the script with no flags will give all output by default";
           spacer;
           printf "%-35s %s\n" "-v | --verbose"  "  \"enable additional output\"";
           printf "%-35s %s\n" "-q | --qrl"  "  \"Check QRL install info\"";
           printf "%-35s %s\n" "-c | --cpu"  "  \"Get CPU information\"";
           exit;
           ;;
  esac
  shift
done

if [ "$verbose" = true ] || [[ "$#" -gt 2 ]]; then
    Dep_Check
    GetUptime;
    printf "%-35s %s\n" "Uptime:"  "  \"$uptime\""
    GetCPUInfo
    QRL_CHECK
fi
