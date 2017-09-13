//
//  StreamerVC.m
//  KMCVStab
//
//  Created by 张俊 on 06/09/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "StreamerVC.h"
#import "RecView.h"
#import <KMCVStab/KMCVStab.h>
#import <MBProgressHUD.h>
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/KSYGPUStreamerKit.h>

#define SYSTEM_VERSION_GE_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface StreamerVC ()
{
    KSYBeautifyProFilter *_filter;     // 滤镜效果
    CVPixelBufferRef     _tmpPixelBuffer;
    
    NSString *_strUrl;
    NSString *_bypassRecFile;
    BOOL      _isSaveVideo;
    NSTimeInterval start;
    
    BOOL     _isAuth;
    NSString *_errStr;

}

@property (nonatomic, strong)KSYGPUStreamerKit *streamerKit;

@property (nonatomic, strong)KMCVStab          *kmcvStab;

@property (nonatomic, strong)RecView           *recView;

@property (nonatomic, strong)UIView            *previewView;

@property (nonatomic, strong)NSTimer           *timer;

@property (nonatomic, strong)MBProgressHUD     *hud;

@end

@implementation StreamerVC


-(instancetype)initWithUrl:(NSString *)strUrl isSave:(BOOL)isSave
{
    self = [super init];
    if (self) {
        _strUrl      = strUrl;
        _isSaveVideo = isSave;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.previewView.frame  = self.view.frame;

    self.previewView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.previewView];
    [self.view addSubview:self.recView];
    
    // Do any additional setup after loading the view.
    
    __weak typeof(self) weakSelf = self;
    self.recView.recBtn.enabled = NO;
    _kmcvStab = [KMCVStab sharedInstance];
    _kmcvStab.videoOrientation = AVCaptureVideoOrientationPortrait;
    [_kmcvStab authWithToken:@"a2fa06b24c9173562ab961a84313c00a" onSuccess:^{
        _isAuth = TRUE;
        dispatch_async(dispatch_get_main_queue(), ^{
            //weakSelf.errLabel.text = @"鉴权成功";
            
            self.recView.recBtn.enabled = YES;
        });
        
        
        
    } onFailure:^(AuthorizeError iErrorCode) {
        if (iErrorCode == AUTHORIZE_ERROR_NotConnectedToInternet){
            _errStr = @"无网络连接，请检查你的网络状态";
        }else{
            _errStr = [NSString stringWithFormat:@"鉴权失败,错误码：%@", @(iErrorCode)];
        }
        [weakSelf toast:_errStr];
        _isAuth = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            //weakSelf.errLabel.text = @"鉴权成功";
            self.recView.recBtn.enabled = YES;
        });
        
    }];
    

    [_recView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    self.recView.block = ^(RecCtlType type, BOOL extra){
        if (type == kVStab){
            if (weakSelf.kmcvStab){
                weakSelf.kmcvStab.enableStabi = extra;
            }
        }
        if (type == kToggle){
            [weakSelf toggleCamera];
        }
        if (type == kBack){
            [weakSelf onBack];
        }
        
        if (type == kRec){
            [weakSelf startStream];
        }
        
    };

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // size
    CGFloat minLength = MIN(_previewView.frame.size.width, _previewView.frame.size.height);
    CGFloat maxLength = MAX(_previewView.frame.size.width, _previewView.frame.size.height);
    CGRect newFrame;
    // frame
    CGAffineTransform newTransform;
    
    UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (currentInterfaceOrientation == UIInterfaceOrientationPortrait) {
        newTransform = CGAffineTransformIdentity;
        newFrame = CGRectMake(0, 0, minLength, maxLength);
    } else {
        newTransform = CGAffineTransformMakeRotation(M_PI_2*(currentInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ? 1 : -1));
        newFrame = CGRectMake(0, 0, maxLength, minLength);
    }
    
    _previewView.transform = newTransform;
    _previewView.frame = newFrame;
    
    [self prepareStreamerKit];
    [self registerNotifications];
}

- (void)toggleCamera
{
    [_streamerKit switchCamera];
}

