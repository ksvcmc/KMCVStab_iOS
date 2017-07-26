//
//  Helper.h
//  KMCVStab
//
//  Created by 张俊 on 27/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject

+(UIImage *)thumbnailForVideo:(NSURL *)path error:(NSError **)outError;

@end
