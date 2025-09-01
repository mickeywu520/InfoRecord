# How to install postgresql on Nvidia Jetson devices, Ex: Jetson orin NX 16g with Ubuntu 22.04
```
sudo apt install postgresql
sudo apt install postgresql-server-dev-14
```
# Check postgres version
```
/usr/lib/postgresql/14/bin/postgres --version
```
# How to connect postgresql via network, due to pgAdmin is not support on ARM64 / aarch64 now.
```
sudo gedit /etc/postgresql/14/main/postgresql.conf
```
# Modify the flag value of listen_addresses
## listen_addresses = 'localhost' to listen_addresses = '*'
# Restart the service after modify the flag of listen_addresses
```
sudo systemctl restart postgresql
```
# Check the listening address has been changed to 0.0.0.0:5432
```
netstat -ntlp | grep LISTEN
```
# Modify the flag value of
```
sudo gedit /etc/postgresql/8.4/main/pg_hba.conf
```
# add below value in pg_hba.conf file
```
host all all 0.0.0.0/0 md5
```
# switch to user postgres as super user permission
````
sudo -i -u postgres
````
# Into psql shell to set user & password for postgresql
````
postgres=# ALTER USER postgres WITH PASSWORD 'postgres';
ALTER ROLE
````
# Exit the psql shell & user of postgres
```
postgres=# \q
postgres@nvidia-desktop:~$ exit
```
# Restart & check status of postgresql service
```
sudo systemctl restart postgresql
sudo systemctl postgresql status
```
# Connect to server
1. Open your pgAdmin application & add hit the "Add new server"
2. Fill full the Name area, you can set any string that you want
3. switch to connection sheet & fill full "Host name/Address" and "username" & "password"
4. Hit save button, it will auto connect to remote server.
# Refer
- https://blog.csdn.net/2301_79325768/article/details/147894245
---
# Install the pgVector
```
cd /tmp
git clone --branch v0.8.0 https://github.com/pgvector/pgvector.git
cd pgvector
make
sudo make install
```
# Enable the extension(do this once in each database where you want to use it)
```
sudo -u postgres psql
postgres=# CREATE EXTENSION vector;
CREATE EXTENSION
postgres=# \q
```
# Refer
```
https://github.com/pgvector/pgvector
```









