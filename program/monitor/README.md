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
	
**HPA介绍**
---
```
K8S集群可以通过Replication Controller的scale机制完成服务的扩容或缩容，实现具有伸缩性的服务。  
K8S自动伸缩分为：
	sacle手动伸缩
	autoscale自动伸缩

自动扩展主要分为两种：
	水平扩展(scale out)，针对于实例数目的增减。
	垂直扩展(scale up)， 即单个实例可以使用的资源的增减, 比如增加cpu和增大内存。

HPA属于前者。它可以根据CPU使用率或应用自定义metrics自动扩展Pod数量(支持 replication controller、deployment 和 replica set)。

```
**HPA使用方法**
---
```
1.开启metrics server

2.想要做HPA必须与资源限制(request,limits字段)一起，否则做了也没用
   request and limits

3.做了资源限制，查看HPA资源时，字段TARGETS有一个Unknown，解决这个需要修改/etc/kubernetes/manifests/kube-controller-manager.yaml
在 spec.containers.command添加：
spec:
  containers:
  - command:
    - --horizontal-pod-autoscaler-use-rest-clients=false
    - --horizontal-pod-autoscaler-sync-period=10s

# 更多参数介绍
horizontal-pod-autoscaler-use-rest-clients： 开启基于rest-clients的自动伸缩
horizontal-pod-autoscaler-sync-period：自动伸缩的检测周期为20s，默认为30s
horizontal-pod-autoscaler-upscale-delay：当检测到满足扩容条件时，延迟多久开始缩容，即该满足的条件持续多久开始扩容，默认为3分钟
horizontal-pod-autoscaler-downscale-delay：当检测到满足缩容条件时，延迟多久开始缩容，即该满足条件持续多久开始缩容，默认为5分钟

	
kubectl run myapp --image=ikubernetes/myapp:v1 --replicas=1 --requests='cpu=50m,memory=128Mi' --limits='cpu=50m,memory=128Mi' --labels='app=myapp' --expose --port=80
# HPA创建用命令即可，以下为基本示例
   kubectl autoscale deployment myapp --min=1 --max=8 --cpu-percent=60
   kubectl autoscale deployment myapp --min=2 --max=10
	如果把副本数设置为大于10个运行个数也是10个

kubectl get hpa
kubectl delete hpa nginx

```
## HPA更多介绍: [HPA](http://www.yfshare.vip/2019/01/28/k8s%E9%9B%86%E7%BE%A4%E6%B0%B4%E5%B9%B3%E6%89%A9%E5%B1%95-HPA/)
## k8s之上promtheus的项目: [promtheus](https://github.com/DirectXMan12)

