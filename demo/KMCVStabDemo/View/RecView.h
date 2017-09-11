//
//  RecView.h
//  KMCVStab
//
//  Created by 张俊 on 26/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMCVStabGLView.h"


typedef NS_ENUM(NSUInteger, RecCtlType)
{
    kToggle = 1,
    kFlash,
    kRec,
    kVStab,
    kPlay,
    kBack
};

//@interface RecView : KMCVStabGLView
@interface RecView : UIView

//散光灯
@property (nonatomic, strong)UIButton       *backBtn;

//录制时间
@property (nonatomic, strong)UILabel        *timeLabel;

//录制
@property (nonatomic, strong)UIButton       *recBtn;

//跳转播放
@property (nonatomic, strong)UIButton       *playBtn;

@property (nonatomic, copy)void (^block)(RecCtlType type, BOOL on);

@end
