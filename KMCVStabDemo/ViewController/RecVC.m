//
//  RecVC.m
//  KMCVStab
//
//  Created by 张俊 on 26/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "RecVC.h"
#import "RecView.h"
#import "KMCVStabGLView.h"
#import "PlayVC.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <KMCVStab/KMCVStab.h>

@interface RecVC ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    CVPixelBufferRef    _resultBufferNormal;
    
    AVCaptureConnection *_videoConnection;
    NSDictionary *_videoCompressionSettings;
    
    AVAssetWriter       *_assetWriter;
    
    CMFormatDescriptionRef _videoTrackSourceFormatDescription;
    CGAffineTransform _videoTrackTransform;
    NSDictionary *_videoTrackSettings;
    AVAssetWriterInput *_videoInput;
    AVCaptureVideoDataOutput *_videoOutput;
    
    
    AVCaptureDevice *_videoDevice;
    AVCaptureVideoOrientation _videoBufferOrientation;
    BOOL isStartRecord, isSessionStarted;
    
    NSURL *_outputUrl;

}

@property (nonatomic, strong)AVCaptureSession     *captureSession;

@property (nonatomic, strong)AVCaptureDeviceInput *videoDeviceInput;

@property (nonatomic, strong)KMCVStab             *vStab;

@property (nonatomic, strong)RecView              *recView;

@property (nonatomic, strong)NSTimer              *timer;

@end

@implementation RecVC


- (instancetype)init
{
    self = [super init];
    if (self) {
        _vStab = [KMCVStab sharedInstance];
        [_vStab authWithToken:@"bafa06b24c9260562ab961a84313c110" onSuccess:^{
            NSLog(@"鉴权成功");
        } onFailure:^(AuthorizeError iErrorCode) {
            NSString * errorMessage = [[NSString alloc]initWithFormat:@"鉴权失败，错误码:%@", @(iErrorCode)];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:errorMessage delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                [alert show];
            });
        }];
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    // Do any additional setup after loading the view.
    _videoTrackTransform = CGAffineTransformIdentity;

    [self setupCamera];
    [self.view addSubview:self.recView];
    [_recView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    __weak typeof(self) weakSelf = self;
    self.recView.block = ^(RecCtlType type, BOOL extra){
        if (type == kVStab){
            if (weakSelf.vStab){
                weakSelf.vStab.enableStabi = extra;
            }
        }
        if (type == kToggle){
            [weakSelf toggleCamera];
        }
        if (type == kFlash){
            [weakSelf flash];
        }
        __strong typeof(self) strongSelf = weakSelf;
        if (type == kRec){
            if (weakSelf.recView.recBtn.selected){
                
                [weakSelf stopRecord:^{
                    
                    UIImage *image = [Helper thumbnailForVideo:strongSelf->_outputUrl error:nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.recView.recBtn.selected = NO;
                        [weakSelf.recView.playBtn setImage:image forState:UIControlStateNormal];
                        weakSelf.recView.timeLabel.text = [NSString stringWithHMS:0];
                    });
                }];
                if (weakSelf.timer){
                    [weakSelf.timer invalidate];
                    weakSelf.timer = nil;
                }
                
                
            }else{
                [weakSelf startRecord];
                weakSelf.recView.recBtn.selected = YES;
                NSTimeInterval start = time(nil);
                if (!weakSelf.timer){
                    weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
                        weakSelf.recView.timeLabel.text = [NSString stringWithHMS:(time(nil) - start)];
                    }];
                }
            }
            
        }
        if (type == kPlay){
            PlayVC *vc = [[PlayVC alloc] initWithUrl:strongSelf->_outputUrl];
            UINavigationController *navi = [[UINavigationController alloc]  initWithRootViewController:vc];
            [weakSelf presentViewController:navi animated:NO completion:nil];
        }
    
    };
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}


