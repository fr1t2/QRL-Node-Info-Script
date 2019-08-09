#!/bin/bash

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


## To Do - assign variables here and later return the data formatted.
function check_os_info(){
  # find release info
  DistributorID=`$LSB -i|sed 's/.*://' |tr -d '\t'`;
  Codename=`$LSB -c |sed 's/.*://' |tr -d '\t'`;
  Release=`$LSB -r |sed 's/.*://' |tr -d '\t'`;
  Description=`$LSB -d |sed 's/.*://' |tr -d '\t'`;
}

# Get Known Peers list from node
function check_qrl_knownpeers(){
  qrlPeersFile=$qrlDir/data/known_peers.json
  if [ -f "$qrlPeersFile" ];
  then
    qrlPeers=$(jq -r '.PeersInfo[].IP' $qrlPeersFile)
  else
    echo -e "No Peers File Found...";
  fi
}

#Get CPU Info and check for AES
function GetCPU_Info(){
cpuInfo=`lscpu`
isAES=$(lscpu |grep aes)
if [ "$isAES" ];
then
  AESenabled=true
else
  AESenabled=false;
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

## To Do - assign variables here and later return the data formatted.
function check_host_info(){
 _HostName=$(hostname) ;
 _UserName=$(whoami) ;
 _UserID=$(id -u);
 _ServerTime=$(date) ;
 _UpTime=$(uptime -p) ;
 _UpSince=$(uptime -s) ;

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

################################
# QRL Functions                #
################################

#Check for go-lang qrl installation
function check_for_gqrl(){ 
  if [ -x "$(command -v gqrl)" ]; 
  then
    qrlBase="go";
    gqrlInstalled=true;
    qrlInstalled=true;
    #using pgrep to find the process id.
    if pgrep -x "gqrl" > /dev/null;
    then
      gqrlRuns=true;
      gqrlProcess=`pgrep -x gqrl`;
      gqrlVersion=`curl -s 127.0.0.1:19009/api/GetVersion |jq -r '.data.version'`
      qrlRuns=true;
    fi;
  else
    gqrlInstalled=false;
    gqrlRuns=false;
    qrlRuns=false;  
    qrlInstalled=false;
  fi;
}
# Check for python qrl installation
function check_for_pyqrl(){
  if [ -x "$(command -v qrl)" ]; 
    then
      qrlBase="python"; 
      py_qrlInstalled=true;
      qrlInstalled=true;
      py_qrlVersion=`qrl --version |sed -n 's/.*\([0-9]\.[0-9][0-9]*\).*/\1/p'`; 
      if pgrep -x start_qrl > /dev/null;
        then 
          py_qrlRuns=true;
          py_qrlProcess=`pgrep -x start_qrl`;
          qrlRuns=true;
        else
          py_qrlRuns=false;
        fi;
    else 
    py_qrlRuns=false;
    py_qrlInstalled=false;
    qrlInstalled=false;
    qrlRuns=false;
  fi;
}





#Fix this function to work
function check_qrl_testnet(){
    if [ -f "$qrlDir/genesis.yml" ]; 
  then
    #Genesis file exsists. Set to true and grab contents
    qrlGenesis=true;
    qrlGenesisFile=$(cat "$qrlDir/genesis.yml");
  else
    qrlGenesis=false;
  fi

  if [ "$qrlGenesis" = true ];
  then
    check_Testnet=$(qrl state |grep Testnet |sed 's/.*://' | sed 's|[\",]||g');
    check=$?;
    if [ "$check" = 0 ]; then
      qrlTestnet=true;
    else
      qrlTestnet=false;
    fi;
  else
    qrlTestnet=false;
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

# Check for qrl_walletd
function check_walletd(){
  if [ -x "$(command -v qrl_walletd)" ]; 
   then 
      qrl_walletdInstalled=true;
      #`go version |sed -n 's/.*\([0-9]\.[0-9][0-9]*\).*/\1/p'` 2> /dev/null;
      qrl_walletdPID=$(pgrep -x qrl_walletd);
    else  
       qrl_walletdInstalled=false;
  fi

  WalletRestProxyDir=/home/$user/go/src/github.com/theQRL/walletd-rest-proxy/
  if [ -d $WalletRestProxyDir ];
  then
    walletdrestproxyInstalled=true;
  fi
  #Check rest proxy
  if [ `lsof -Pi :5359 -sTCP:LISTEN -t` >/dev/null ] && [ `lsof -Pi :19010 -sTCP:LISTEN -t` >/dev/null ];
  then
    walletdrestproxyRunning=true;
  fi
  qrlWalletdCount=$(locate -c walletd.json)
  qrlWalletdLocation=$(locate  walletd.json)

}
