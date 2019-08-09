## QRL Node Info Script

This script is used to get information form an Ubuntu Server running a QRL node. This will print out quite a bit if information on your OS, Server and various QRL related features.

### Example Output

```
-------------------------------------
  QRL_NODE_INFO
-------------------------------------

Gather information on the local system for diagnostics.
Join our Discord server for help and support
	___ https://discord.gg/MSzBSdr ___


#######__ Local System Info __#######

Your OS is:                         "Ubuntu 16.04.5 LTS"
DistributorID:                      "Ubuntu"
Codename:                           "xenial"
Release:                            "16.04"
Description:                        "Ubuntu 16.04.5 LTS"

#######__ Host Info __#######

UserName:                           "ubuntu"
User ID:                            "1000"
User is sudo:                       "true"
Script called as root:              "false"
Hostname:                           "faucet"
ServerTime:                         "Fri Aug  9 11:56:03 UTC 2019"
Uptime:                             "up 43 weeks, 22 hours, 5 minutes"
Up Since:                           "2018-10-11 13:50:27"

#######__ Server Memory __#######

              total        used        free      shared  buff/cache   available
Mem:           990M        808M         77M        672K        105M         37M
Swap:          1.0G        607M        416M
Total:         2.0G        1.4G        493M

#######__ Network Test __#######

Can We Reach https://theQRL.org?    "true"
Peer IP found:                      "true"
Peer's IP:                          ""
PeerIP is reachable                 "false"

#######__ QRL Info __#######

QRL Is Installed:                   "true"
QRL Base installed:                 "python"
QRL Runs:                           "true"
Python QRL Version:                 "1.10"
Python QRL PID:                     "4645"
blockheight:                        " 592839"

#######__ QRL Wallet __#######

QRL Wallet Found:                   "true"
QRL Wallet Count:                   "1"

Wallet Location:

/home/ubuntu/wallet.json

#######__ wallet_api __#######

qrl_walletd Installed:              "true"
qrl_walletd PID:                    "4661"
walletd-rest-proxy Installed        "true"
walletd-rest-proxy Running          "true"
PORT 5359 is                        "OPEN"
PORT 19010 is                       "OPEN"
wallet-api Wallet Found             "3"

wallet-api Wallet Location:

/home/ubuntu/walletd.json2
/home/ubuntu/walletd.json1
/home/ubuntu/.qrl/walletd.json

#######__ QRL Config File __#######

QRL Config Found:                   "true"

 mining_enabled: False
 public_api_enabled: True
 public_api_host: "127.0.0.1"
 public_api_port: 19009
# public_api_threads: 1
# public_api_max_concurrent_rpc: 100
 public_api_server: "127.0.0.1:19009"
 wallet_daemon_host: "127.0.0.1"
 wallet_daemon_port: 18091
 wallet_api_host: "127.0.0.1"
 wallet_api_port: 19010
# wallet_api_threads: 1
# wallet_api_max_concurrent_rpc: 100


```

## Usage Instructions

Clone the repo.

```bash
git clone https://github.com/fr1t2/QRL_Node_Info.git
```

Change into the directory you just cloned and run the script.

```bash
cd QRL_Node_Info && ./QRLinfo_0.0.2.sh
```

This will print out information for your installation status and the QRL install.


### Print to File

Using the example above, you can pipe the output to a file, while printing to stdout.


```bash
./QRLinfo_0.0.2.sh -v |tee YOURFILENAME
```

