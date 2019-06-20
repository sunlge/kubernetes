# Ingress 简介

## 介绍traefik:
   Traefik是一款开源的反向代理与负载均衡工具。它最大的优点是能够与常见的微服务系统直接整合，可以实现自动化动态配置。目前支持Docker, Swarm, Mesos/Marathon, Mesos, Kubernetes, Consul, Etcd, Zookeeper, BoltDB, Rest API等等后端模型。    

## 理解Ingress:
  简单的说，ingress就是从kubernetes集群外访问集群的入口，将用户的URL请求转发到不同的service上,通过service资源去标识后端Pod，将后端的Pod的信息直接注入到ingress-controoler中。                                                                                                               Ingress相当于nginx、apache等负载均衡方向代理服务器，其中还包括规则定义，即URL的路由信息，路由信息得的刷新由Ingress controller来提供.

## 理解Ingress Controller:
  Ingress Controller 实质上可以理解为是个监视器，Ingress Controller 通过不断地跟 kubernetes API 打交道，实时的感知后端 service、pod 等变化，比如新增和减少 pod，service 增加与减少等；当得到这些变化信息后，Ingress Controller 再结合下文的 Ingress 生成配置，然后更新反向代理负载均衡器，并刷新其配置，达到服务发现的作用。

### Traefik的basic应用:
    有的web界面需要基于账户的访问控制，Traefik可以利用httpd-tools的htpasswd做到这一点.
    首先下载 yum -y install httpd-tools
    创建一个用户 htpasswd -c auth sunlge
    使用auth文件创建一个secret资源 kubectl create secret generic sunlge --from-file auth --namespace=kube-system
    
    将以下注释附加到Ingress对象：
        traefik.ingress.kubernetes.io/auth-type: "basic"
        traefik.ingress.kubernetes.io/auth-secret: "sunlge" ##这里的sunlge名称一定要和上面创建的secret资源名称相对应

下面是基于traefik的web界面做的一个示例
```bash
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: traefik-web-ui
  namespace: kube-system
##增basic功能.
  annotations:
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/auth-type: "basic"
    traefik.ingress.kubernetes.io/auth-secret: "traefik-basic" 
spec:
  rules:
  - host: node01.sunlge.com
    http:
      paths:
      - path: /
        backend:
          serviceName: traefik-web-ui
          servicePort: admin
```
### 文章参考：
    官方文档：
        https://docs.traefik.io/user-guide/kubernetes/#basic-authentication  
    私人博客：
        https://jimmysong.io/kubernetes-handbook/practice/traefik-ingress-installation.html
       
