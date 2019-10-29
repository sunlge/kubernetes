# volumes的简单说明
Kubernets当中，“$”符号是变量引用

**kubernetes当中存储方式的类型**
---
```
简单来说有spec.volumes字段下有：

下面为常见类型，还有很多，可参考官网。
	emptyDir特性：
		会随机在node节点上创建挂载点，但是挂载目录会随着Pod的删除而删除。	
		
	emptyDir：{medium，sizaLimit}
		medium：存储介质，默认为普通存储，改为Memory则是用内存做存储方式。
		sizaLimit：做限制，如果启动Memory，一定要做一个限制/
	
	hostPath特性：
		在yaml文件中写的挂在点路径如果没有会自动创建，因为Pod资源默认是随机调度的，所以会随机在node节点上创建挂载点。
		Pod资源删除之后挂在目录并不会随着Pod的消失而消失。
	hostPath嵌套字段：
	   Path：就是挂载点了
	   type: <string>
	   	DirectoryOrCreate:指定路径不存在自动创建，权限为0755，属主属组kubelet
		Directory: 必须存在的目录路径
		FileOrCreate：直接的路径不存在时自动创建权限为0644的空文件，属主属组为kubelet
		File：必须存在的文件路径
		Socket：必须存在的Socket文件路径
		CharDevice：必须存在的字符设备文件路径
		BlockDevice：必须存在的块设置文件路径

还有就是网络存储类型了。不过需要依赖于PV，PVC。
```

**什么是pv，pvc?**  
---
pvc依赖于pv，pv依赖于存储方式。  
pv就相当于一个存储池，当创建pvc时，pvc需要存储空间，这个存储空间就是从pv中申请。所以想要创建一个pvc，必须要有满足条件的pv。  

**简单说一下存储供给的方式：**  
---
`静态供给`：它是由集群管理员手动创建一定数量的PV的资源供应方式。这些PV负责处理存储系统的细节，并将其抽象成易用的存储资源提供给用户，它不强依赖于存储类(StorageClass) 。  StorageClass资源需要自行创建。此处只简单介绍一下。

`动态存储` ：不存在某静态的PV匹配到用户的PVC申请时，kubernetes集群会尝试为PVC动态创建符合需求的PV，这就是`动态供给`。它依赖于存储类的辅助，pvc必须向一个事先存在的存储类发起动态分配的PV请求。
所以有一个pvc类型叫做动态pvc，当你想要创建一个pvc时，会动态自动创建一个pv来满足需要。

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
		

