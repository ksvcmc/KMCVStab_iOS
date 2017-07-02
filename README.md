# 金山云魔方贴纸API文档
## 项目背景
金山魔方是一个多媒体能力提供平台，通过统一接入API、统一鉴权、统一计费等多种手段，降低客户接入多媒体处理能力的代价，提供多媒体能力供应商的效率。 本文档主要针对视频防抖功能而说明。

## 集成
下载demo, 执行
```
pod install
```
打开KMCVStabDemo.xcworkspace演示demo查看效果

将KMCVStab.framework添加进自己的工程用于集成


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