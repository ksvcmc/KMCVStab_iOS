//
//  PlayView.m
//  KMCVStab
//
//  Created by 张俊 on 26/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "PlayView.h"
#import "VideoList.h"

@interface PlayView ()

@property (nonatomic, strong)VideoList *vidListView;

@end

@implementation PlayView


- (instancetype)init
{
    self = [super init];
    if (self){
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    [self addSubview:self.vidListView];
    [_vidListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(@(114));
    }];
    
    [self addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(_vidListView.mas_top);
        make.top.mas_equalTo(self.mas_top);
    }];
    
    [self addSubview:self.playCtlBtn];
    [_playCtlBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(_playerView);
    }];
    
    [self addSubview:self.tipView];
    self.tipView.hidden = YES;
    [_tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];

}


- (void)addVideo:(VideoListModel *)model
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_vidListView){
            [_vidListView.dataArray addObject:model];
            //[_vidListView.collectionView reloadData];
            
            //[_vidListView.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];

        }
    });

}

- (void)reload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_vidListView){
            [_vidListView.collectionView reloadData];
            
            //[_vidListView.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
            
        }
    });
}


- (EmptyVideoView *)tipView
{
    if (!_tipView){
        _tipView = [[EmptyVideoView alloc] init];
    }
    return _tipView;
}

- (VideoList *)vidListView
{
    if (!_vidListView){
        _vidListView = [[VideoList alloc] initWithIdentifier:@"VIdeoList"];
        
    }
    return _vidListView;
}


- (UIView *)playerView
{
    if (!_playerView){
        _playerView = [[UIView alloc] init];
    }
    return _playerView;
}

- (UIButton *)playCtlBtn
{
    if (!_playCtlBtn){
        
        _playCtlBtn= [UIButton buttonWithType:UIButtonTypeCustom];

        [_playCtlBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [_playCtlBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        
    }
    return _playCtlBtn;
}

- (void)onClick:(id)sender
{
    if (self.block){
        self.block(CtlType_Play, nil);
    }
}

-(void)setBlock:(void (^)(KMCPlayCtlType, VideoListModel *))block
{
    _block = block;
    _vidListView.block = block;
}
@end