- (void)onBack
{
    [_streamerKit stopPreview];
    [_streamerKit.streamerBase stopStream];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)startStream
{
    if (!_isAuth){
        [self toast:_errStr];
        return;
    }
    if (!_streamerKit.streamerBase.isStreaming){
        self.recView.recBtn.selected = YES;
        [_streamerKit.streamerBase startStream:[NSURL URLWithString:_strUrl]];

    }else{
        
        [_streamerKit.streamerBase stopStream];
        //self.recView.recBtn.selected = NO;
        if (self.timer){
            [self.timer invalidate];
            self.timer = nil;
        }
        self.recView.timeLabel.text = [NSString stringWithHMS:0];

    }
    
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInf{
    if (error) {
        self.hud.mode = MBProgressHUDModeText;
        self.hud.label.text = @"保存失败";
        
    }else{
        self.hud.mode = MBProgressHUDModeText;
        self.hud.label.text = @"保存成功";
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.hud hideAnimated:YES];
    });
}

- (RecView *)recView
{
    if (!_recView){
        _recView = [[RecView alloc] init];
    }
    return _recView;
}

//- (UIView *)previewView
//{
//    if (!_previewView){
//        _previewView = [[UIView alloc] init];
//    }
//    return _previewView;
//}


- (void)prepareStreamerKit{
    if (!_streamerKit){
        _streamerKit = [[KSYGPUStreamerKit alloc] initWithDefaultCfg];
    }
    // 采集相关设置初始化
    [self setupCaptureCfg];
    
    // 默认开启 前置摄像头
    _streamerKit.cameraPosition = AVCaptureDevicePositionFront;
    
    // 开启默认美颜：柔肤
    _filter = [[KSYBeautifyProFilter alloc] init];
    [_streamerKit setupFilter:_filter];
    
    // 开启预览
    [_streamerKit startPreview:self.previewView];
    _streamerKit.gpuOutputPixelFormat = kCVPixelFormatType_32BGRA;
    _streamerKit.capturePixelFormat   = kCVPixelFormatType_32BGRA;
    __weak typeof(self) weakSelf = self;
    _streamerKit.videoProcessingCallback = ^(CMSampleBufferRef sampleBuffer){
        
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        size_t w = CVPixelBufferGetWidth(pixelBuffer);
        size_t h = CVPixelBufferGetHeight(pixelBuffer);
        
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf && !strongSelf->_tmpPixelBuffer){
            // empty IOSurface properties dictionary
            CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFMutableDictionaryRef attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
            
            CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault, w, h,
                                                  kCVPixelFormatType_32BGRA, attrs, &strongSelf->_tmpPixelBuffer);
            if (result) {
                NSLog(@"Create local pixel buffer error:%d", result);
            }
            CFRelease(empty);
            CFRelease(attrs);
        }
        if (strongSelf){
            [strongSelf->_kmcvStab process:sampleBuffer outBuffer:strongSelf->_tmpPixelBuffer];
            CVPixelBufferLockBaseAddress(pixelBuffer, 0);
            
            CVPixelBufferLockBaseAddress(strongSelf->_tmpPixelBuffer, 0);
            
            void *targetBase = CVPixelBufferGetBaseAddress(pixelBuffer);
            void *tmpBase    = CVPixelBufferGetBaseAddress(strongSelf->_tmpPixelBuffer);
            
            if (targetBase && tmpBase){
                memcpy(targetBase, tmpBase, CVPixelBufferGetDataSize(strongSelf->_tmpPixelBuffer));
            }
            
            CVPixelBufferUnlockBaseAddress(strongSelf->_tmpPixelBuffer, 0);
        }

        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    };
    
}

- (void)setupCaptureCfg{
    
    _streamerKit.capPreset           = AVCaptureSessionPreset1280x720;
    _streamerKit.previewDimension   = CGSizeMake(1280, 720);
    _streamerKit.videoOrientation   = UIInterfaceOrientationPortrait;
    _streamerKit.streamOrientation  = UIInterfaceOrientationPortrait;
    _streamerKit.previewOrientation = UIInterfaceOrientationPortrait;
    
    [[AVAudioSession sharedInstance]setBInterruptOtherAudio:NO];
    
    _streamerKit.streamerProfile = KSYStreamerProfile_720p_3;
    
    /// 设置gpu输出的图像像素格式 （kCVPixelFormatType_32BGRA、kCVPixelFormatType_4444AYpCbCr8）
    _streamerKit.gpuOutputPixelFormat = kCVPixelFormatType_32BGRA;
    
    _streamerKit.streamerBase.videoCodec = KSYVideoCodec_AUTO;
    _streamerKit.streamerBase.videoInitBitrate =  _streamerKit.streamerBase.videoMaxBitrate*6/10;
    _streamerKit.streamerBase.videoMinBitrate  =    0;
    //_streamerKit.streamerBase.audiokBPS = audioBitRate;//kbps
    _streamerKit.streamerBase.bwEstimateMode = KSYBWEstMode_Default;
    _streamerKit.streamerBase.shouldEnableKSYStatModule = YES;
    _streamerKit.streamerBase.logBlock = ^(NSString* str){
        
    };
    _streamerKit.streamerBase.audioCodec = KSYAudioCodec_AAC_HE;
}

