#  Helm基本介绍

## 组织架构：
```
     helm依赖于tiller
     helm：客户端，管理本地的Chart仓库，管理Chart,与Tiller服务器交互，发送Chart，实例安装、查询、卸载等操作
     Tiller：服务端，接收helm发来的Charts与Config，合并生成relase；
```

**1.基本术语**
---
Helm: Kubernetes的应用打包工具，也是命令行工具的名称。  
Tiller: Helm的服务端，以Deployment方式部署在Kubernetes集群中，用于处理Helm的相关命令。  
Chart: Helm的打包格式，内部包含了一组相关的kubernetes资源。  
Repoistory: Helm的软件仓库，repository本质上是一个web服务器，该服务器保存了chart软件包以供下载，并有提供一个该repository的chart包的清单文件以供查询。在使用时，Helm可以对接多个不同的Repository。  
Release: 使用Helm install命令在Kubernetes集群中安装的Chart称为Release。  
    
    Helm中提到的Release和我们通常概念中的版本有所不同，这里的Release可以理解为Helm使用Chart包部署的一个应用实例.  


## 2.安装Helm
---
**2.1.下载源码包进行安装`Version:2.14.2`**
```
wget https://get.helm.sh/helm-v2.14.2-linux-amd64.tar.gz
tar zxf helm-v2.14.2-linux-amd64.tar.gz -C /usr/local/helm
mv /usr/local/helm/linux-amd64* /usr/local/helm/
rm -rf /usr/local/helm/linux-amd64
ln -s /usr/local/helm/helm /usr/local/bin/

```
**2.2.Helm的SA账户**
---

**Helm的 RBAC 配置文件示例：**  
`    https://github.com/helm/helm/blob/master/docs/rbac.md`
```
自己写一个tiller-rbac.yaml文件并且去创建它
cat >> tiller-rbac.yaml <EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
  apiGroup: ""
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF

kubectl apply -f tiller-rbac.yaml

```
**2.3.初始化Helm**
---
```
##安装helm服务端tiller，若无法访问 gcr.io，可以使用阿里云镜像，如：

helm init --service-account tiller --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.12.2 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
    -i   ##指定自己的镜像，因为官方的镜像因为某些原因无法拉取
    --service-account   ##指定SA账户

如果--service-account未指定，可使用下面方法，但是集群内一定要有tiller这个ServiceAccount
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

```

**2.4.检查是否安装成功**
---
```
$ kubectl -n kube-system get pods|grep tiller
tiller-deploy-2372561459-f6p0z         1/1       Running   0          1h
$ helm version
Client: &version.Version{SemVer:"v2.14.2", GitCommit:"a8b13cc5ab6a7dbef0a58f5061bcc7c0c61598e7", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.12.2", GitCommit:"7d2b0c73d734f6586ed222a567c5d103fed435be", GitTreeState:"clean"}
```

### helm的目录结构请参考
	https://helm.sh/docs/developing_charts/#charts

### helm替换源的方法
	helm repo remove stable
	helm repo add stable https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
	helm repo update

### helm添加源的方法
	[root@master myapp]# helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator

### helm官方可用chart列表
	https://hub.kubeapps.com
		显示为 stable 为稳定版本
		显示为 incubator 为测试，预发版本

	
### helm常用命令：
	helm reset --force		##重置
	helm version 			##查看版本信息
	helm repo list			##查看可用镜像仓库
	helm search				##列出可用仓库的所有chart
	helm search jenkins		##过滤
	helm update
	helm inspect stable/jenkins		##列出配置信息
	helm install --name mem1 stable/memcached  ##安装
	helm delete mem1		##卸载删除
	helm delete --purge mem1	##名字也要移除
	helm list				##列出部署程序包
	helm rollback			##回滚版本
	helm upgrade			##升级版本
	helm status				##获取release信息
	helm history			##release的历史信息
	
	helm  package myapp		##打包
	helm  serve				##打开一个charts服务
	helm  create myapp		##自己创建一个
	helm  lint  myapp		##语法检查
	helm  repo  add			##添加仓库  
	
```	
[root@master helm]# helm create myapp
Creating myapp
[root@master myapp]# cat Chart.yaml 
apiVersion: v1
appVersion: "1.0"
description: A Helm chart for Kubernetes myapp test of sunlge
name: myapp
version: 0.0.1
##以下内容为自己添加，还可在添加别的内容，参考https://helm.sh/docs/developing_charts/#charts
maintainer:
- name: SunLge
  email: sunlge@test.com
  url: http://www.sunlge.com

##定义依赖于别的charts	
[root@master myapp]# touch requirements.yaml	
[root@master myapp]# ls
charts  Chart.yaml  requirements.yaml  templates  values.yaml
##语法检查
[root@master myapp]# helm  lint  myapp
==> Skipping myapp
No chart found for linting (missing Chart.yaml)

Error: 0 chart(s) linted, 1 chart(s) failed

[root@master myapp]# helm  lint myapp
==> Skipping myapp
No chart found for linting (missing Chart.yaml)

Error: 0 chart(s) linted, 1 chart(s) failed

[root@master myapp]# helm  lint ../myapp
==> Linting ../myapp
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, no failures	
```	
### 打包自己的程序
```
[root@master helm]# helm package myapp/
Successfully packaged chart and saved it to: /root/program/helm/myapp-0.0.1.tgz
[root@master helm]# ls  mya*
myapp  myapp-0.0.1.tgz  
```
### 打开本地端口
```
[root@master helm]# helm serve
Regenerating index. This may take a moment.
Now serving you on 127.0.0.1:8879
```	
### 搜索本地的helm程序包
```
[root@master ingress]# helm search myapp
NAME            CHART VERSION   APP VERSION     DESCRIPTION                                     
local/myapp     0.0.1           1.0             A Helm chart for Kubernetes myapp test of sunlge
```	
