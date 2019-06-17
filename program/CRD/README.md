CRD的工作步骤如下：

用户向Kubernetes API服务注册一个带特定schema的资源，并定义相关API

注册一系列该资源的实例
在Kubernetes的其它资源对象中引用这个新注册资源的对象实例
用户自定义的controller例程需要对这个引用进行释义和实施，让新的资源对象达到预期的状态
从基本原理上来讲，CRD定义的Kubernetes扩展资源：


详情参考原文：
  https://blog.csdn.net/cloudvtech/article/details/80277960 