- (void)registerNotifications{
    // 网络状态
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNetStateEvent:)
                                                 name:KSYNetStateEventNotification
                                               object:nil];
    // 采集状态
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCaptureStateChange:)
                                                 name:KSYCaptureStateDidChangeNotification
                                               object:nil];
    
    // 推流状态
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onStreamStateChange:)
                                                 name:KSYStreamStateDidChangeNotification
                                               object:nil];
    
    
}


/**
 推流错误
 */
- (void)onStreamError:(KSYStreamErrorCode)errCode{
    switch (errCode) {
        case KSYStreamErrorCode_CODEC_OPEN_FAILED:  // 无法打开配置指示的CODEC
        case KSYStreamErrorCode_AV_SYNC_ERROR:      // 音视频同步失败 (输入的音频和视频的时间戳的差值超过5s)
        case KSYStreamErrorCode_CONNECT_BREAK:      // 网络中断
            [self tryReconnect];
            return;
        default:{
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf toast:[NSString stringWithFormat:@"推流出错了, 错误码:(%@)", @(errCode)]];
                weakSelf.recView.recBtn.selected = NO;
                [_streamerKit.streamerBase stopStream];
                if (self.timer){
                    [self.timer invalidate];
                    self.timer = nil;
                }
                self.recView.timeLabel.text = [NSString stringWithHMS:0];
            });
            
        }break;
    }
}

- (void) onCaptureStateChange:(NSNotification *)notification {
    if ( _streamerKit.captureState == KSYCaptureStateIdle){
        NSLog(@"idle");
    }
    else if (_streamerKit.captureState == KSYCaptureStateCapturing ) {
        NSLog(@"capturing");
    }
    else if (_streamerKit.captureState == KSYCaptureStateClosingCapture ) {
        NSLog(@"closing capture");
    }
    else if (_streamerKit.captureState == KSYCaptureStateDevAuthDenied ) {
        NSLog(@"camera/mic Authorization Denied");
    }
    else if (_streamerKit.captureState == KSYCaptureStateParameterError ) {
        NSLog(@"capture devices ParameterErro");
    }
    else if (_streamerKit.captureState == KSYCaptureStateDevBusy ) {
        NSLog(@"device busy, try later");
    }
}

- (void) onStreamStateChange:(NSNotification *)notification {
    NSLog(@"=================>");
    if ( _streamerKit.streamerBase.streamState == KSYStreamStateIdle) {
        NSLog(@"onStreamStateChange idle");
        //推流结束
        if (_recView.recBtn.selected){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_isSaveVideo && _bypassRecFile != nil){
                    
                    
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_bypassRecFile)) {
                        
                        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        self.hud.label.text = @"正在保存视频";
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            UISaveVideoAtPathToSavedPhotosAlbum(_bypassRecFile, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                        });
                        
                        
                    }else{
                        [self toast:@"该视频无法无法保存"];
                    }
                }
            });

        }
        _recView.recBtn.selected = NO;
    }
    else if ( _streamerKit.streamerBase.streamState == KSYStreamStateConnected){
        NSLog(@"connected");
        
        _recView.recBtn.selected = YES;
        
        BOOL bRec = _streamerKit.streamerBase.bypassRecordState == KSYRecordStateRecording;
        
        if (_isSaveVideo && _streamerKit.streamerBase.isStreaming && !bRec ){
            
            self->start = time(nil);
            
            if (!self.timer){
                self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(onCountDown:) userInfo:nil repeats:YES];
            }
            
            _bypassRecFile = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@.mp4", @(self->start)];
            NSURL *url =[[NSURL alloc] initFileURLWithPath:_bypassRecFile];
            [_streamerKit.streamerBase startBypassRecord:url];
        }
        
    }
    else if (_streamerKit.streamerBase.streamState == KSYStreamStateConnecting ) {
        NSLog(@"kit connecting");
    }
    else if (_streamerKit.streamerBase.streamState == KSYStreamStateDisconnecting ) {
        NSLog(@"disconnecting");
    }
    else if (_streamerKit.streamerBase.streamState == KSYStreamStateError ) {
        [self onStreamError:_streamerKit.streamerBase.streamErrorCode];
    }
}


