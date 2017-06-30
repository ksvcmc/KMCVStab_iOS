//
//  Helper.m
//  KMCVStab
//
//  Created by 张俊 on 27/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "Helper.h"
#import <AVFoundation/AVFoundation.h>

@implementation Helper

+(UIImage *)thumbnailForVideo:(NSURL *)path error:(NSError **)outError;
{
    if (!path /*|| path.length <= 0 */){
        NSLog(@"path invalid");
        return nil;
    }else{
        //TODO  check file exists
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
        if (!asset) return nil;
        
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        if(!imageGenerator) return nil;
        imageGenerator.appliesPreferredTrackTransform = YES;
        
        imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeProductionAperture;
        
        CGImageRef thumbnailImageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:nil error:outError];
        UIImage *imag = nil;
        if (!thumbnailImageRef){
            if(outError && !*outError)
                NSLog(@"Get Thumbnail at err:%@", (*outError).localizedDescription);
            return nil;
        }else{
            imag = [UIImage imageWithCGImage:thumbnailImageRef];
            CFRelease(thumbnailImageRef);
        }
        return imag;
    }
}

@end
