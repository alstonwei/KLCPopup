//
//  WWAlertView.m
//  WWAlertTest
//
//  Created by Shouqiang Wei de Mac on 16/7/23.
//  Copyright © 2016年 shouqiangwei. All rights reserved.
//

#import "WWAlertView.h"
#import "WWAlertButton.h"

#define WWAlertContentPadding 10
@interface WWAlertView()
{
    UIView* _realAlertView;
    NSString* _alertHeadIconName;
    WWAlertButton* _btn;
   
}
/*标题*/
@property(nonatomic,copy)NSString* alertTitle;
@property(nonatomic,strong) NSDictionary* alertTitleAttributes;
@property(nonatomic,strong) UILabel* alertTitleLable;
/*内容*/
@property(nonatomic,copy)NSString* alertContentText;
@property(nonatomic,strong) NSDictionary* alertContentTextAttributes;
@property(nonatomic,strong) UILabel* alertContentTextLable;

@end

@implementation WWAlertView

- (instancetype)init
{
    if (self = [super init]) {
        [self config];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self config];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
         [self config];
    }
    return self;
}

-(void)config
{
    self.alertWidth = 250;
    self.alertViewHeightLimit = WWAlertViewHeightLimitMake(200, 1000);
    
}

+(WWAlertView*)showAlert
{
    WWAlertView* alert = [[WWAlertView alloc] init];
    [alert show];
    return alert;
}

+(WWAlertView*)showAlertWithTitle:(NSString*)title;
{
    return [WWAlertView showAlertWithTitle:title contentText:nil];
}
+(WWAlertView*)showAlertWithTitle:(NSString*)title
                      contentText:(NSString*)contentText
{
    NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    titleParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary* titleattributes = @{
                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:17],
                                 NSParagraphStyleAttributeName: titleParagraphStyle
                                 };
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary* attributes = @{
                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:12],
                                 NSParagraphStyleAttributeName: paragraphStyle
                                 };
    
    return [WWAlertView showAlertWithTitle:title attributes:titleattributes contentText:contentText attributes:attributes];
}
　　
+(WWAlertView*)showAlertWithTitle:(NSString*)title attributes:(nullable NSDictionary<NSString *,id> *)attributes;
{
    return [self showAlertWithTitle:title attributes:attributes contentText:nil attributes:nil];
}


+(WWAlertView*)showAlertWithTitle:(NSString*)title
                       attributes:(nullable NSDictionary<NSString *,id> *)attributes
                            contentText:(NSString*)contentText
                       attributes:(nullable NSDictionary<NSString *,id> *)contentTextAttributes;
{
    WWAlertView* alert = [[WWAlertView alloc] init];
    alert.alertTitle = title;
    alert.alertTitleAttributes = attributes;
    if (contentText) {
        alert.alertContentText = contentText;
        alert.alertContentTextAttributes = contentTextAttributes;
    }
    [alert show];
    return alert;
}

-(void)caculateSize
{
    CGRect realContentFrame = CGRectZero;
    CGFloat contentW = self.alertWidth- 2*WWAlertContentPadding;
    CGFloat y = WWAlertContentPadding;
    if (self.alertTitle) {
        CGSize limitSize = CGSizeMake(contentW,1000);
        CGSize size = [self.alertTitle boundingRectWithSize:limitSize options:NSStringDrawingUsesLineFragmentOrigin attributes:self.alertTitleAttributes context:nil].size;
        [self.contentView addSubview:self.alertTitleLable];
        CGRect titleFrame = {{WWAlertContentPadding, y},{MAX(size.width, contentW),size.height}};

        [self.alertTitleLable setBackgroundColor:[UIColor greenColor]];
        [self.alertTitleLable setText:self.alertTitle];
        [self.alertTitleLable setFrame:titleFrame];
        y+=size.height;
    }
    
    y+=WWAlertContentPadding;
    
    if (self.alertContentText) {
        CGSize limitSize = CGSizeMake(contentW,1000);
        CGSize size = [self.alertContentText boundingRectWithSize:limitSize options:NSStringDrawingUsesLineFragmentOrigin attributes:self.alertContentTextAttributes context:nil].size;
        [self.contentView addSubview:self.alertContentTextLable];
        CGRect frame = {{WWAlertContentPadding, y},{MAX(size.width, contentW),size.height}};
        
        [self.alertContentTextLable setBackgroundColor:[UIColor greenColor]];
        [self.alertContentTextLable setText:self.alertContentText];
        [self.alertContentTextLable setFrame:frame];
        y+=size.height;
    }
    
    y+=WWAlertContentPadding;
    
    
    y = MAX(self.alertViewHeightLimit.limitMin,y);
    y = MIN(self.alertViewHeightLimit.limitMax,y);
    self.contentView.frame= CGRectMake(0, 0, self.alertWidth,y);
}


- (UIView *)contentView
{
    if (!_realAlertView) {
        _realAlertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        [_realAlertView setBackgroundColor:[UIColor redColor]];
        [_realAlertView setClipsToBounds:YES];
    }
    return _realAlertView;
}

#pragma mark inherit
-(void)show
{
    [self caculateSize];
    [super show];
}

- (void)layoutContentView
{
    [super layoutContentView];
    
}

#pragma gettar settar
- (UILabel *)alertContentTextLable
{
    if (!_alertContentTextLable) {
        _alertContentTextLable = [[UILabel alloc] init];
        _alertContentTextLable.numberOfLines = 0 ;
        [_alertContentTextLable setFont:[UIFont systemFontOfSize:12]];
    }
    
    return _alertContentTextLable;
}

- (UILabel *)alertTitleLable
{
    if (!_alertTitleLable) {
        _alertTitleLable = [[UILabel alloc] init];
        _alertTitleLable.textAlignment = NSTextAlignmentCenter;
        _alertTitleLable.numberOfLines = 0 ;
        [_alertContentTextLable setTextColor:[UIColor blackColor]];
        [_alertTitleLable setFont:[UIFont boldSystemFontOfSize:17]];
    }
    return _alertTitleLable;
}

@end
