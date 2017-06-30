//
//  VideoListModel.h
//  KMCVStab
//
//  Created by 张俊 on 26/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoListModel : NSObject

@property(nonatomic, strong)NSURL   *url;

@property(nonatomic, strong)UIImage *thumb;

//选中
@property(nonatomic, assign)BOOL    checked;

@end
  
