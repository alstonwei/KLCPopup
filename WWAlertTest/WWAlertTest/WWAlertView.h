//
//  WWAlertView.h
//  WWAlertTest
//
//  Created by Shouqiang Wei de Mac on 16/7/23.
//  Copyright © 2016年 shouqiangwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWPopup.h"

struct WWAlertViewHeightLimit {
    CGFloat limitMin;
    CGFloat limitMax;
};

typedef struct WWAlertViewHeightLimit WWAlertViewHeightLimit;
CG_INLINE WWAlertViewHeightLimit
WWAlertViewHeightLimitMake(CGFloat min, CGFloat max)
{
    WWAlertViewHeightLimit limit; limit.limitMin = min; limit.limitMax = min; return limit;
};


typedef NS_ENUM(NSInteger,WWAlertViewType)
{
    WWAlertViewOnlyTitle=0,
    WWAlertViewOnlyText,
    WWAlertViewTitleAndText,
    WWAlertViewOnlyTitleCustomView,
};
@interface WWAlertView : WWPopup


@property(nonatomic,assign)CGFloat alertWidth;
@property(nonatomic)WWAlertViewHeightLimit alertViewHeightLimit;
@property(nonatomic,assign)WWAlertViewType alertType;

+(WWAlertView*)showAlert;

+(WWAlertView*)showAlertWithTitle:(NSString*)title;

+(WWAlertView*)showAlertWithTitle:(NSString*)title
                      contentText:(NSString*)contentText;

+(WWAlertView*)showAlertWithTitle:(NSString*)title
                       attributes:(nullable NSDictionary<NSString *,id> *)attributes;

+(WWAlertView*)showAlertWithTitle:(NSString*)title
                       attributes:(nullable NSDictionary<NSString *,id> *)attributes
                      contentText:(NSString*)contentText
                       attributes:(nullable NSDictionary<NSString *,id> *)contentTextAttributes;

@end
