# Secret和Congimap应用场景
应用场景：镜像往往是一个应用的基础，还有很多需要自定义的参数或配置，例如资源的消耗、日志的位置级别等等，这些配置可能会有很多，因此不能放入镜像中，Kubernetes中提供了Configmap来实现向容器中提供配置文件或环境变量来实现不同配置，从而实现了镜像配置与镜像本身解耦，使容器应用做到不依赖于环境配置。

## 配置容器化应用的方式：
	1.自定义命令行参数；
		args: []
	2.把配置文件直接焙进镜像；
	3.环境变量注入时，只在系统启动时有效
		(1)Cloud Native的应用程序一般可直接通过环境变量加载配置；
		(2)通过Entrypoint脚本来预处理变量为配置文件中的配置信息；
	4.存储卷可以实施更新
**什么是ConfigMap:**  
---
利用ConfigMap可以解耦部署与配置的关系，对于同一个应用部署文件，可以利用valueFrom字段引用一个在测试环境和生产环境都有的ConfigMap（当然配置内容不相同，只是名字相同），就可以降低环境管理和部署的复杂度。
```
ConfigMap有三种用法：
	生成为容器内的环境变量
	设置容器启动命令的参数
	挂载为容器内部的文件或目录
	
ConfigMap的缺点:
	ConfigMap必须在Pod之前创建
	ConfigMap属于某个NameSpace，只有处于相同NameSpace的Pod才可以应用它
	ConfigMap中的配额管理还未实现
	如果是volume的形式挂载到容器内部，只能挂载到某个目录下，该目录下原有的文件会被覆盖掉
	静态Pod不能用ConfigMap
```
		
		
### confgimap创建方法
```
kubectl create configmap <map-name> --from-literal=<parameter-name>=<parameter-value>
kubectl create configmap <map-name> --from-literal=<parameter1>=<parameter1-value> --from-literal=<parameter2>=<parameter2-value> --from-literal=<parameter3>=<parameter3-value>
kubectl create configmap <map-name> --from-file=<file-path>
kubectl apply -f <configmap-file.yaml>
## 还可以从一个文件夹创建configmap
kubectl create configmap <map-name> --from-file=/path/to/dir
```
### 创建 yaml声明式的confgimap
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

### 配置文件使用存储卷定义时需要进行的编码、解码方式
```
##base64如何解码
echo TXlwYXNzMTIz |base64 -d
```
**什么是Secret：**  
---
Secret与ConfigMap类似，但是用来存储敏感信息。在Master节点上，secret以非加密的形式存储（意味着我们要对master严加管理）。从Kubernetes1.7之后，etcd以加密的形式保存secret。secret的大小被限制为1MB。当Secret挂载到Pod上时，是以tmpfs的形式挂载，即这些内容都是保存在节点的内存中，而不是写入磁盘，通过这种方式来确保信息的安全性。

### 使用指定的key创建名为tls-secret的TLS secret
	kubectl create secret tls tls-secret --cert=./tls.crt --key=./tls.key --dry-run -oyaml

### 查看帮助
	kubectl create secret --help
	  docker-registry 创建一个给 Docker registry 使用的 secret
	  generic         从本地 file, directory 或者 literal value 创建一个 secret
	  tls             创建一个 TLS secret
## 参考资料
[腾讯云社区](https://cloud.tencent.com/developer/article/1368094)
