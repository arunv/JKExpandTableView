//
//  JKParentTableViewCell.h
//  ExpandTableView
//
//  Created by Jack Kwok on 7/5/13.
//  Copyright (c) 2013 Jack Kwok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKExpandTableViewImageStyle.h"

@interface JKParentTableViewCell : UITableViewCell {
    UIImageView *iconImage;
    UILabel *label;
    UIImageView *selectionIndicatorImgView;
    NSInteger parentIndex;
}

@property (nonatomic,strong) UIImageView *iconImage;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UILabel *auxLabel;
@property (nonatomic,strong) UIImage *selectionIndicatorImg;
@property (nonatomic,strong) UIImageView *selectionIndicatorImgView;
@property (nonatomic,strong) UIImageView *expansionIndicatorImage;
@property (nonatomic) NSInteger parentIndex;
@property JKExpandTableViewCellImageStyle imageStyle;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setupDisplay;
- (void)rotateIconToExpanded;
- (void)rotateIconToCollapsed;
- (void)selectionIndicatorState:(BOOL) visible;
- (void)setCellForegroundColor:(UIColor *) foregroundColor;
- (void)setCellBackgroundColor:(UIColor *) backgroundColor;

@end
