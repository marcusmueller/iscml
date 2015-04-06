## Introduction ##

[ownCloud](http://owncloud.org) is a service deployed on the WCRL cluster enabling _automatic synchronization_ of files between _cluster home directories_ and _personal devices_.

This functionality can be convenient when using WebCML on the cluster.

ownCloud usage requires a cluster account.  Contact the system administrator to obtain one if necessary.


## Procedure for Enabling Cluster ownCloud Access ##

**1. Access Request**
> Contact the system administrator and request access to ownCloud.
> Once a reply has been received, proceed to the next step.


**2. Configuration on Cluster**

> In this step we create a directory on the cluster under your home directory to synchronize with the WCRL ownCloud server.

> Log in via SSH and execute

```
       > sudo wcrl-owncloud-setup
```

> Enter your WCRL cluster password when prompted.

> Your cluster home directory will contain a new directory
```
       ~/oc
```
> > which contains all files synchronized to your ownCloud account.


**3. Client installation**


> On the machine to be synchronized with your cluster ownCloud directory, download and install the _ownCloud Desktop client_ for your platform located at

https://owncloud.org/install/


**4. Client configuration**

Launch the desktop client.  When prompted for a server address, enter
```
https://wcrl.csee.wvu.edu/owncloud 
```
as

![http://wcrl.csee.wvu.edu/owncloud_client_1.png](http://wcrl.csee.wvu.edu/owncloud_client_1.png)


When prompted for a username and password, enter your WCRL cluster credentials.

Specify the local folder which you would like to synchronize with ownCloud.


**Installation of ownCloud is complete.**

**All files placed in your local ownCloud directory will automatically synchronize with your cluster directory**
```
~/oc
```