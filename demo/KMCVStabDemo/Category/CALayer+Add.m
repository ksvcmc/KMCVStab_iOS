//
//  CALayer+Add.m
//  KMCVStab
//
//  Created by 张俊 on 05/09/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "CALayer+Add.h"
#import <UIKit/UIKit.h>
@implementation CALayer (Add)

- (void)setBorderColorWithUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

@end
