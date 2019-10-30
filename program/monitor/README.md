# k8s_监控-top

## 监控资源：
```
	heapster依赖于influxDB
	可以使用grafana来展示
```

**metrics server是什么:**
---
	metrics Server是集群级别的资源利用率数据的聚合器( aggregator )  
	相当于一个简化版的Heapster.  
	它通过kubernetes聚合器注册到主 API Server上，然后基于kubelet的Summary API收集每个节点上的指标数据.并将它们存储于内存中然后以指标API格式提供.  	

**部署好metrics server 之后就可以直接通过API来获取相关的资源指标，如下:**
---
```
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/pods" | jq .
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/node" | jq .
```
	
## HPA：

```
想要做HPA必须与资源限制一起，否则做了也没用
request and limits
做了资源限制，查看HPA资源时，字段TARGETS有一个Unknown，解决这个需要修改/etc/kubernetes/manifests/kube-controller-manager.yaml
在 spec.containers.command添加：
spec:
  containers:
  - command:
    - --horizontal-pod-autoscaler-use-rest-clients=false
    - --horizontal-pod-autoscaler-sync-period=10s

	
kubectl run myapp --image=ikubernetes/myapp:v1 --replicas=1 --requests='cpu=50m,memory=128Mi' --limits='cpu=50m,memory=128Mi' --labels='app=myapp' --expose --port=80
# HPA创建用命令即可，以下为基本示例
   kubectl autoscale deployment myapp --min=1 --max=8 --cpu-percent=60
   kubectl autoscale deployment myapp --min=2 --max=10
	如果把副本数设置为大于10个运行个数也是10个

kubectl get hpa
kubectl delete hpa nginx

```
## k8s之上promtheus的项目: [promtheus](https://github.com/DirectXMan12)
