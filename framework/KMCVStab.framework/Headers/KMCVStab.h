//
//  KMCVStab.h
//  KMCVStab
//
//  Created by 张俊 on 26/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "KMCDefines.h"

@interface KMCVStab : NSObject


+(instancetype)sharedInstance;
/**
 @param token 控制台分配的token
 @param completeSuccess 注册成功后的回调
 @param completeFailure 注册失败后的回调
 */
- (void)authWithToken:(NSString *)token
                  onSuccess:(void (^)(void))completeSuccess
                  onFailure:(void (^)(AuthorizeError iErrorCode))completeFailure;


- (void)process:(CMSampleBufferRef )inBuffer outBuffer:(CVPixelBufferRef)outBuffer;

/**
 是否开启防抖模式， YES 开启，NO关闭
 */
@property(nonatomic, assign) BOOL enableStabi;

@end