- (void)onEnterBackground:(NSNotificationCenter *)sender
{
    if (!isStartRecord) return ;
    __weak typeof(self) weakSelf = self;
    [self stopRecord:^{
        __strong typeof(self) strongSelf = weakSelf;
        UIImage *image = [Helper thumbnailForVideo:strongSelf->_outputUrl error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.recView.recBtn.selected = NO;
            [weakSelf.recView.playBtn setImage:image forState:UIControlStateNormal];
            weakSelf.recView.timeLabel.text = [NSString stringWithHMS:0];
        });
    }];
    if (self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (RecView *)recView
{
    if (!_recView){
        _recView = [[RecView alloc] init];
        
    }
    return _recView;
}

- (void)setupCamera
{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *device = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *d in devices) {
        if ([d position] == AVCaptureDevicePositionBack) {
            device = d;
            break;
        }
    }
    _videoDevice = device;
    AVCaptureDeviceInput *videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    //AVCaptureMovieFileOutput
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    [videoOutput setVideoSettings:@{
                                    (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                    }];
    
    dispatch_queue_t videoCaptrueQueue = dispatch_queue_create("com.paraken.video-capture", DISPATCH_QUEUE_SERIAL);
    [videoOutput setSampleBufferDelegate:self queue:videoCaptrueQueue];
    
    if ([session canAddInput:videoDeviceInput]) {
        [session addInput:videoDeviceInput];
        self.videoDeviceInput = videoDeviceInput;
        
    } else {
        return;
    }
    if ([session canAddOutput:videoOutput]) {
        [session addOutput:videoOutput];
        _videoConnection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
        _videoCompressionSettings = [[videoOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie] copy];
        
        _videoBufferOrientation = _videoConnection.videoOrientation;
        
    } else {
        return;
    }
    
    [session startRunning];

    self.captureSession = session;
}

- (void)checkLocalPixelBufferForSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    size_t inputW = CVPixelBufferGetWidth( pixelBuffer);
    size_t inputH = CVPixelBufferGetHeight(pixelBuffer);
    
    size_t allocW = inputW;
    size_t allocH = inputH;
    
    BOOL realloc = NO;
    if (!(_resultBufferNormal)) {
        realloc = YES;
    } else {
        size_t resultW = CVPixelBufferGetWidth( _resultBufferNormal);
        size_t resultH = CVPixelBufferGetHeight(_resultBufferNormal);
        
        if (resultW != allocW || resultH != allocH) {
            realloc = YES;
        }
    }
    
    if (realloc) {
        CVPixelBufferRef pNormal = _resultBufferNormal;
        _resultBufferNormal = NULL;
        if (pNormal) {
            CFRelease(pNormal);
        }
        
        CFDictionaryRef empty; // empty value for attr value.
        CFMutableDictionaryRef attrs;
        // empty IOSurface properties dictionary
        empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
        
        CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, allocW, allocH, kCVPixelFormatType_32BGRA, attrs, &pNormal);
        if (err) {
            NSLog(@"Create local pixel buffer error:%d", err);
        } else {
            _resultBufferNormal = pNormal;
        }
        
        CFRelease(empty);
        CFRelease(attrs);
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    CFRetain(sampleBuffer);
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    _videoTrackSourceFormatDescription = formatDescription;
    [self checkLocalPixelBufferForSampleBuffer:sampleBuffer];
    
    CVPixelBufferRef resultNormal = _resultBufferNormal;
    //BOOL mirror = self.videoDeviceInput.device.position == AVCaptureDevicePositionFront;
    [self.vStab process:sampleBuffer outBuffer:resultNormal];
    
    //save
    @synchronized (self) {
        if ( isStartRecord ) {
            if (!isSessionStarted){
                [_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                
                isSessionStarted = YES;
            }
            //M_PI
            if ( _videoInput.readyForMoreMediaData )
            {
                CMSampleTimingInfo sampleTiming;
                CMSampleBufferGetSampleTimingInfo(sampleBuffer, 0, &sampleTiming);
                CMSampleBufferRef newSampleBuffer = NULL;
                CMVideoFormatDescriptionRef videoInfo = NULL;
                CMVideoFormatDescriptionCreateForImageBuffer(NULL, resultNormal, &videoInfo);
                CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, resultNormal, YES, NULL, NULL, videoInfo, &sampleTiming, &newSampleBuffer);
                BOOL success = [_videoInput appendSampleBuffer:newSampleBuffer];
                if ( ! success ) {
                    NSError *error = _assetWriter.error;
                    NSLog(@"appendSampleBuffer err:%@\n", error.localizedDescription);
                }
                
            }
            else
            {
                NSLog( @"input not ready for more media data, dropping buffer" );
            }
        }
    }
    CFRetain(resultNormal);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.recView displayPixelBuffer:resultNormal];
        CFRelease(resultNormal);
    });
    //TODO add audio support here
    
    CFRelease(sampleBuffer);
}

- (void)startRecord
{
    NSString *fileName = [NSString stringWithFormat:@"%lld.mov", (int64_t)(CACurrentMediaTime()*1e6)];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"cache"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:path]){
        [fileMgr createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSError *error;
    _outputUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", path, fileName]];
    _assetWriter = [[AVAssetWriter alloc] initWithURL:_outputUrl fileType:AVFileTypeQuickTimeMovie error:&error];
    if (error){
        NSLog(@"init AVAssetWriter err:%@\n", error.localizedDescription);
    }
    NSLog(@"writer status:%ld\n", (long)_assetWriter.status);
    
    
    if (!_videoCompressionSettings){
        NSLog(@"videoCompressionSettings is null\n");
        return ;
    }
    
    if ( [_assetWriter canApplyOutputSettings:_videoCompressionSettings forMediaType:AVMediaTypeVideo] )
    {
        
        _videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:_videoCompressionSettings sourceFormatHint:_videoTrackSourceFormatDescription];
        _videoInput.expectsMediaDataInRealTime = YES;
        _videoInput.transform = [self transformFromVideoBufferOrientationToOrientation:AVCaptureVideoOrientationPortrait withAutoMirroring:NO];
        if ( [_assetWriter canAddInput:_videoInput] )
        {
            [_assetWriter addInput:_videoInput];
        }
        else
        {
            NSLog(@"cann't apply output settings :%@\n", _assetWriter.error.localizedDescription);
            return ;
        }
        
        BOOL success = [_assetWriter startWriting];
        if ( ! success ) {
            NSLog(@"startWriting err:%@\n", _assetWriter.error);
            return ;
        }
        @synchronized (self) {
            isStartRecord = YES;
        }
    }
    else
    {
        NSLog(@"cann't apply output settings:%@\n", _assetWriter.error.localizedDescription);
    }
}

