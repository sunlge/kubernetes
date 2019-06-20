# volumes的简单说明
Kubernets当中，“$”符号是变量引用

### 什么是pv，pvc?
	pvc依赖于pv，pv依赖于存储方式。
	想要创建一个pvc，必须要有满足条件的pv。
	所以有一个pvc类型叫做动态pvc，当你想要创建一个pvc时，会动态自动创建一个pv来满足需要。
### pvc 与 pv之间的关系
    pvc和pv是绑定关系，多个Pod可用同一个pvc，但是同一个pvc只能绑定同一个pv。 
    动态pv，根据storageClassName(存储类)，pvc去根据这个存储类去动态创建pv。
    创建动态PV需要先定义一个storageClass，然后在创建一个PersistentVolumeClain即可。它会根据存储类动态创建pv

## volumes参数介绍
```
kubectl explain pod.spec.volumes				##pod中定义存储卷的方式
kubectl explain pod.spec.containers.volumeMounts		##容器中定义挂载卷方式，只能挂载当前Pod资源中定义的具体存储卷	
kubectl explain pod.spec.volumes.emptyDir			##定义emtpyDir，可以为空{}
kubectl explain pod.spec.volumes.emptyDir.medium		##定义此目录的存储介质类型，为default和Memory，Memory表示使用RAM内存
kubectl explain pod.spec.volumes.emptyDir.sizeLimi		##空间限制，默认为nil，开启medium的RAM时，一定要做此限制
kubectl explain pod.spec.volumes.gitRepo.repository		##Git仓库的URL  	#1.12版本之后已经被废弃

kubectl explain pod.spec.volumes.hostPath.type.DirectoryOrCreate	##指定的路径不存在时自动创建权限是0755的空目录，为kubelet。
kubectl explain pod.spec.volumes.hostPath.type.Directory		##必须存在的目录路径
kubectl explain pod.spec.volumes.hostPath.type.FileOrCreate		##指定路径不存在创建权限是0644的空文件，主为kubelet。
kubectl explain pod.spec.volumes.hostPath.type.File			##必须存在的文件路径
https://kubernetes.io/docs/concepts/storage/volumes#hostpath		##更多参数可以查看此文档

kubectl explain pod.spec.volumes.nfs.server		##NFS服务器的IP地址或主机名
kubectl explain pod.spec.volumes.nfs.readOnly		##NFS服务器导出(共享)的文件系统路径，必选字段
kubectl explain pod.spec.volumes.nfs.path		##是否以只读方式挂载，默认为false。

kubectl explain PersistentVolume.spec.capacity		##当前PV容量，目前，Capacity仅支持空间设定。

kubectl explain PersistentVolume.spec.accessModes.ReadWriteMany		##可以被多个节点同时都写挂载，简写为RWX
kubectl explain PersistentVolume.spec.accessModes.ReadOnlyMany		##可以被多个节点同时只读挂载，简写为ROX
kubectl explain PersistentVolume.spec.accessModes.ReadWriteOnce		##仅可被单个节点读写挂载，简写为RWO。

kubectl explain PersistentVolume.spec.storageClassName			##当前PV所属的StorageClass的名称，默认为空。
kubectl explain PersistentVolume.spec.mountOptions			##挂载选项组成的列表，如ro，soft和hard等
kubectl explain PersistentVolume.spec.volumeMode			##卷模型，指定此卷可被用作文件系统还是裸格式的块设备

kubectl explain pod.spec.volumes.persistentVolumeClaim			##Pod挂载pvc，注意，containers中同样要挂载volumeMounts。
kubectl explain pod.spec.volumes.downwardAPI				##详细查阅官网


kubectl explain PersistentVolume.spec.persistentVolumeReclaimPolicy	##pv空间释放策略
	Retain：保持不当，由管理员回收(默认)
	Recycle：空间回收，删除存储卷目录下的所有文件，仅支持NFS和hostPath。
	Delete：删除存储卷，仅支持部分云端存储系统。
```	
	
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

### 创建secret
	kubectl create secret generic mysql-root-password --from-literal=password=Mypass123
### 配置文件环境变量定义
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
