# Docker Harbor Deployment
## **`Harbor Version`**:`1.7.0`
## **`Docker`版本**:`18.09.6`         //配置好yum源，直接安装即可
## **`docker-compose`版本:** 1.18.0   //配置好yum源，直接安装即可
## **Harbor**版本地址：`https://github.com/goharbor/harbor/releases`
**获取地址** `https://storage.googleapis.com/harbor-releases/release-1.7.0/harbor-offline-installer-v1.7.0.tgz`
****
[root@harbor ~]# wget https://storage.googleapis.com/harbor-releases/release-1.7.0/harbor-offline-installer-v1.7.0.tgz
[root@harbor ~]# tar -zxf harbor-offline-installer-v1.7.0.tgz
[root@harbor ~]# cd harbor/
### 制作证书，可以参考   [证书制作](https://github.com/sunlge/kubernetes/blob/master/program/build%20certificate.md)
`[root@harbor harbor]# mkdir pki`
**制作一个私钥**
```
[root@harbor harbor]#cd pki
[root@harbor pki]# openssl genrsa -out harbor.key 2048
```
**根据私钥生成一个证书请求文件**
`[root@harbor pki]# openssl req -new -key harbor.key  -out harbor.csr -subj "/C=bj/ST=bj/L=bj/O=sunlge/OU=Personal/CN=harbor.sunlge.com" -key harbor.key  -out harbor.csr"`

**根据证书请求文件生成一个CA自签署证书即可**
`[root@harbor pki]# openssl x509 -req -days 365 -in harbor.csr  -signkey harbor.key -out harbor.crt`
`Docker`守护进程会将`.crt`文件解释为CA证书，将`.cert`文件解释为客户机证书，先将`.crt`文件转换一份`.cert`文件
**官方解释地址**`https://docs.docker.com/engine/security/certificates/`
```
[root@harbor pki]# openssl x509 -inform PEM -in harbor.crt -out harbor.cert
[root@harbor pki]# mkdir  -p /etc/docker/certs.d/harbor.sunlge.com
[root@harbor pki]# cp -pf harbor.cert harbor.crt harbor.key /etc/docker/certs.d/harbor.sunlge.com/
[root@harbor pki]# systemctl restart docker
```
### 或者直接将`.crt`证书文件直接写到`/etc/ssl/certs/ca-bundle.trust.crt`文件中
```
[root@harbor pki]# cat harbor.crt >> /etc/ssl/certs/ca-bundle.trust.crt
[root@harbor pki]# systemctl restart docker
```
```
[root@harbor harbor]#  cat -n harbor.cfg | sed -n '8p;12p;24p;25p;28p;69p'
     8  hostname = harbor.sunlge.com                      ##域名或者主机名
    12  ui_url_protocol = https                           ##http or https 协议
    24  ssl_cert = /root/harbor/pki/harbor.crt            ##证书目录，指定crt证书文件目录
    25  ssl_cert_key = /root/harbor/pki/harbor.key        ##证书目录，指定key证书获取密钥
    28  secretkey_path = /root/harbor/pki                 ##自动生成的一个secretkey文件
    69  harbor_admin_password = Harbor12345               ##Harbor仓库的默认密码
 ```
**直接执行harbor目录下install一键安装脚本即可**
`[root@harbor harbor]# ./install.sh`
