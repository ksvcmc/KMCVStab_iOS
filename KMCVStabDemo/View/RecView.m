//
//  RecView.m
//  KMCVStab
//
//  Created by 张俊 on 26/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "RecView.h"

@interface RecView ()

//切换
@property (nonatomic, strong)UIButton *toggleBtn;

//底部
@property (nonatomic, strong)UISwitch *vstabSwitch;


@property (nonatomic, strong)UILabel  *vstabLabel;

@end


@implementation RecView

-(instancetype)init
{
    self = [super init];
    if (self){
        [self initSubviews];
        
    }
    return self;
}

-(void)initSubviews
{
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [self addSubview:bgView];
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self);
        make.height.mas_equalTo(@(40));
    }];
    
    [bgView addSubview:self.flashBtn];
    [_flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.mas_equalTo(@(18));
        make.centerY.mas_equalTo(bgView);
    }];
    
    [bgView addSubview:self.timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(bgView);
    }];
    
    [bgView addSubview:self.toggleBtn];
    [_toggleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(@(-18));
        make.centerY.mas_equalTo(bgView);
    }];
    
    UIView *bottomBgView = [[UIView alloc] init];
    bottomBgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [self addSubview:bottomBgView];
    [bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(140);
    }];
    
    [bottomBgView addSubview:self.recBtn];
    [_recBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(@(27));
        make.bottom.mas_equalTo(@(-43));
    }];
    
    [bottomBgView addSubview:self.vstabSwitch];
    
    [_vstabSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@51);
        make.centerY.mas_equalTo(_recBtn);
    }];
    
    [bottomBgView addSubview:self.vstabLabel];
    
    self.vstabLabel.text = [NSString stringWithFormat:@"防抖:%@", _vstabSwitch.on?@"开":@"关"];
    [_vstabLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_vstabSwitch.mas_bottom).offset(7);
        make.centerX.mas_equalTo(_vstabSwitch).offset(3);
    }];
    
    [bottomBgView addSubview:self.playBtn];
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(@(-51));
        make.width.height.mas_equalTo(@50);
        make.centerY.mas_equalTo(_recBtn);
    }];
    
}


-(UIButton *)flashBtn
{
    if (!_flashBtn){
    
        _flashBtn = [self createButtonWithTag:kFlash image:[UIImage imageNamed:@"flash_on"] image:[UIImage imageNamed:@"flash"]];
    }
    return _flashBtn;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel){
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.text = [NSString stringWithHMS:0];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:18];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}

- (UILabel *)vstabLabel
{
    if (!_vstabLabel){
        _vstabLabel = [[UILabel alloc] init];
        _vstabLabel.textColor = [UIColor whiteColor];
        _vstabLabel.font = [UIFont systemFontOfSize:14];
        _vstabLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _vstabLabel;
}

- (UIButton *)toggleBtn
{
    if (!_toggleBtn){
        _toggleBtn = [self createButtonWithTag:kToggle image:[UIImage imageNamed:@"toggle"] image:nil];
    }
    return _toggleBtn;
}

- (UISwitch *)vstabSwitch
{
    if (!_vstabSwitch){
        _vstabSwitch = [[UISwitch alloc] init];
        _vstabSwitch.onTintColor = [UIColor colorWithRed:0.345 green:0.886 blue:0.761 alpha:1.00];
        [_vstabSwitch addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _vstabSwitch;
}

- (UIButton *)recBtn
{
    if (!_recBtn){
        _recBtn = [self createButtonWithTag:kRec image:[UIImage imageNamed:@"rec"] image:[UIImage imageNamed:@"recing"]];
    }
    return _recBtn;
}

- (UIButton *)playBtn
{
    if (!_playBtn){
        _playBtn = [self createButtonWithTag:kPlay image:[UIImage imageNamed:@"default"] image:nil];
    }
    return _playBtn;
}

- (UIButton *)createButtonWithTag:(NSUInteger)tag image:(UIImage *)defaultImg image:(UIImage *)selectedImage
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    if (defaultImg) [btn setImage:defaultImg forState:UIControlStateNormal];
    if (selectedImage) [btn setImage:selectedImage forState:UIControlStateSelected];
    return btn;
}


- (void)onClick:(UIButton *)sender
{
    
    if (self.block){
        self.block(sender.tag, 0);
    }
}

- (void)onValueChanged:(UISwitch *)sender
{
    if (self.block){
        
        self.block(kVStab, sender.on);
        self.vstabLabel.text = [NSString stringWithFormat:@"防抖:%@", _vstabSwitch.on?@"开":@"关"];
    }
    
}

@end
