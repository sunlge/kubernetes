# Ingress Nginx Controller控制器的TLS的secret资源示例
### Secret资源的三种类型：
```
docker-registry  
generic          
tls
##
  其中tls资源最主要就是做证书使用的
```
### 生成证书
      openssl genrsa -out tls.key 2048
      openssl req -new -x509 -key tls.key -out tls.crt -subj /C=CN/ST=Beijing/L=Beijing/O=DevOps/CN=master.sunlge.com -days 3605

### 创建一个Secrets资源
      kubectl create secret tls tomcat-ingress-secret --cert=tls.crt --key=tls.key

### 创建一个TLS类型的Ingress资源配置清单
```
[root@master tls]# cat tomcat-ingress-tls.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-tomcat
  namespace: test-ingress
spec:
##注意tls字段以及子字段，是创建secret资源的重点
  tls:
  - hosts:
    - master.sunlge.com
    secretName: tomcat-ingress-secret
  rules:
  - host: master.sunlge.com
    http:
      paths:
      - path: /
        backend:
         serviceName: tomcat-svc
         servicePort: 8080
```
