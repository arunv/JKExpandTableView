//
//  JKSubTableViewCellCell.m
//  ExpandTableView
//
//  Created by Jack Kwok on 7/5/13.
//  Copyright (c) 2013 Jack Kwok. All rights reserved.
//

#import "JKSubTableViewCellCell.h"
#import "JKExpandTableViewImageStyle.h"

@implementation JKSubTableViewCellCell
@synthesize titleLabel, iconImage, selectionIndicatorImg, auxLabel, imageStyle;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [[self contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    if(!self)
        return self;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.iconImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageStyle = JKExpandTableViewCellImageStyleSquare;
    [self.contentView addSubview:iconImage];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.opaque = NO;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:titleLabel];
    
    self.auxLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    auxLabel.backgroundColor = [UIColor clearColor];
    auxLabel.opaque = NO;
    auxLabel.textColor = [UIColor darkTextColor];
    auxLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:auxLabel];
    
    self.selectionIndicatorImg = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:selectionIndicatorImg];
    
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    [self setupDisplay];
}

- (void) setupDisplay {
    CGRect contentRect = [self bounds];
    CGFloat contentAreaWidth = self.contentView.bounds.size.width;
    CGFloat contentAreaHeight = self.contentView.bounds.size.height;
    CGFloat checkMarkHeight = 0.0;
    CGFloat checkMarkWidth = 0.0;
    CGFloat iconHeight = 27.0; //  set this according to icon
    CGFloat iconWidth = 27.0;
    
    self.iconImage.contentMode = UIViewContentModeScaleToFill;
    if (self.iconImage.image) {
        if (self.iconImage.image.size.width < iconWidth || self.iconImage.image.size.height < iconHeight) {
            self.iconImage.contentMode = UIViewContentModeCenter;
        }
    }
    if (self.selectionIndicatorImg.image) {
        checkMarkWidth = MIN(contentAreaWidth, self.selectionIndicatorImg.image.size.width);
        checkMarkHeight = MIN(contentAreaHeight, self.selectionIndicatorImg.image.size.height);
    }
    
    CGFloat sidePadding = 22.0;
    CGFloat icon2LabelPadding = 6.0;
    CGFloat checkMarkPadding = 16.0;
    CGFloat auxLabelWidth = 60.0;
    [self.contentView setAutoresizesSubviews:YES];
    
    self.iconImage.frame = CGRectMake(sidePadding, (contentAreaHeight - iconHeight)/2, iconWidth, iconHeight);
    
    JKExpandTableViewCellImageStyle _imageStyle = self.imageStyle;
    switch (_imageStyle) {
        case JKExpandTableViewCellImageStyleSquare:
            self.iconImage.layer.cornerRadius = 0;
            self.iconImage.layer.masksToBounds = NO;
            break;
        case JKExpandTableViewCellImageStyleCircle:
            self.iconImage.layer.cornerRadius = self.iconImage.frame.size.height / 2.0;
            self.iconImage.layer.masksToBounds = YES;
            break;
        case JKExpandTableViewCellImageStyleRoundedRect:
            self.iconImage.layer.cornerRadius = self.iconImage.frame.size.height * 0.2;
            self.iconImage.layer.masksToBounds = YES;
            break;
        default:
            break;
    }
    
    
    CGFloat XOffset = iconWidth + sidePadding + icon2LabelPadding;
    
    CGFloat labelWidth = contentAreaWidth - XOffset - auxLabelWidth;
    self.titleLabel.frame = CGRectMake(XOffset, 0, labelWidth, contentAreaHeight);
    self.auxLabel.frame = CGRectMake(contentAreaWidth - sidePadding - auxLabelWidth, 0, auxLabelWidth, contentAreaHeight);
    self.auxLabel.numberOfLines = 2;

    //self.titleLabel.backgroundColor = [UIColor purpleColor];
    //self.selectionIndicatorImg.backgroundColor = [UIColor yellowColor];
    
    self.selectionIndicatorImg.frame = CGRectMake(contentAreaWidth - checkMarkWidth - checkMarkPadding,
                                                      (contentRect.size.height/2)-(checkMarkHeight/2),
                                                      checkMarkWidth,
                                                      checkMarkHeight);
    
    
}

- (void)setCellForegroundColor:(UIColor *) foregroundColor {
    titleLabel.textColor = foregroundColor;
    auxLabel.textColor =foregroundColor;
}

- (void)setCellBackgroundColor:(UIColor *) backgroundColor {
    self.contentView.backgroundColor = backgroundColor;
}


@end
