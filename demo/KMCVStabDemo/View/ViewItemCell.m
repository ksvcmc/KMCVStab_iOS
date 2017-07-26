//
//  ViewItemCell.m
//  KMCVStab
//
//  Created by 张俊 on 26/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "ViewItemCell.h"

@interface ViewItemCell ()

@property (nonatomic, strong)UIImageView *thumbView;

@end

@implementation ViewItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}


- (void)initSubViews
{
    [self addSubview:self.thumbView];
    
    [self.thumbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.height.mas_equalTo(80);
    }];
}



- (UIImageView *)thumbView
{
    if (!_thumbView){
        _thumbView = [[UIImageView alloc] init];
        _thumbView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbView.clipsToBounds = YES;
    }
    return _thumbView;

}

- (void)setModel:(VideoListModel *)model
{
    if (model && model.thumb){
        _model = model;
        _thumbView.image = model.thumb;
//        if(model.checked){
//            [self setSelected:YES];
//        }
    }
}

- (void)setSelected:(BOOL)selected{
    
    [super setSelected:selected];
    
    if (selected) {
        [self onSelected];
    }else{
        [self onUnselected];
    }
}

- (void)onSelected
{
    self.thumbView.layer.borderColor = [UIColor colorWithRed:0.345 green:0.886 blue:0.761 alpha:1.00].CGColor;
    self.thumbView.layer.borderWidth = 2;
}

- (void)onUnselected
{
    
    self.thumbView.layer.borderColor = [[UIColor clearColor]CGColor];
    self.thumbView.layer.borderWidth = 0;
}
@end
