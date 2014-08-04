//
//  JKParentTableViewCell.m
//  ExpandTableView
//
//  Created by Jack Kwok on 7/5/13.
//  Copyright (c) 2013 Jack Kwok. All rights reserved.
//

#import "JKParentTableViewCell.h"
#import "JKExpandTableViewImageStyle.h"

@implementation JKParentTableViewCell

@synthesize label,iconImage,selectionIndicatorImgView,parentIndex,selectionIndicatorImg,expansionIndicatorImage,auxLabel, imageStyle;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier; {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [[self contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    if(!self) {
        return self;
    }
    self.contentView.backgroundColor = [UIColor clearColor];
    self.imageStyle = JKExpandTableViewCellImageStyleSquare;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.iconImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.iconImage setContentMode:UIViewContentModeCenter];
    [self.contentView addSubview:iconImage];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.textColor = [UIColor darkTextColor];
    label.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:label];
    
    self.auxLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    auxLabel.backgroundColor = [UIColor clearColor];
    auxLabel.opaque = NO;
    auxLabel.textColor = [UIColor darkTextColor];
    auxLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:auxLabel];
    
    self.selectionIndicatorImgView = [[UIImageView alloc] initWithFrame:CGRectZero];

    //[self.selectionIndicatorImgView setContentMode:UIViewContentModeCenter];
    [self.contentView addSubview:selectionIndicatorImgView];
    
    self.expansionIndicatorImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:expansionIndicatorImage];
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    [self setupDisplay];
}

- (void)setupDisplay {
    CGRect contentRect = [self bounds];
    CGFloat contentAreaWidth = self.contentView.bounds.size.width;
    CGFloat contentAreaHeight = self.contentView.bounds.size.height;
    CGFloat checkMarkHeight = 0.0;
    CGFloat checkMarkWidth = 0.0;
    CGFloat arrowWidth = 0.0;
    CGFloat arrowHeight = 0.0;
    CGFloat iconHeight = 27.0; //  set this according to icon
    CGFloat iconWidth = 27.0;
    if (self.iconImage.image) {
        iconWidth = MAX(iconHeight, self.iconImage.image.size.width);
        iconHeight = MAX(iconWidth, self.iconImage.image.size.height);
    }
    if (self.selectionIndicatorImgView.image) {
        checkMarkWidth = MIN(contentAreaWidth, self.selectionIndicatorImgView.image.size.width);
        checkMarkHeight = MIN(contentAreaHeight, self.selectionIndicatorImgView.image.size.height);
    }
    if (self.expansionIndicatorImage.image) {
        arrowWidth = MIN(contentAreaWidth, self.expansionIndicatorImage.image.size.width);
        arrowHeight = MIN(contentAreaWidth, self.expansionIndicatorImage.image.size.height);
    }
    
    CGFloat sidePadding = 6.0;
    CGFloat icon2LabelPadding = 6.0;
    CGFloat checkMarkPadding = 16.0;
    
    CGFloat auxLabelWidth = 50;
    
    [self.contentView setAutoresizesSubviews:YES];

    self.iconImage.frame = CGRectMake(sidePadding, (contentAreaHeight - iconHeight)/2, iconWidth, iconHeight);
    
    switch (self.imageStyle) {
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

    
    self.expansionIndicatorImage.frame = CGRectMake(contentAreaWidth - sidePadding - arrowWidth, (contentAreaHeight - arrowHeight)/2, arrowWidth, arrowHeight);
    CGFloat XOffset = iconWidth + sidePadding + icon2LabelPadding;
    
    CGFloat labelWidth = contentAreaWidth - XOffset - checkMarkWidth - checkMarkPadding - auxLabelWidth;
    self.auxLabel.frame = CGRectMake(vLeft(self.expansionIndicatorImage) - auxLabelWidth - icon2LabelPadding,  0, auxLabelWidth, contentAreaHeight);
    auxLabel.font = [self.label.font fontWithSize:12];
    
    self.label.frame = CGRectMake(XOffset, 0, labelWidth, contentAreaHeight);
    self.label.numberOfLines = 2;

    self.selectionIndicatorImgView.frame = CGRectMake(contentAreaWidth - checkMarkWidth - checkMarkPadding,
                                                 (contentRect.size.height/2)-(checkMarkHeight/2),
                                                 checkMarkWidth,
                                                 checkMarkHeight);
}

- (void)rotateIconToExpanded {
    [UIView beginAnimations:@"rotateDisclosure" context:nil];
    [UIView setAnimationDuration:0.2];
    expansionIndicatorImage.transform = CGAffineTransformMakeRotation(M_PI);
    [UIView commitAnimations];
}

- (void)rotateIconToCollapsed {
    [UIView beginAnimations:@"rotateDisclosure" context:nil];
    [UIView setAnimationDuration:0.2];
    expansionIndicatorImage.transform = CGAffineTransformMakeRotation(0);
    [UIView commitAnimations];
}

- (void)selectionIndicatorState:(BOOL) visible {
    //
    if (!self.selectionIndicatorImg) {
        self.selectionIndicatorImg = [UIImage imageNamed:@"checkmark"];
    }
    self.selectionIndicatorImgView.image = self.selectionIndicatorImg;  // probably better to init this elsewhere
    if (visible) {
        self.selectionIndicatorImgView.hidden = NO;
    } else {
        self.selectionIndicatorImgView.hidden = YES;
    }
}

- (void)setCellForegroundColor:(UIColor *) foregroundColor {
    self.label.textColor = foregroundColor;
}

- (void)setCellBackgroundColor:(UIColor *) backgroundColor {
    self.contentView.backgroundColor = backgroundColor;
}

@end