- (void) onNetStateEvent:(NSNotification *)notification {
    KSYNetStateCode netEvent = _streamerKit.streamerBase.netStateCode;
    if ( netEvent == KSYNetStateCode_SEND_PACKET_SLOW ) {
        NSLog(@"bad network" );
    }
    else if ( netEvent == KSYNetStateCode_EST_BW_RAISE ) {
        NSLog(@"bitrate raising" );
    }
    else if ( netEvent == KSYNetStateCode_EST_BW_DROP ) {
        NSLog(@"bitrate dropping" );
    }
}

- (void)tryReconnect{
    
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        NSLog(@"try again");
        [_streamerKit.streamerBase startStream:[NSURL URLWithString:_strUrl]];
    });
}

-(void)dealloc
{
    // 停止预览
    [_streamerKit stopPreview];
    _streamerKit = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator NS_AVAILABLE_IOS(8_0)
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // size
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat minLength = MIN(screenSize.width, screenSize.height);
    CGFloat maxLength = MAX(screenSize.width, screenSize.height);
    CGRect newFrame;
    
    // frame
    CGAffineTransform newTransform;
    // need stay frame after animation
    CGAffineTransform newTransformOfStay;
    // whether need to stay
    __block BOOL needStay = NO;
    
    UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    UIDeviceOrientation toDeviceOrientation = [UIDevice currentDevice].orientation;
    
    if (toDeviceOrientation == UIDeviceOrientationPortrait){
        newTransform = CGAffineTransformIdentity;
        newFrame = CGRectMake(0, 0, minLength, maxLength);
    }else{
        if (currentInterfaceOrientation == UIInterfaceOrientationPortrait) {
            newTransform = CGAffineTransformMakeRotation(M_PI_2*(toDeviceOrientation == UIDeviceOrientationLandscapeRight ? 1 : -1));
        } else {
            needStay = YES;
            if (currentInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                newTransform = CGAffineTransformRotate(self.previewView.transform, M_PI * 1.00001);
                newTransformOfStay = CGAffineTransformRotate(self.previewView.transform, M_PI);
            }else{
                newTransform = CGAffineTransformRotate(self.previewView.transform, SYSTEM_VERSION_GE_TO(@"8.0") ? 1.00001 * M_PI : M_PI * 0.99999);
                newTransformOfStay = CGAffineTransformRotate(self.previewView.transform, M_PI);
            }
        }
        newFrame = CGRectMake(0, 0, maxLength, minLength);
    }

    __weak typeof(self) weakSelf = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        if(SYSTEM_VERSION_GE_TO(@"8.0")) {
            [self onViewRotate];
        }
        
        strongSelf.previewView.transform = newTransform;
        strongSelf.previewView.frame =  newFrame;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        if (needStay) {
            strongSelf.previewView.transform = newTransformOfStay;
            strongSelf.previewView.frame = newFrame;
            needStay = NO;
        }
    }];
}
    
- (void)onCountDown:(id)sender
{
    self.recView.timeLabel.text = [NSString stringWithHMS:(time(nil) - start)];
}

- (void)toast:(NSString *)msg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = msg;
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:2.f];
    });
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if(SYSTEM_VERSION_GE_TO(@"8.0")) {
        return;
    }
    [self onViewRotate];
}
- (void) onViewRotate {
    
    UIInterfaceOrientation orie = [[UIApplication sharedApplication] statusBarOrientation];
    [_streamerKit rotateStreamTo:orie];
}


- (BOOL)shouldAutorotate
{
    if (self.recView.recBtn.selected){
        return NO;
    }else{
        return YES;
    }
    
    
}







@end
