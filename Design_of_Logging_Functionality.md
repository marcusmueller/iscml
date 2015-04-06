## Requirements ##

> - Centralize functionality which writes messages to log files


> - Archiving policy for log files


> - Establish consistent format for logging messages

> ` <username> <date> <time> message `





## File Layout ##

The logging function filename is

`   PrintOut.m `

The file is contained in

`  pcs/tc/util/log/ `


The archive class filename is




## Module Logging Process ##

```
Modules implementing logging add pcs/tc/util/log to path and
call the function PrintOut() as


 PrintOut(msg, vq, filename, at)

where
msg - cell array of strings containing log messages

vq - integer selecting message in msg array

filename 
    name of log file to write
    1 - print to standard out

append_time - append time to log message
  0 - no
  1 - yes  


The only required argument is "msg".

Defaults
vq - 0
filename - 1
append_time - 0

```


## Archiving ##
```
A single object is responsible for managing log archiving.

The object is instantiated in its own instance of MATLAB, analagous to the
task controllers, workers controllers, and job managers.

The object is initialized by either:
   reading a configuration file specifying all of the directories to monitor
   
   scanning the hierarchy for directories named 'log'


The archiving object rotates the log files by periodically writing the active
log file to a subdirectory called 'archive', using the following naming convention

<name>.log.0
<name>.log.1
...
<name>.log.6
```




## Modules Utilizing the Logging Class ##
```
task controller
worker controller
generic workers
job manager
user code called by workers   
```




## Notes ##

We could consolidate the logging mechanisms to a single type by implementing
all of the controller and manager classes similarly to the generic worker.

All of the services could be consolidated by implementing a top level controller
MATLAB class.