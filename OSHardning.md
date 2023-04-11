      This update is did only for The First Time we launch the new instance otherwise we don't update 
First update the server 
cmd: yum update 


------------Set Hostname----------------
To check hostname
cmd==>
hostname

Setting Host name
cmd==>
hostname servername

Either create (if not present the file) or edit these file

cmd: vi /etc/hostname (For Ubuntu/Centos)

cmd: vi /etc/sysconfig/network  (for amazon linux only) HOSTNAME=Server-Name

cmd: vi /etc/hosts (For All Unix flavours)

#add these lines in "hosts" file 
      help- 10.20.20.61 ProjectName-Prod-server
      help- privateipaddress server-Name

vi /etc/hostname >> put your servername
hostname
Enter Hostname here and Save and Exit ESC:wq

hostname "servername"
	  
	 cmd => cd 
	 cmd => sudo su

-----------change hard limit and soft limit---------
Step1:
Either create (if not present the file) or edit these file

cmd:  

vi /etc/sysctl.conf

# Add below 
# Custom change for increasing max number of ulimit open files

fs.file-max = 1000000

Step2:

vi /etc/security/limits.conf  
# Add below
# Custom change to increase open files limit

*          soft     nproc          1000000
*          hard     nproc          1000000
*          soft     nofile         1000000
*          hard     nofile         1000000
root     soft     nproc          1000000
root     hard     nproc          1000000
root     soft     nofile         1000000
root     hard     nofile         1000000


cmd:  ulimit -n 1000000

to check ulimits (cmd: ulimit -Hn and cmd: ulimit -Sn)

TIPS- for ubuntu linux follow steps in below link
https://phpsolved.com/ubuntu-16-increase-maximum-file-open-limit-ulimit-n/

Step3:
sestatus
cmd: 
------------Disable selinux--------------
cmd: sestatus 
if it shows disabled then its fine

Centos7 Disable Selinux follow below link.
https://linuxize.com/post/how-to-disable-selinux-on-centos-7/


Creating User 
============================================================================================

sudo useradd -s /bin/bash -m -d /home/Rapyder-Admin Rapyder-Admin
sudo su Rapyder-Admin
cd
ll -a
mkdir .ssh
chmod 700 .ssh
cd .ssh
vi authorized_keys

#copy the public key(generate using puttygen) in authorized_keys and use putty peagent (add private key in it)

TIPS- tick "Allow agent forwarding" in putty's "ssh->auth".

cmd: chmod 600 authorized_keys
cmd: exit

Giving Sudo Access
==========================================================
cmd: visudo
# in visudo file add below line at the end of the file
Rapyder-Admin ALL=(ALL)   NOPASSWD: ALL
Rapyder-Admin 
Deleloper
Rapyder-Admin 

10.125.3.155

Rapyder-Admin

cmd: exit
cmd: sudo su
Rapyder-Admin    ALL=(ALL:ALL)  NOPASSWD: ALL
===========================================================================================
#!/bin/bash
sudo useradd -s /bin/bash -m -d /home/Rapyder-Admin Rapyder-Admin
mkdir -p /home/Rapyder-Admin/.ssh
touch /home/Rapyder-Admin/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAhIl6S3PyZO/k8LUzxyeQUFXwjIJ7Mo0tDOVAr6SWLqECbGUSwPcm2JXK1+u/PYGbLs1/0jzBrqn1gz/RJrhrcwBxqmkJeP2QLPWm4eZXvR5LrweZTMZ+KiRVN1h1qWpsWUjuwH2YAFePcUiButILkdlbxZgI9NVTVI/Tkaq60IPOeCwEdyYnLcoIEazCZR+wMGM/niEoO2YSo7F2FVo9rLr0PGm/s23yxbED0r9CQzvOSBnkTRLqVrjZFDmsyBwFGzcuJ6La/DbYqS5WvUTGCUhKWP9FQT08UiWeKkIdFi+2IFnI3Wz1HLT/ekUOiE+rbmT4PNJOqXCXI5VbU9z8xw== rsa-key-20181008" > /home/Rapyder-Admin/.ssh/authorized_keys
chmod 700 /home/Rapyder-Admin/.ssh
chmod 600 /home/Rapyder-Admin/.ssh/authorized_keys
chown -R Rapyder-Admin:Rapyder-Admin /home/Rapyder-Admin
echo "Rapyder-Admin ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "Rapyder-Admin user successfully created"
====================================================================================================

How to Enable the password based authentication in Linux server using userName & password!.
1.Login as Root
2.sudo passwd username
3.Update the PasswordAuthentication parameter in the /etc/ssh/sshd_config file:
PasswordAuthentication yes
4.sudo service ssh restart or sudo systemctl restart sshd.service
=========================================================================





















