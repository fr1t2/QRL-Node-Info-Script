#!/bin/bash

## QRL Node Information Script

source src/_functions.sh


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
# This will need to change once we add multiple OS's here...
AcceptedOS="Ubuntu"
header QRL_NODE_INFO
echo -e "Gather information on the local system for diagnostics."
echo -e "Join our Discord server for help and support\n\t___ https://discord.gg/MSzBSdr ___\n\n"
# Check for a valid OS for this script to run on.

subHeader Local System Info
check_os_info;
_Check=$(echo "$DistributorID" |grep "$AcceptedOS")
check=$?;
if [[ "$check" = 1 ]];
then
  errHeader Not Running Ubuntu 
  echo -e "This script has been configured to work with Ubuntu.";
  printf "%-35s %s\n" "Your OS is:"  "\"$Description\"";
  echo -e "\nIf you would care to contribute this code is opensource, contributions are welcom!\n";
  echo -e "https://github.com/fr1t2/QRL_Node_Info"
  #exit; # Uncomment to exit the script here!
else
# Print data to terminal
  #subHeader " System information "
  printf "%-35s %s\n" "Your OS is:"  "\"$Description\"";
  printf "%-35s %s\n" "DistributorID:"  "\"$DistributorID\"";  
  printf "%-35s %s\n" "Codename:"  "\"$Codename\"";  
  printf "%-35s %s\n" "Release:"  "\"$Release\""  
  printf "%-35s %s\n" "Description:"  "\"$Description\""  
fi

subHeader Host Info
  check_host_info;
  printf "%-35s %s\n" "UserName:"  "\"$_UserName\""  
  printf "%-35s %s\n" "User ID:"  "\"$_UserID\""  
  IsSudo;
  # SUDO
  if [ "$SUDO" = true ];
  then
    printf "%-35s %s\n" "User is sudo:"  "\"$SUDO\"";
  else
    printf "%-35s %s\n" "User is sudo:"  "\"$SUDO\"";
  fi  
    #ROOT 
    if [ "$ROOT" = true ];
    then
      printf "%-35s %s\n" "Script called as root:"  "\"$ROOT\""
    else
      printf "%-35s %s\n" "Script called as root:"  "\"$ROOT\""
    fi    
  printf "%-35s %s\n" "Hostname:"  "\"$_HostName\"";
  printf "%-35s %s\n" "ServerTime:"  "\"$_ServerTime\"";
  printf "%-35s %s\n" "Uptime:"  "\"$_UpTime\"";  
  printf "%-35s %s\n" "Up Since:"  "\"$_UpSince\"";  


# Memory check
subHeader Server Memory;
free -th


subHeader Network Test;
# Check network
if ping -c 1 theqrl.org &> /dev/null;
  then
    connection=true;
    printf "%-35s %s\n" "Can We Reach https://theQRL.org?"  "\"$connection\""  ;
    # Get known peer and ping
    if [ -d "$qrlDir" ];
    then
      check_qrl_knownpeers; # this sets the variable $qrlPeers to the contents of the peer file.
      qrlPeersCount=$(echo "$qrlPeers" |wc -l);
      qrlPeersMath=$(( qrlPeersCount / 2));
      peerIP=$(echo "$qrlPeers" |sed -n $qrlPeersMath\p |sed 's|[",]||g' | sed 's/:.*//')
      printf "%-35s %s\n" "Peer IP found:"  "\"true\""  ;
      printf "%-35s %s\n" "Peer's IP:"  "\"$peerIP\""  ;
      if ping -c 1 $peerIP &> /dev/null;
      then
        printf "%-35s %s\n" "PeerIP is reachable"  "\"true\""  ;
      else
        printf "%-35s %s\n" "PeerIP is reachable"  "\"false\""  ;
      fi

    else
      echo -e "No Peers File Found...";
    fi
  else
    connection=false
    errHeader Not Connected
    printf "%-35s %s\n" "Can We Reach https://theQRL.org?"  "\"$connection\"";
    echo -e "No Connection! Check stuff and come back";
    exit;
  fi


subHeader QRL Info

## QRL Tests and checks

check_for_pyqrl;

if [ "$py_qrlInstalled" = false ];
then
check_for_gqrl;
fi

