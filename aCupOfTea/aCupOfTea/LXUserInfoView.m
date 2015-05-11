//
//  LXUserInfoView.m
//  aCupOfTea
//
//  Created by mwsn on 14-12-23.
//  Copyright (c) 2014年 Sangoly. All rights reserved.
//

#import "LXUserInfoView.h"
#import "LXDeviceManageControllerViewController.h"

@interface LXUserInfoView()
{
    NSString *leftText;
    NSString *rightText;
    NSInteger viewCategory; // 1 for label, 2 for button
    UIButton *rightButton;
}
@end

@implementation LXUserInfoView

- (id)initWithFrame:(CGRect)frame leftLabel:(NSString *)leftLabelText rightViewText:(NSString *)rightViewText labelOrButton:(NSInteger)category {
    self = [super initWithFrame:frame];
    if (self) {
        leftText = leftLabelText;
        rightText = rightViewText;
        viewCategory = category;
        self.alpha = 0.5;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Fix left label and right label/button position
    // First make the left label
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, rect.origin.y, 85.0f, rect.size.height)];
    leftLabel.text = leftText;
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.textColor = [UIColor yellowColor];
    [self addSubview:leftLabel];
    
    if (viewCategory == 1) {
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, rect.origin.y, rect.size.width-65.0f, rect.size.height)];
        rightLabel.text = rightText;
        rightLabel.textColor = [UIColor greenColor];
        rightLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:rightLabel];
    } else if (viewCategory == 2) {
        rightButton = [[UIButton alloc] initWithFrame:CGRectMake(65.0f, rect.origin.y, rect.size.width-65.0f, rect.size.height)];
        [rightButton setTitle:rightText forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
        rightButton.backgroundColor = [UIColor clearColor];
        [self addSubview:rightButton];
    }
}


@end
