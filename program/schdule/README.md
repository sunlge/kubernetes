# Pod资源调度


### 调度器策略：
	预选策略:
		ChekNodeCondition:检查节点是否正常
		PodToleratesNodeTaints：检查Pod上的spec.tolerations可容忍的污点是否完全包含节点上的污点
		PodToleratesNodeNoExecuteTaints：检查NoExecute属性
		CheckNodeLabelPresence：检查标签存在性
		CheckServiceAffinity：
		参考：
			https://github.com/kubernetes/kubernetes/blob/master/pkg/scheduler/algorithm/predicates/predicates.go
		
	优选策略：
		参考：
			https://github.com/kubernetes/kubernetes/tree/master/pkg/scheduler/algorithm/priorities


#### CPU单位:
1颗逻辑CPU
	1=1000,millicores
	500m=0.5CPU
#### 内存单位：
	E、P、T、G、M、K
	Ei、Pi


### QoS状态：
	Guranteed：
		每个容器同时设置CPU和内存的requests和limits.
		cpu.limits=cpu.requests
		memory.limits=memory.request
	Burstable:
		至少有一个容器设置CPU或内存资源的requests属性
	BestEffort：
		没有任何一个容器设置了requests或limits属性；最低优先级别；

节点选择器：nodeSelector， nodeName
节点亲和调度：nodeAffinity

### 节点污点的三种终态，taint的effect定义对Pod排斥效果：
      NoSchedule: 一定不能被调度
      PreferNoSchedule: 尽量不要调度
      NoExecute: 不仅不会调度, 还会将Node上已有的Pod立即驱除
	
### 管理节点污点：
	kubectl taint node node01.sunlge.com node-type=production:NoSchedule
	kubectl taint node node1 key1:NoSchedule-  # 这里的key可以不用指定value
	kubectl taint node node1 key1:NoExecute-
	kubectl taint node node1 key1-  删除指定key所有的effect
	kubectl taint node node1 key2:NoSchedule-
