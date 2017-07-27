# 金山云魔方防抖API文档
## 项目背景
金山魔方是一个多媒体能力提供平台，通过统一接入API、统一鉴权、统一计费等多种手段，降低客户接入多媒体处理能力的代价，提供多媒体能力供应商的效率。 本文档主要针对视频防抖功能而说明。

## 集成

- 直接集成

下载demo, 执行
```
pod install
```
打开KMCVStabDemo.xcworkspace演示demo查看效果

将KMCVStab.framework添加进自己的工程用于集成

- Pod集成

```
pod 'KMCVStab', '~> 1.0.0'

```


## SDK使用指南  

本sdk使用简单，初次使用需要在魔方服务后台申请token，用于客户鉴权，使用下面的接口鉴权
``` objective-c
- (void)authWithToken:(NSString *)token
                  onSuccess:(void (^)(void))completeSuccess
                  onFailure:(void (^)(AuthorizeError iErrorCode))completeFailure;
```

开启防抖功能

``` objective-c
@property(nonatomic, assign) BOOL enableStabi;
```
处理视频帧

``` objective-c

- (void)process:(CMSampleBufferRef )inBuffer outBuffer:(CVPixelBufferRef)outBuffer;

```
开启防抖之后outBuffer即为处理过的帧

## 接入流程
![金山魔方接入流程](https://raw.githubusercontent.com/wiki/ksvcmc/KMCSTFilter_Android/all.jpg "金山魔方接入流程")
## 接入步骤  
1.登录[金山云控制台]( https://console.ksyun.com)，选择视频服务-金山魔方
![步骤1](https://raw.githubusercontent.com/wiki/ksvcmc/KMCSTFilter_Android/step1.png "接入步骤1")

2.在金山魔方控制台中挑选所需服务。
![步骤2](https://raw.githubusercontent.com/wiki/ksvcmc/KMCSTFilter_Android/step2.png "接入步骤2")

3.点击申请试用，填写申请资料。
![步骤3](https://raw.githubusercontent.com/wiki/ksvcmc/KMCSTFilter_Android/step3.png "接入步骤3")

![步骤4](https://raw.githubusercontent.com/wiki/ksvcmc/KMCSTFilter_Android/step4.png "接入步骤4")

4.待申请审核通过后，金山云注册时的邮箱会收到邮件及试用token。
![步骤5](https://raw.githubusercontent.com/wiki/ksvcmc/KMCSTFilter_Android/step5.png "接入步骤5")

5.下载安卓/iOS版本的SDK集成进项目。
![步骤6](https://raw.githubusercontent.com/wiki/ksvcmc/KMCSTFilter_Android/step6.png "接入步骤6")

6.参照文档和DEMO填写TOKEN，就可以Run通项目了。  
7.试用中或试用结束后，有意愿购买该服务可以与我们的商务人员联系购买。  
（商务Email:KSC-VBU-KMC@kingsoft.com）  
## 反馈与建议  
主页：[金山魔方](https://docs.ksyun.com/read/latest/142/_book/index.html)  
邮箱：ksc-vbu-kmc-dev@kingsoft.com  
QQ讨论群：574179720 [视频云技术交流群]
