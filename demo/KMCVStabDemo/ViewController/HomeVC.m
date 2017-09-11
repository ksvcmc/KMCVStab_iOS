//
//  HomeVC.m
//  
//
//  Created by 张俊 on 04/09/2017.
//
//

#import "HomeVC.h"
#import "AboutView.h"
#import "StreamerVC.h"
#import <MBProgressHUD.h>

@interface HomeVC ()

@property (weak, nonatomic) IBOutlet UISwitch *saveLocalSwitch;

@property (weak, nonatomic) IBOutlet UITextField *streamUrl;


@property (weak, nonatomic) IBOutlet UILabel *playUrl;
//
//@property (weak, nonatomic) IBOutlet UIButton *enterCameraBtn;
//
//
//@property (weak, nonatomic) IBOutlet UIButton *aboutBtn;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _streamUrl.text = @"rtmp://test.uplive.ks-cdn.com/live/kmc123";
    self.playUrl.text = [NSString stringWithFormat:@"rtmp://test.uplive.ks-cdn.com/live/%@", _streamUrl.text.lastPathComponent ];
    
    //rtmp://test.rtmplive.ks-cdn.com/live/kmc123
    self.saveLocalSwitch.on = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enterCamera:(UIButton *)sender
{
    if (_streamUrl.text.length <= 0){
        [self toast:@"请输入推流地址"];
        return ;
    }
    StreamerVC *vc = [[StreamerVC alloc] initWithUrl:_streamUrl.text isSave:_saveLocalSwitch.on];
    [self presentViewController:vc animated:YES completion:nil];

}

- (IBAction)showAbout:(id)sender
{
    [AboutView toast:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    self.playUrl.text = [NSString stringWithFormat:@"rtmp://test.uplive.ks-cdn.com/live/%@", _streamUrl.text.lastPathComponent ];
    [self.view endEditing:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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

@end
