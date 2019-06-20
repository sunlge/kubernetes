# k8s的RBAC

## 访问k8s的三步流程
    client：
	认证
	授权
	准入控制

## 访问k8s的两种认证方式：
    token
    ssl
	
### 开启一个API接口：
	kubectl proxy --port=8088
	
### 使用API来访问使用资源：	
	Resource:
	Subresource:
	Namespace:
	API group
	curl http://localhost:8088/apis/apps/v1/namespace
	
### 使用API来请求一个Action:
	HTTP request verb:
		get，post，put，delete
	映射为 API requets verb:
		get，list，create，update，patch，watch，protxy....等
	
### 创建一个serviceaccout： ##注意，SA和secrtes是互相关联的。创建SA会自动创建一个Secrtes。
```
kubectl create serviceaccount accout-test --dry-run -oyaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: null
  name: accout-test
```
### 创建一个sa的Pod
	[root@master serviceaccout]# kubectl create serviceaccount admin --dry-run -oyaml

### admin创建完之后会自动创建一个admin-token
```
[root@master RBAC]# kubectl get secrets  |grep admin
NAME                       TYPE                                  DATA   AGE
admin-token-rx989          kubernetes.io/service-account-token   3      3d6h

[root@master serviceaccout]# cat pod-demo-account.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-sa-demo
  namespace: default
  labels:
    app: myapp
    tier: frontend
spec:
  containers:
  - name: myapp
    image: ikubernetes/myapp:v1
  serviceAccountName: admin
```  
### Pod-sa-demo根据sa创建完之后会自动绑定至一个admin-token-rx989
    [root@master serviceaccout]# kubectl describe pod pod-sa-demo |grep SecretName
    SecretName:  admin-token-rx989

### 自己创建一个kubeconfig配置文件,其实它就是UserAccountName资源
	1.set-cluster		##设定集群
	2.set-credentials	##设定用户账号
	3.set-context		##设定上下文
	4.use-context		##设定谁是当前用户
	5.view				##查看config文件

### 切换用户空间
	kubectl config use-context sunlge@kubernetes

###自己建立一个自部署证书，作为另一个账号的认证证书文件。
```
[root@master serviceaccout]# (umask 077; openssl genrsa -out sunlge.key 2048)
[root@master serviceaccout]# openssl req -new -key sunlge.key -out sunlge.csr -subj "/CN=sunlge" ##这里的CN等于你的账号名称
[root@master serviceaccout]# openssl x509 -req  -in sunlge.csr -CA "/etc/kubernetes/pki/ca.crt"  -CAkey "/etc/kubernetes/pki/ca.key" -CAcreateserial -out sunlge.crt -days 366
```
### sunlge其实就是用户的标识,设定用户账号，--embed-certs=true将信息隐藏起来
	[root@master serviceaccout]# kubectl config set-credentials sunlge  --client-certificate=./sunlge.crt --client-key=./sunlge.key --embed-certs=true	

### 创建用户，设定上下文。将集群参数和用户参数关联起来。--user其实就是一个标识，随意指定就好。
	[root@master serviceaccout]# kubectl config set-context sunlge@kubernetes --cluster=kubernetes --user=sunlge

### 切换至用户sunlge，这个用户因为没有权限，所以没有任何的权限。
    [root@master serviceaccout]# kubectl config use-context sunlge@kubernetes
    Switched to context "sunlge@kubernetes".

### 创建一个集群信息，并且将config文件输出到当前目录下的test,cof 
	[root@master serviceaccout]# kubectl config set-cluster mycluster --kubeconfig=./test.cof --server="https://192.168.100.10:6443" --certificate-authority=/etc/kubernetes/pki/ca.crt  --embed-certs=true

### 查看刚刚创建的
	[root@master serviceaccout]# kubectl config view --kubeconfig=./test.cof


### 梳理
	创建一个SA会自动创建一个Secrets资源，这个Secrets资源其实就是一个Token令牌
	Role是一个角色,角色上要定义权限,SA与Role来做一个绑定,也就是所谓的Rolebinding,这样SA就拥有了Role角色的权限
	robinding资源是干嘛的.它其实就是一个动作,将SA与Role绑定到一起.
	

