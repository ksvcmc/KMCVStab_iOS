//
//  VideoList.h
//  KMCVStab
//
//  Created by 张俊 on 26/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoListModel.h"

@interface VideoList : UIView

- (instancetype)initWithIdentifier:(NSString *)identifier;

@property (nonatomic, strong)UICollectionView *collectionView;

//for external init
@property (nonatomic, strong)NSMutableArray *dataArray;

@property(nonatomic, copy) void (^block)(KMCPlayCtlType type, VideoListModel *model);


@end
