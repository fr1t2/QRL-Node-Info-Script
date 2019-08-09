## QRL Node Info Script

This script is used to get information form an Ubuntu Server running a QRL node. This will print out quite a bit if information on you rOS, Server and various QRL related features.



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

This should help with sharing the information.