### RBAC
```
RBAC定义一个标准的Role，Role上绑定了权限定义。用户来扮演角色。
Role，标准的k8s资源:
		operations
		objects
		注意，定义时没有拒绝权限，所有都是允许操作，只能许可。

Rolebinding:
	user account OR service account binding in role

#### 级别权限：
Role and Rolebinding属于namespace级别
Clusterrole and Clusterrolebinding属于Cluster级别

#### ServiceAccount授权过程
	1.先创建一个SA，会自动生成一个secrets
	2.创建一个role
	3.将SA绑定到role or clusterrole之上

```
### 定义一个role
```
[root@master ~]# kubectl create role pods-reader --verb=get,list,watch --resource=pods --dry-run -oyaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: null
  name: pods-reader
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - list
  - watch
```
### binding一个Role，注意绑定的是user用户。
```
[root@master RBAC]# kubectl create rolebinding sunlge-read-pods --role=pods-reader --user=sunlge -oyaml --dry-run 
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: null
  name: sunlge-read-pods
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pods-reader
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: sunlge
```
### binding一个Role，这里绑定的是一个ServiceAccount账户
```
[root@master RBAC]# kubectl create rolebinding sunlge-read-pods --role=pods-reader --serviceaccount=default:admin -oyaml --dry-run 
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: null
  name: sunlge-read-pods
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pods-reader
subjects:
- kind: ServiceAccount
  name: admin
  namespace: default
```
### 定义一个ClusterRole
```
[root@master RBAC]# kubectl create clusterrole cluster-reader --verb=get,list,watch --resource=pods -oyaml --dry-run 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  creationTimestamp: null
  name: cluster-reader
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - list
  - watch
```
### clusterrolebinding
```
[root@master RBAC]# kubectl create clusterrolebinding cluster-sunlge-pods --clusterrole=cluster-reader --user=sunlge -oyaml --dry-run 
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  creationTimestamp: null
  name: cluster-sunlge-pods
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-reader
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: sunlge

kubectl get clusterrole		##查看系统的ClusterRole
kubectl describe clusterrolebindings cluster-admin
```
### 部署一个dashboard：
```
	将service改为NodePort
	认证：
		认证时的账号必须为ServiceAccout
		token认证
			1.创建SA，绑定合理的role or  clusterrole
			2.获取此SA的secret的Token
			
		
		kubeconfig：把ServiceAccount的token封装为kubeconfig文件
    
    wget https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

##下面操作也可以直接在源码里面的spec下直接加一个type:NodePort就好了
    [root@master pki]# pwd
    /etc/kubernetes/pki
    [root@master pki]# kubectl patch svc -n kube-system kubernetes-dashboard -p '{"spec":{"type":"NodePort"}}'	
    
```


### 申请证书
	[root@master pki]# cd /etc/kubernetes/pki/^C
	[root@master pki]# (umask 077; openssl genrsa -out dashbord.key 2048)
	[root@master pki]# openssl req -new -key dashbord.key -out dashbord.csr -subj "/O=sunlge/CN=master.sunlge.com"

### 签署颁发证书
```
[root@master pki]# openssl x509 -req -in dashbord.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out dashbord.crt -days 999
[root@master pki]# kubectl config set-cluster kubernetes --certificate-authority=./ca.crt --server="https://192.168.100.10:6443" --embed-certs=true --kubeconfig=/root/def-ns-admin.conf
Cluster "kubernetes" set.

[root@master ~]# kubectl get secrets def-ns-admin-token-vs9hc -o jsonpath={.data.token} | base64 -d
[root@master ~]# kubectl config set-credentials def-ns-admin --token=$DEF_NS_ADMIN_TOKEN
[root@master ~]# kubectl config set-credentials def-ns-admin --token=$DEF_NS_ADMIN_TOKEN --kubeconfig=/root/def-ns-admin.conf 
User "def-ns-admin" set.
[root@master ~]# kubectl config set-context def-ns-admin@kubernetes --cluster=kubernetes --user=def-ns-admin --kubeconfig=/root/def-ns-admin.conf 
[root@master ~]# kubectl config use-context def-ns-admin@kubernetes --kubeconfig=/root/def-ns-admin.conf 
Switched to context "def-ns-admin@kubernetes".
```
	
### token认证
```
[root@master ~]# kubectl create serviceaccount dashboard-admin -n kube-system 
[root@master ~]# kubectl create clusterrolebinding  dashboard-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
[root@master ~]# kubectl describe secrets dashboard-admin-token-2m2v9 -n kube-system 
	其中的token信息就是它的令牌
```	
### 创建一个default
```
[root@master pki]#  kubectl create secret generic dashboard-cert -n kube-system --from-file=dashbord.crt=./dashbord.crt --from-file=dashboard.key=./dashbord.key 
[root@master pki]#  kubectl create serviceaccount def-ns-admin -n default
[root@master pki]#  kubectl create rolebinding def-ns-admin --clusterrole=admin --serviceaccount=default:def-ns-admin	

[root@master dashboard]# kubectl -n kube-system create secret tls k8s-dashboard-secret --key ./tls.key --cert ./tls.crt
[root@master dashboard]# kubectl get secrets --all-namespaces |grep k8s-dashboard-secret
```

## 参考地址
	https://github.com/fanfengqiang/k8s_manifests/tree/master/dashboard
