### 制作证书
```
  openssl genrsa -out "/etc/gitlab/ssl/gitlab.exampre.com.key 2048
  openssl req -new -key /etc/gitlab/ssl/gitlab.exampre.com.key  -out "/etc/gitlab/ssl/gitlab.exampre.com.csr"
```
### 签署证书
```
  openssl x509 -req -days 365 -in "/etc/gitlab/ssl/gitlab.exampre.com.csr" -signkey "/etc/gitlab/ssl/gitlab.exampre.com.key" -out "/etc/gitlab/ssl/gitlab.exampre.com.crt"
```
### 申请证书
```
[root@master pki]# (umask 077; openssl genrsa -out dashbord.key 2048)
[root@master pki]# openssl req -new -key dashbord.key -out dashbord.csr -subj "/O=sunlge/CN=master.sunlge.com"
```
### 签署颁发证书
```
[root@master pki]# openssl x509 -req -in dashbord.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out dashbord.crt -days 999
