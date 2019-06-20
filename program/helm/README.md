#  k8s的helm基本介绍 
## helm的 RBAC 配置文件示例：
	https://github.com/helm/helm/blob/master/docs/rbac.md
	
### 一定要使用--service-account去绑定
	helm init --service-account tiller --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.9.1 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts


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


### 组织架构：
	helm依赖于tiller
	helm：客户端，管理本地的Chart仓库，管理Chart,与Tiller服务器交互，发送Chart，实例安装、查询、卸载等操作
	Tiller：服务端，接收helm发来的Charts与Config，合并生成relase；
	
	
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
