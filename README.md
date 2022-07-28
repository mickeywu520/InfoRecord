# Information record
## Gen your own ssh key
### ssh-keygen -t rsa -b 4096 -C your@email.com  
    Ex: ssh-keygen -t rsa -b 4096 -C mickey.wu@qbictechnology.com

## .ssh path for linux  
    move your ssh key to /home/yourDir/.ssh/id_rsa.pub

## .ssh path for windows  
    move your ssh key to C:\Users\[your user name]\.ssh

## Error
### 1.  Permission denied (publickey).
#### → try to change id_dsa id_dsa.pub .ssh to permission 700  
    Ex: chmod 700 ../.ssh id_dsa id_dsa.pub  

### 2. Still Permission denied (publickey).
#### → try to add your ssh key to ssh agent 
    Ex: ssh-add id_dsa
    
### 3. Could not open a connection to your authentication agent.
#### → "ssh-agent bash" then "ssh-add id_dsa" again  
    Ex: ssh-agent bash 
    Ex: ssh-add id_dsa

### 4. Check ssh key with gerrit server.
#### → ssh -p 29418 www.gerrit.qbictechnology.com
    if success, it would show below Info.
    ****    Welcome to Gerrit Code Review    ****
