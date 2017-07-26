//
//  VideoList.m
//  KMCVStab
//
//  Created by 张俊 on 26/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "VideoList.h"
#import "ViewItemCell.h"

@interface VideoList ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong)NSString *identifier;

@end

@implementation VideoList


- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        [self initSubViews ];
    }
    return self;
}

- (void)initSubViews
{
    [self addSubview:self.collectionView];
    [self.collectionView registerClass:[ViewItemCell class] forCellWithReuseIdentifier:self.identifier];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(100, 80);
        //layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        //layout.headerReferenceSize = CGSizeMake(75, 100);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        _collectionView.scrollsToTop = YES;
        
    }
    return _collectionView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ViewItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.identifier forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    if (cell.model.checked){
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionTop];
        cell.model.checked = NO;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.block){
        self.block(CtlType_Switch, [self.dataArray objectAtIndex:indexPath.row]);
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray){
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

@end

