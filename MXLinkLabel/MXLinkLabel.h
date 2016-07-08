//
//  MXLinkLabel.h
//  MXLineLabel
//
//  Created by Meniny on 16/7/8.
//  Copyright © 2016年 Meniny. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MXLinkTapAction) (NSURL * _Nullable link);

IB_DESIGNABLE
@interface MXLinkLabel : UIView
@property (nonatomic, assign) IBInspectable CGFloat lineFragmentPadding;
@property (nonatomic, assign) IBInspectable NSInteger maximumNumberOfLines;
@property (nonatomic, copy) IBInspectable NSString * _Nullable markupText;
@property (nonatomic, copy) IBInspectable NSAttributedString * _Nullable attributedText;
@property (nonatomic, copy) MXLinkTapAction _Nullable linkTapHandler;
@end
