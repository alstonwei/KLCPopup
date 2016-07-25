//
//  WWAlertView.h
//  WWAlertTest
//
//  Created by Shouqiang Wei de Mac on 16/7/23.
//  Copyright © 2016年 shouqiangwei. All rights reserved.
//
/* usage

 _alertView = [WWAlertView showAlertWithTitle:@"这是一个提示测试。" ];
 
 _alertView = [WWAlertView showAlertWithTitle:@"这是一个提示测试这是一个提示测试这是一个提示测试这是一个提示测试" contentText:@"这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,"];
 

_alertView = [WWAlertView alertWithTitle:@"test" contentText:@"内容违法！！"];
[_alertView addButtonWithTitle:@"知道了" configBlock:^(UIButton *btn, id otherInfo) {
    
} actionBlock:^BOOL(UIButton *btn, id otherInfo) {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"test" message:@"msg" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
    return YES;
}];
[_alertView show];

*/

#import <UIKit/UIKit.h>
#import "WWPopup.h"

struct WWAlertViewHeightLimit {
    CGFloat limitMin;
    CGFloat limitMax;
};

typedef void(^WWAlertViewButtonConfigBlock)(UIButton* btn,id otherInfo);
/*!
 *  @brief alert 按钮点击事件回调block
 *
 *  @param btn
 *  @param otherInfo
 *
 *  @return 是否dismiss
 */
typedef BOOL(^WWAlertViewButtonActionBlock)(UIButton* btn,id otherInfo);

typedef struct WWAlertViewHeightLimit WWAlertViewHeightLimit;
CG_INLINE WWAlertViewHeightLimit
WWAlertViewHeightLimitMake(CGFloat min, CGFloat max)
{
    WWAlertViewHeightLimit limit; limit.limitMin = min; limit.limitMax = max; return limit;
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
@property(nonatomic,assign)CGFloat alertConerRedius;
@property(nonatomic)WWAlertViewHeightLimit alertViewHeightLimit;
@property(nonatomic,assign)WWAlertViewType alertType;

/*标题*/
@property(nonatomic,copy)NSString* alertTitle;
@property(nonatomic,strong) NSDictionary* alertTitleAttributes;
@property(nonatomic,strong) UILabel* alertTitleLable;
/*内容*/
@property(nonatomic,copy)NSString* alertContentText;
@property(nonatomic,strong) NSDictionary* alertContentTextAttributes;
@property(nonatomic,strong) UILabel* alertContentTextLable;
@property(nonatomic,strong)NSMutableArray* bottomButtons;

@property(nonatomic,strong)UIImageView* alertIconImageView;

@property(nonatomic,assign)BOOL autoDismissed;

+(WWAlertView*)alertWithTitle:(NSString*)title
                  contentText:(NSString*)contentText;

+(WWAlertView*)alertWithTitle:(NSString*)title
                   attributes:(nullable NSDictionary<NSString *,id> *)attributes
                  contentText:(NSString*)contentText
                   attributes:(nullable NSDictionary<NSString *,id> *)contentTextAttributes;

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

-(void)addCancelButtonWithTitle:(NSString*)title
             actionBlock:(WWAlertViewButtonActionBlock)actionBlock;

-(void)addConfirmButtonWithTitle:(NSString*)title
                     actionBlock:(WWAlertViewButtonActionBlock)actionBlock;
-(void)addButtonWithTitle:(NSString*)title
              configBlock:(WWAlertViewButtonConfigBlock)configBlock
              actionBlock:(WWAlertViewButtonActionBlock)actionBlock;


@end
