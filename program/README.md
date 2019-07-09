# Kubernetes的基本介绍
## 如需安装点击 [链接](https://github.com/sunlge/kubernetes/blob/k8s-1.14.0/program/kubernetes_install/k8s_install.md)
## Kubernetes简介
Kubernetes简称k8s,如果你还没有了解k8s并且想要深入理解它，那么你可以参考以下链接：  
  [中文社区](http://docs.kubernetes.org.cn/230.html)  
  [官网链接](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/)  
  [Git Hub](https://github.com/kubernetes/kubernetes/)  
  [GitHub 获取地址](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.13.md) #对应下载地址  

**单词:**  
	`舵手：kubernetes`    
	
## 相关概念介绍	 

**理解云原生：**

  在一般用法中，云原生是一种构建和运行应用程序的方法，它利用了云计算交付模型的优势。云原生是关于如何创建和部署应用程序，和位置无关。 这意味着应用程序位于云中，而不是传统数据中心.  
	
**理解DevOps：**
```
一种文化和思想，将运维开发产品更好的柔和到一起。参考下列内容   
CI：持续集成  
	项目上线之前：  
		做方案，计划 --> 架构设计 --> 开发 --> 构建 --> 测试  
			开发代码之后的过程称之为CI  
			构建过程可以通过工具完成，所谓的maven之类的工具  
	单元测试：  
		开发者自测代码，保证各自的代码能够正常工作  
	CD：持续交付，Delivery.  
		将测试好以后打包的最终产品自动实现交给运维就是持续交付  
	CD：持续部署，Deployment.  
		自动将产品进行上线或投入生产环境中称之为CD。  
```
**kubernetes设计理念：**

	API设计原则： 
		声明式的：
	           不需要结果，你只需要声明你所期望的状态就好。
	控制机设计原则 
		命令式：
		   返回结果，命令执行成功之后才会返回结果
	
## Kubernetes资源介绍
**容器中的六种中名称空间：**
```
UTS：		主机名和域名
IPC：		信号量，消息队列和共享内存
PID：		进程编号
Network：	网络设备，网络栈，端口等
Mount：		挂载点(文件系统)
User：		用户和用户组
```
**Pod(有生命周期的对象):**
```
Pod是k8s中最小的调度逻辑单元，一个Pod封装多个应用容器（也可以只有一个容器）、存储资源、一个独立的网络 IP 以及管理控制容器运行方式的策略选项。
   Pod三种运行模式：
  	自主式Pod
	控制器管理的Pod
	ReplicationController(副本控制器)				 

---

一个Pod可以拥有多个容器，共享同一个底层的网络名称空间：
   Net UTS IPC这是共享的		

---

多个容器互相隔离的资源：
   User Mount PID,它还可以去挂载共享存储卷。		

---

需要在Pod上放多个容器时；
   	主容器，相当于一个Pod上的master(程序)
   	辅助的容器，去辅助主容器(程序)完成工作。

---		

一个Pod里的所有容器只能运行在一个node上的这个Pod里。				
	为了实现Pod的识别，需要在Pod之上附加一些元数据；	
	拥有一个类似于一个Key值，这个Key值必须是value的这种概念。否则就不是这个Pod。
	根据selector(标签选择器去选择)
	 	Pod，Label，Label Selector 标签选择器
		Label：key=value
		Label Selector：
```

**副本控制器(Replication Controller，RC)**

  `RC` 确保任何时候 `Kubernetes` 集群中有指定数量的 `Pod` 副本 `replicas` 在运行。通过监控运行中的 Pod 来保证集群中运行指定数目的 Pod 副本。指定的数目可以是多个也可以是1个；少于指定数目，RC 就会启动运行新的 Pod 副本；多于指定数目，RC 就会终止多余的 Pod 副本。
		
**副本集（Replica Set，RS）**

  `ReplicaSet（RS）`是 `RC` 的升级版本，唯一区别是对选择器的支持，`RS` 能支持更多种类的匹配模式。副本集对象一般不单独使用，而是作为 `Deployment` 的理想状态参数使用。
		
**Deployment控制器（Deployment）**
  
  部署表示用户对 Kubernetes 集群的一次更新操作。部署比 RS 应用更广，可以是创建一个新的服务，更新一个新的服务，也可以是滚动升级一个服务。滚动升级一个服务，实际是创建一个新的 `RS`，然后逐渐将新 `RS` 中副本数增加到理想状态，将旧 `RS` 中的副本数减小到 `0` 的复合操作；这样一个复合操作用一个RS是不太好描述的，所以用一个更通用的 `Deployment` 来描述。不建议您手动管理利用 `Deployment` 创建的 `RS`。

**服务（Service）**
  
  `Service` 也是 Kubernetes 的基本操作单元，是真实应用服务的抽象，每一个服务后面都有很多对应的容器来提供支持，通过 `Kube-Proxy` 的 port 和服务 `selector` 决定服务请求传递给后端的容器，对外表现为一个单一访问接口，外部不需要了解后端如何运行，这给扩展或维护后端带来很大的好处。

**标签（labels）**
  
  `Labels` 的实质是附着在资源对象上的一系列 `Key/Value` 键值对，用于指定对用户有意义的对象的属性，标签对内核系统是没有直接意义的。标签可以在创建一个对象的时候直接赋予，也可以在后期随时修改，每一个对象可以拥有多个标签，但 `key` 值必须唯一。

**存储卷（Volume）**
  
  Kubernetes 集群中的存储卷跟 Docker 的存储卷有些类似，只不过 Docker 的存储卷作用范围为一个容器，而 Kubernetes 的存储卷的生命周期和作用范围是一个 Pod。每个 Pod 中声明的存储卷由 Pod 中的所有容器共享。支持使用 Persistent Volume Claim 即 PVC 这种逻辑存储，使用者可以忽略后台的实际存储技术，具体关于 Persistent Volumn(pv)的配置由存储管理员来配置。

**持久存储卷（Persistent Volume，PV）和持久存储卷声明（Persistent Volume Claim，PVC）**
 
  `PV` 和 `PVC` 使得 Kubernetes 集群具备了存储的逻辑抽象能力，使得在配置 Pod 的逻辑里可以忽略对实际后台存储技术的配置，而把这项配置的工作交给 PV 的配置者。存储的 `PV` 和 `PVC` 的这种关系，跟计算的 `Node` 和 `Pod` 的关系是非常类似的；`PV` 和 `Node` 是资源的提供者，根据集群的基础设施变化而变化，由 Kubernetes 集群管理员配置；而 PVC 和 Pod是资源的使用者，根据业务服务的需求变化而变化，由 Kubernetes 集群的使用者即服务的管理员来配置。

**Ingress**

  简单的说，`ingress`就是从`kubernetes`集群外访问集群的入口，将用户的URL请求转发到不同的service上。Ingress相当于nginx、apache等负载均衡方向代理服务器，其中还包括规则定义，即URL的路由信息，路由信息得的刷新由`Ingress controller`来提供。用户可以通过 POST Ingress 资源到 API server 的方式来请求 `ingress`。 `Ingress controller` 负责实现 `Ingress`，通常使用负载均衡器，它还可以配置边界路由和其他前端，这有助于以 HA 方式处理流量。通常用来做七层代理。
  
**Ingress Controller：**

  `Ingress Controller` 实质上可以理解为是个监视器，`Ingress Controller` 通过不断地跟 `kubernetes API` 打交道，实时的感知后端 service、pod 等变化，比如新增和减少 pod，service 增加与减少等；当得到这些变化信息后，Ingress Controller 再结合下文的 Ingress 生成配置，然后更新反向代理负载均衡器，并刷新其配置，达到服务发现的作用。  

**高级调度节点特性：**

  节点亲和性/反亲和性特性、Pod亲和性/反亲和性特性、污点和容忍特性、报告节点问题特性。
	
**污点和容忍：**

  污点和容忍（Taints and tolerations）在一起工作，目的是确保Pod不会被调度到不正确的节点上。通过给节点设置污点，可以标识出这些节点不接受任何Pod，这些Pod不能容忍任何污点。也可以通过给Pod设置容忍，让这些Pod部署到能够容忍污点的节点上。
	
**API server组件：**

  在 `kubernetes` 集群中，`API Server` 有着非常重要的角色。`API Server` 负责和 `etcd` 交互（其他组件不会直接操作 etcd(DB)，只有 API Server 这么做），是整个 kubernetes 集群的数据中心，所有的交互都是以 API Server 为核心的。
```  
  简单来说，API Server 提供了一下的功能：  
	整个集群管理的 API 接口：
	所有对集群进行的查询和管理都要通过 API 来进行集群内部各个模块之间通信的枢纽：
	所有模块之前并不会之间互相调用，而是通过和 API Server 打交道来完成自己那部分的工作
```

**K8s的网络模式：**

	节点网络
	集群网络
	Pod 网络

**k8s更多核心概念：**   [参考博客](http://www.cnblogs.com/zhenyuyaodidiao/p/6500720.html)
 