- (void)stopRecord:(void (^)(void))finish
{
    if(!_assetWriter) return ;
    if (_assetWriter.status != AVAssetWriterStatusWriting) return;
    @synchronized (self) {
        isStartRecord = NO;
    }
    [_videoInput markAsFinished];
    [_assetWriter finishWritingWithCompletionHandler:^{
        _assetWriter     = nil;
        isSessionStarted = NO;
        if (finish){
            finish();
        }
    }];
    
}

- (CGAffineTransform)transformFromVideoBufferOrientationToOrientation:(AVCaptureVideoOrientation)orientation withAutoMirroring:(BOOL)mirror
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // Calculate offsets from an arbitrary reference orientation (portrait)
    CGFloat orientationAngleOffset = angleOffsetFromPortraitOrientationToOrientation( orientation );
    CGFloat videoOrientationAngleOffset = angleOffsetFromPortraitOrientationToOrientation( _videoBufferOrientation );
    
    // Find the difference in angle between the desired orientation and the video orientation
    CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    transform = CGAffineTransformMakeRotation( angleOffset );
    
    if ( _videoDevice.position == AVCaptureDevicePositionFront )
    {
        if ( mirror ) {
            transform = CGAffineTransformScale( transform, -1, 1 );
        }
        else {
            if ( UIInterfaceOrientationIsPortrait( (UIInterfaceOrientation)orientation ) ) {
                transform = CGAffineTransformRotate( transform, M_PI );
            }
        }
    }
    
    return transform;
}

static CGFloat angleOffsetFromPortraitOrientationToOrientation(AVCaptureVideoOrientation orientation)
{
    CGFloat angle = 0.0;
    
    switch ( orientation )
    {
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        default:
            break;
    }
    
    return angle;
}

- (void)onVStab:(UISwitch *)sender
{
    self.vStab.enableStabi = sender.on;

}

#pragma mark -- Private camera utils
- (void)toggleCamera
{
    
    NSArray *inputs = self.captureSession.inputs;
    for (AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput =nil;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self findCaptureDevice:AVCaptureDevicePositionBack];
            else
                newCamera = [self findCaptureDevice:AVCaptureDevicePositionFront];
            NSError *error;
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:&error];
            if (error){
                NSLog(@"toggle camera err :%@", error.localizedDescription);
            }
            // beginConfiguration ensures that pending changes are not applied immediately
            [self.captureSession beginConfiguration];
        
            [self.captureSession removeInput:input];
            if ([self.captureSession canAddInput:newInput]){
                [self.captureSession addInput:newInput];
                _videoDeviceInput = newInput;
            }else{
                NSLog(@"add input error");
            }
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.captureSession commitConfiguration];
            break;
        }
    }
}

- (AVCaptureDevice *)findCaptureDevice:(AVCaptureDevicePosition)position
{
    AVCaptureDevice *device;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *d in devices) {
        if ([d position] == position) {
            device = d;
            break;
        }
    }
    return device;
    
}

- (void)flash
{
    NSError *err;
    if (_videoDeviceInput.device.position == AVCaptureDevicePositionBack){
        [_videoDevice lockForConfiguration:&err];
        if (err){
            NSLog(@"lock camera error:%@", err.localizedDescription);
            return ;
        }
        if ([_videoDevice hasFlash]) {
            
            if (_videoDevice.flashMode == AVCaptureFlashModeOff) {
                _videoDevice.flashMode = AVCaptureFlashModeOn;
                _videoDevice.torchMode = AVCaptureTorchModeOn;
                _recView.flashBtn.selected = YES;
            } else if (_videoDevice.flashMode == AVCaptureFlashModeOn) {
                _videoDevice.flashMode = AVCaptureFlashModeOff;
                _videoDevice.torchMode = AVCaptureTorchModeOff;
                _recView.flashBtn.selected = NO;
            }
            
        }
        [_videoDevice unlockForConfiguration];
        
    }else{
        _recView.flashBtn.selected = NO;
    }

}




@end
