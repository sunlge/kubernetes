### 配置容器化应用的方式：
	1.自定义命令行参数；
		args: []
	2.把配置文件直接焙进镜像；
	3.环境变量注入时，只在系统启动时有效
		(1)Cloud Native的应用程序一般可直接通过环境变量加载配置；
		(2)通过Entrypoint脚本来预处理变量为配置文件中的配置信息；
	4.存储卷可以实施更新
				
		
		
### 创建confgimap
	kubectl create cm nginx-config --from-literal=nginx_port=8080 --from-literal=service_name=myapp.sunlge.com		
	kubectl create cm nginx-www --from-file=./www.conf 
	[root@master secret]# cat www.conf 
	server {
		server_name myapp.sunlge.com;
		listen 80;
		root /data/web/html/;
	}

	kubectl explain pod.spec.containers.env.valueFrom.configMapKeyRef.optional	##key必须从configMap中获取，不然报错
	kubectl explain pods.spec.volumes.configMap.items				##去除不想指定的参数。		
		
### 创建secret的generic
```
kubectl create secret generic mysecret1 --from-literal=user=tom --from-literal=password1=redhat --from-literal=password2=redhat	 #创建时直接在命令中将value当参数


# 下面的方法是使用一个文件对应一个变量的方式，两种方法创建的secret资源查看yaml文件时所有的value都会加密。
echo -n tom > user
echo -n redhat > password1
echo -n redhat > password2
kubectl create secret generic mysecret2 --from-file=./user --fromfile=./password1 --from-file=./password2     # 注意：此文件名就是变量名

# 下面是使用一个文件对应多个变量的方式
cat > ./env.md <<EOF
user=tom
password1=redhat
password2=redhat
EOF
kubectl create secret generic mysecret3 --from-env-file=env.md

```
### yaml的配置文件里定义环境变量
	spec
	...
	    env:
	    - name: MYSQL_ROOT_PASSWORD
	      valueFrom: 
		secretKeyRef:  ##如果是cm换成configMapKeyRef即可
		  name: mysql-root-pass
		  key: password

### 配置文件使用存储卷定义
```
##base64如何解码
echo TXlwYXNzMTIz |base64 -d
```
### 使用指定的key创建名为tls-secret的TLS secret
	kubectl create secret tls tls-secret --cert=./tls.crt --key=./tls.key --dry-run -oyaml

### 查看帮助
	kubectl create secret --help
	  docker-registry 创建一个给 Docker registry 使用的 secret
	  generic         从本地 file, directory 或者 literal value 创建一个 secret
	  tls             创建一个 TLS secret
