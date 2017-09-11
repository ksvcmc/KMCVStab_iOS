//
//  AboutView.m
//  KMCVStab
//
//  Created by 张俊 on 05/09/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "AboutView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface AboutView()

@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation AboutView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0];
}

+ (void)toast:(UIViewController *)controller
{
    AboutView *alert = [[NSBundle mainBundle]loadNibNamed:@"AboutView" owner:nil options:nil][0];
    
    alert.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    [controller.view addSubview:alert];
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
    
    alert.bgView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.2,0.2);
    alert.bgView.alpha = 0.1;

    [UIView animateWithDuration:0.3 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
        alert.bgView.transform = transform;
        alert.bgView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    
}

- (IBAction)onClose:(UIButton *)sender
{

    [self removeFromSuperview];
}



@end
