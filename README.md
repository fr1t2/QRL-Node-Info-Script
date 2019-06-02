## QRL Node Info Script

This script is meant to be ran on the node to print useful information to the command line.

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
