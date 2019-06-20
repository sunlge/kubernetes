# k8s的Ingress的定义方法及其示例

## Ingress Nginx Controller 部署方式点击以下链接:
[ingress_install_nginx](https://github.com/sunlge/kubernetes/tree/k8s-1.14.0/program/ingress/ingress_install_nginx)

## Ingress Traefik Controller 不是点击以下链接:
[Ingress_Traefik_ingress](https://github.com/sunlge/kubernetes/tree/k8s-1.14.0/program/ingress/Ingress_Traefik_ingress)

### 内部DNS域名格式
```
myapp.myapp-svc.default.svc.cluster.local. @k8s_DNS_IP
pod_name.service_name.ns_name.svc.cluster.local
```

### 负载均衡APP简单介绍
```
服务网格中，Traefik，Traefik，nginx
服务网格倾向于使用Envoy，据说Traefik是为了服务网格而出现的
做微服务更加倾向于Envoy

Service模型：
	userspace 	1.1-
		依赖于Iptables。
	iptables 	1.10-
	IP_vs 		1.10+
		需要添加专门的选项，如果没有则自动降级为Iptables。
		编辑Kubelet的配置文件/etc/sysconfig/kubelet 
			KUBE_PROXY_MODE=ipvs
		
Service本质上是一个四层的调度。
引入集群外部流量的方式，ingress，是一个七层的资源。

LBaas：腾讯的SLB 
LBaas是OpenStack的负载均衡服务，默认采用的是Haproxy作为Driver实现其负载均衡功能，默认情况下，LBaaS不提供高可能功能，
```	
### 资源暴露类型：
```	LoadBlance：在公有云上部署，需要与公有云的LBaas结合
	externalName：将集群外部的服务流量引入内部
		强依赖于DNS，解析A记录，依靠于CNAME -> FQDN
	NodePort：暴露集群内部服务x
	ClusterIP：Pod内部ClusterIP。
	
	kubectl explain svc.spec.sessionAffinity  ##绑定Session，支持动态绑定，粘性会话

##ingress获取地址
	for i in rbac.yaml namespace.yaml mandatory.yaml with-rbac.yaml configmap.yaml ;do wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/$i;done

	kubectl explain ingress.spec.rules	  ##定义当前ingress资源的转发规则
	kubectl explain ingress.spec.backend	  ##定义全局默认

##生成证书
openssl genrsa -out tls.key 2048
openssl req -new -x509 -key tls.key -out tls.crt -subj /C=CN/ST=Beijing/L=Beijing/O=DevOps/CN=master.sunlge.com -days 3605

##创建一个Secrets资源
kubectl create secret tls tomcat-ingress-secret --cert=tls.crt --key=tls.key 

##创建一个TLS类型的Ingress资源配置清单
[root@master tls]# cat tomcat-ingress-tls.yaml 
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-tomcat
  namespace: test-ingress
spec:
  tls:
  - hosts:
    - master.sunlge.com
    secretName: tomcat-ingress-secret
  rules:
  - host: master.sunlge.com
    http:
      paths:
      - path: /
        backend:
         serviceName: tomcat-svc
         servicePort: 8080  
```
