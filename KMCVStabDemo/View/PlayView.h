//
//  PlayView.h
//  KMCVStab
//
//  Created by 张俊 on 26/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoListModel.h"
#import "EmptyVideoView.h"

@interface PlayView : UIView

- (void)addVideo:(VideoListModel *)model;

- (void)reload;

//播放控制
@property(nonatomic, strong)UIButton        *playCtlBtn;

@property (nonatomic, strong)UIView         *playerView;

@property (nonatomic, strong)EmptyVideoView *tipView;

@property(nonatomic, copy)void (^block)(KMCPlayCtlType type, VideoListModel *model);

@end
