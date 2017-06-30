//
//  EmptyVideoView.m
//  KMCVStab
//
//  Created by 张俊 on 28/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "EmptyVideoView.h"

@interface EmptyVideoView ()

@property (nonatomic, strong)UILabel *tipTitle;

@property (nonatomic, strong)UILabel *tipDesc;

@end

@implementation EmptyVideoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self initSubViews];
    }
    return self;
}


- (void)initSubViews
{
    [self addSubview:self.tipTitle];
    [_tipTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.top.mas_equalTo(self).offset(203);
        make.centerX.mas_equalTo(self);
    }];
    [self addSubview:self.tipDesc];
    [_tipDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.top.mas_equalTo(_tipTitle.mas_bottom).offset(14);
        make.centerX.mas_equalTo(self);
    }];
}



- (UILabel *)tipTitle
{
    if (!_tipTitle){
        _tipTitle = [[UILabel alloc] init];
        _tipTitle.textColor = [UIColor colorWithRed:0.800 green:0.800 blue:0.800 alpha:1.00];
        _tipTitle.font = [UIFont systemFontOfSize:28];
        _tipTitle.text = @"无录制视频";
        _tipTitle.textAlignment = NSTextAlignmentCenter;
    }
    return _tipTitle;
}


- (UILabel *)tipDesc
{
    if (!_tipDesc){
        _tipDesc = [[UILabel alloc] init];
        _tipDesc.textColor = [UIColor colorWithRed:0.800 green:0.800 blue:0.800 alpha:1.00];
        _tipDesc.font = [UIFont systemFontOfSize:16];
        _tipDesc.text = @"可返回录制页，点击下方按钮录制视频";
        _tipDesc.textAlignment = NSTextAlignmentCenter;
    }
    return _tipDesc;
}


@end