if [ "$qrlInstalled" = true ];
then
  printf "%-35s %s\n" "QRL Is Installed:"  "\"$qrlInstalled\"" 
  printf "%-35s %s\n" "QRL Base installed:"  "\"$qrlBase\""        

  if [ "$qrlRuns" = true ];
  then
    printf "%-35s %s\n" "QRL Runs:"  "\"$qrlRuns\"";
    if [ "$qrlBase" = "python" ]
    then
      printf "%-35s %s\n" "Python QRL Version:"  "\"$py_qrlVersion\"";
      printf "%-35s %s\n" "Python QRL PID:"  "\"$py_qrlProcess\"";
      blockheight=$(qrl state |grep block_height |sed 's/.*://');
      printf "%-35s %s\n" "blockheight:"  "\"$blockheight\"";

    elif [ "$qrlBase" = go ]; then
      #printf "%-35s %s\n" "Go QRL Version:"  "\"$go_qrlVersion\"";
      printf "%-35s %s\n" "Go QRL PID:"  "\"$gqrlProcess\"";
      blockheight=`curl -s 127.0.0.1:19009/api/GetHeight |jq '.height'`;
      printf "%-35s %s\n" "blockheight:"  "\"$blockheight\"";
    fi
        #statements
  else
    printf "%-35s %s\n" "QRL Runs:"  "\"$qrlRuns\"";
  fi

else
      printf "%-35s %s\n" "QRL Is Installed:"  "\"$qrlInstalled\""        
fi


# Check for testnet
if [ -f "$qrlDir/genesis.yml" ]; 
  then
    #Genesis file exsists. Set to true and grab contents
    qrlGenesis=true;
    qrlGenesisFile=$(cat "$qrlDir/genesis.yml");
    printf "%-35s %s\n" "Genesis File Found:"  "\"$qrlGenesis\""        
    
    if [ "$qrlBase" = "python" ];
    then
      check_Testnet=$(qrl state |grep Testnet |sed 's/.*://' | sed 's|[\",]||g');
      check=$?;
      if [ "$check" = 0 ]; then
        qrlTestnet=true;
        printf "%-35s %s\n" "QRL Testnet:"  "\"$qrlTestnet\""        
      else
        qrlTestnet=false;
        printf "%-35s %s\n" "QRL Testnet:"  "\"$qrlTestnet\""              
      fi;
    else
      echo -e "QRL BASE is not Python, you may be running testnet\nI need to develop this script more..."
    fi
  #else
#    qrlGenesis=false;
#    qrlTestnet=false;
#    printf "%-35s %s\n" "QRL Testnet:"  "\"$qrlTestnet\""        
  fi



check_qrl_bannedpeers;

if [ "$qrlBannedPeersFound" = true ];
then
  printf "%-35s %s\n" "Banned Peers Found:"  "\"$qrlBannedPeersFound\""
  echo "$qrlBannedPeers"
#else
#  printf "%-35s %s\n" "Banned Peers Found:"  "\"$qrlBannedPeersFound\""
fi


check_qrl_wallet;

if [ "$qrlWallet" = true ];
then
 subHeader QRL Wallet;
 printf "%-35s %s\n" "QRL Wallet Found:"  "\"$qrlWallet\""
 printf "%-35s %s\n" "QRL Wallet Count:"  "\"$qrlWalletCount\""
 echo -e "\nWallet Location:\n"
  echo "$qrlWalletLocation"
#else
#   printf "%-35s %s\n" "QRL Wallet Found:"  "\"$qrlWallet\""
fi

# Check for wallet REST proxy
#walletd-rest-proxy
check_walletd;

if [ "$qrl_walletdInstalled" = true ];
then
  subHeader wallet_api
  printf "%-35s %s\n" "qrl_walletd Installed:"  "\"$qrl_walletdInstalled\""
  printf "%-35s %s\n" "qrl_walletd PID:"  "\"$qrl_walletdPID\""
fi
if [ "$walletdrestproxyInstalled" = true ]
then
  printf "%-35s %s\n" "walletd-rest-proxy Installed"  "\"$walletdrestproxyInstalled\""  
  if [ "$walletdrestproxyRunning" = true ];
  then
    printf "%-35s %s\n" "walletd-rest-proxy Running"  "\"$walletdrestproxyRunning\""  
    printf "%-35s %s\n" "PORT 5359 is"  "\"OPEN\""  
    printf "%-35s %s\n" "PORT 19010 is"  "\"OPEN\""  
    printf "%-35s %s\n" "wallet-api Wallet Found"  "\"$qrlWalletdCount\""  
    echo -e "\nwallet-api Wallet Location:\n"
    echo "$qrlWalletdLocation"

  else
    printf "%-35s %s\n" "walletd-rest-proxy Running"  "\"$wwalletdrestproxyRunning\""  
  fi
fi

check_qrl_config;

if [ "$qrlConfigSet" = true ];
then
  subHeader QRL Config File  
  printf "%-35s %s\n" "QRL Config Found:"  "\"$qrlConfigSet\""
  echo -e ""
  echo -e "$qrlConfig"
#else
#    printf "%-35s %s\n" "QRL Config Found:"  "\"$qrlConfigSet\""
fi


