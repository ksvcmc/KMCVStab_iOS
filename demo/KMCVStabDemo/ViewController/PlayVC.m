//
//  PlayVC.m
//  KMCVStab
//
//  Created by 张俊 on 26/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "PlayVC.h"
#import "PlayView.h"
#import "VideoListModel.h"
#import  <AVFoundation/AVFoundation.h>

@interface PlayVC ()
{
    AVPlayer      *_player;
    NSURL         *_playUrl;

}

@property(nonatomic, strong)PlayView *playView;

@end

@implementation PlayVC

- (instancetype)initWithUrl:(NSURL *)url
{
    self = [super init];
    if (self){
        _playUrl = url;
    }
    return self;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.playView];
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.title = @"视频";
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent  = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:18],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self action:@selector(onBack)];
    self.navigationItem.leftBarButtonItem  = leftBarItem;
    
    [_playView mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.edges.mas_equalTo(self.view);
    }];
    
    __weak typeof(self) weakSelf = self;
    _playView.block = ^(KMCPlayCtlType type, VideoListModel *model){
        __strong typeof(self) strongSelf = weakSelf;
        if (type == CtlType_Play){
            weakSelf.playView.playCtlBtn.hidden = YES;
            [strongSelf->_player seekToTime:kCMTimeZero];
            [strongSelf->_player play];
        }
        if (type == CtlType_Switch){
            strongSelf->_playUrl = model.url;
            [strongSelf->_player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:model.url]];
            [strongSelf->_player pause];
            [strongSelf->_player seekToTime:kCMTimeZero];
            weakSelf.playView.playCtlBtn.hidden = NO;
        }
    };
    
    [self scanVideos:^(VideoListModel *model) {
        //
        if (_playView){
            
            [_playView addVideo:model];
        }
    } done:^(int count) {
        if (count <= 0){
            if (_playView){
                _playView.tipView.hidden = NO;
            }
        }else{
            if (_playView){
                [_playView reload];
            }
        }

    }];
    

 
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:_playUrl];
    _player = [AVPlayer playerWithPlayerItem:item];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [playerLayer setFrame:self.playView.playerView.bounds];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.playView.playerView.layer addSublayer:playerLayer];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}


- (PlayView *)playView
{
    if (!_playView){
        _playView = [[PlayView alloc] init];
    }
    return _playView;
}

-(void)playerDidFinishPlaying:(NSNotification *)notification
{
    self.playView.playCtlBtn.hidden = NO;
//    [_player seekToTime:kCMTimeZero];
//    [_player play];
}


- (void)onBack
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark -- private utils
- (void)scanVideos:(void (^)(VideoListModel *model))finishBlock done:(void(^)(int count))done
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *dir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"cache"];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if (![fileMgr fileExistsAtPath:dir]){
            if (done){
                done(0);
            }
            return;
        }
        else{
            
            NSArray *pathsArr = [fileMgr subpathsAtPath:dir];
            if (!pathsArr || pathsArr.count == 0){
                if (done){
                    done(0);
                }
                return;
            }
            NSArray *sortedFiles = [pathsArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                //
                int64_t  f1 = [[obj1 stringByDeletingPathExtension] longLongValue];
                int64_t  f2 = [[obj2 stringByDeletingPathExtension] longLongValue];
                return (f2 > f1);
            }];
            
            NSEnumerator *fileEnu = [sortedFiles objectEnumerator];
            
            NSString *file;
            int ref = 0;
            while ((file = [fileEnu nextObject])) {
                if ([[file pathExtension] isEqualToString: @"mov"]) {
                    
                    @autoreleasepool {
                        // process the document
                        if (finishBlock){
                            VideoListModel *model = [[VideoListModel alloc] init];
                            NSString *path = [dir stringByAppendingPathComponent:file];
                            model.url   = [NSURL fileURLWithPath:path];
                            if (!_playUrl) {
                                _playUrl = model.url;
                                model.checked = YES;
                            }else if ([self->_playUrl.path isEqualToString:path]){
                                model.checked = YES;
                            }
                            ref ++;
                            model.thumb = [Helper thumbnailForVideo:model.url error:nil];
                            finishBlock(model);
                        }
                    }
                    
                }
            }
            if (done){
                done(ref);
            }
            
        }
    });

}




@end
