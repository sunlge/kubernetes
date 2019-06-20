# k8s的StatefulSet有状态类型控制器		  

${prod.TBASE.DEPLOY_INSTANCE_NUM_PER_IP}

### StatefulSet：
	cattle(个体)，pet(群体)	
	1.3 PetSet -> StatefulSet
	
### StatefulSet的应用场景:
	1.稳定且唯一的网络标识符；
	2.稳定且持久的存储；
	3.有序，平滑的部署和扩展；
	4.有序，平滑的终止和删除；
	5.有序的滚动更新；
	
### 创建StatefulSet需要的三个组件：
	headless service(无头服务)
	StatefulSet
	volumeClaimTemplate(存储卷申请模板) 
```		
kubectl explain sts.spec		##查看sts的资源字段
kubectl explain sts.spec.updateStrategy.rollingUpdate.partition		##分区更新，partition定义为5，那么只更新大于等于5的pod
#可以 patch打补丁来更新，回滚，升级。
```
