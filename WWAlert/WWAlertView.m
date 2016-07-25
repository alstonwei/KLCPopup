//
//  WWAlertView.m
//  WWAlertTest
//
//  Created by Shouqiang Wei de Mac on 16/7/23.
//  Copyright © 2016年 shouqiangwei. All rights reserved.
//

#import "WWAlertView.h"
#import "WWAlertButton.h"
#import <objc/runtime.h>

#define WWAlertContentPadding 10

const char* WWAlertViewButtonActionBlockKey = "WWAlertViewButtonActionBlockKey";
@interface UIButton (Helper)

-(WWAlertViewButtonActionBlock)getWWAlertButtonActionBlock;
-(void)setWWAlertButtonActionBlock:(WWAlertViewButtonActionBlock)actionBlock;

@end

@implementation UIButton (Helper)


-(WWAlertViewButtonActionBlock)getWWAlertButtonActionBlock
{
    id ret = objc_getAssociatedObject(self, WWAlertViewButtonActionBlockKey);
    return ret;
}

-(void)setWWAlertButtonActionBlock:(WWAlertViewButtonActionBlock)actionBlock
{
    objc_setAssociatedObject(self, WWAlertViewButtonActionBlockKey, actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@interface WWAlertView()
{
    UIView* _realAlertView;
    NSString* _alertHeadIconName;
    WWAlertButton* _btn;
   
}

@property(nonatomic,strong)NSString* alertIconImageName;
@property(nonatomic,strong)UIView* alertContainerView;
@property(nonatomic,strong)UIView* alertContentView;
@property(nonatomic,strong)UIView* alertBottomContainerView;
@end

@implementation WWAlertView
@synthesize backgroundView = _backgroundView;
@synthesize containerView = _containerView;

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
    self.alertConerRedius = 10;
    self.alertViewHeightLimit = WWAlertViewHeightLimitMake(120, 1000);
    
}


+(WWAlertView*)alertWithTitle:(NSString*)title
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
    
    return [WWAlertView alertWithTitle:title attributes:titleattributes contentText:contentText attributes:attributes];
}

+(WWAlertView*)alertWithTitle:(NSString*)title
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
    alert.shouldDismissOnBackgroundTouch = NO;
    alert.maskType = WWPopupMaskTypeLightGray;
    return alert;
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
    alert.shouldDismissOnBackgroundTouch = NO;
    alert.maskType = WWPopupMaskTypeLightGray;
    [alert addCancelButtonWithTitle:@"取消" actionBlock:nil];
    [alert addConfirmButtonWithTitle:@"确定" actionBlock:nil];
    alert.autoDismissed = YES;
    [alert show];
    return alert;
}
-(void)addCancelButtonWithTitle:(NSString*)title
                    actionBlock:(WWAlertViewButtonActionBlock)actionBlock
{
    
    [self addButtonWithTitle:title configBlock:^(UIButton *btn, id otherInfo) {
        UIColor* topicColor = [UIColor colorWithRed:89/255.f green:89/255.f blue:89/255.f alpha:1];
        [btn setTitleColor:topicColor forState:UIControlStateNormal];
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = topicColor.CGColor;
        btn.layer.cornerRadius = 35/2.0f;
    } actionBlock:^BOOL(UIButton *btn, id otherInfo) {
        
        return YES;
    }];
}

;

-(void)addConfirmButtonWithTitle:(NSString*)title
                     actionBlock:(WWAlertViewButtonActionBlock)actionBlock;
{
    [self addButtonWithTitle:title configBlock:^(UIButton *btn, id otherInfo) {
        UIColor* topicColor = [UIColor colorWithRed:174/255.f green:40/255.f blue:46/255.f alpha:1];
        [btn setTitleColor:topicColor forState:UIControlStateNormal];
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = topicColor.CGColor;
        btn.layer.cornerRadius = 35/2.f;
    } actionBlock:^BOOL(UIButton *btn, id otherInfo) {
         return YES;
    }];
}

-(void)addButtonWithTitle:(NSString*)title
              configBlock:(WWAlertViewButtonConfigBlock)configBlock
              actionBlock:(WWAlertViewButtonActionBlock)actionBlock;
{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIColor* topicColor = [UIColor colorWithRed:174/255.f green:40/255.f blue:46/255.f alpha:1];
    [btn setTitleColor:topicColor forState:UIControlStateNormal];
    
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = topicColor.CGColor;
    btn.layer.cornerRadius = 35/2.f;
    
    if (configBlock) {
        configBlock(btn,nil);
    }
    if (actionBlock) {
        [btn setWWAlertButtonActionBlock:actionBlock];
    }
    
    [self.bottomButtons addObject:btn];
}

-(void)buttonClicked:(UIButton*)btn
{
    if (self.autoDismissed) {
        [self dismiss:YES];
    }
    
    WWAlertViewButtonActionBlock actionBlock = [btn getWWAlertButtonActionBlock];
    if (actionBlock) {
        BOOL dismiss =  actionBlock(btn,nil);
        if (dismiss) {
            [self dismiss:YES];
        }
    }
}

-(void)caculateSize
{
    CGRect realContentFrame = CGRectZero;
    CGFloat contentW = self.alertWidth- 2*WWAlertContentPadding;
    CGFloat containerY = 0; //alert 内部内容区域容器的y轴
    CGFloat iconW = 64;
    CGFloat alertContainerY = 1;//alert 容器的y轴
    
    [self.contentView addSubview:self.alertContainerView];
     containerY=alertContainerY;
    self.alertIconImageName = @"1";
    if (self.alertIconImageName) {
        //alertContainerY = iconW*0.5;
        CGFloat iconX = (self.alertWidth -iconW)/2.0F;
        UIImageView* v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.alertIconImageName]];
        [v setContentMode:UIViewContentModeScaleAspectFit];
        [v setFrame:CGRectMake(iconX, 0, iconW, iconW)];
        [v setBackgroundColor:[UIColor colorWithRed:222/255.f green:86/255.f blue:86/255.f alpha:1]];
        [v.layer setCornerRadius:iconW*0.5f];
        [v.layer setMasksToBounds:YES];
        [v setClipsToBounds:YES];
        self.alertIconImageView = v;
        [self.contentView addSubview:v];
        containerY = iconW*0.5;
        alertContainerY = containerY;
    }
    
    if (self.alertContentView) {//自定义内容
        
    }
    else//普通标准样式。
    {
        
        self.alertContentView = [[UIView alloc] init];
        [self.alertContentView setBackgroundColor:[UIColor whiteColor]];
        
        CGFloat y =  WWAlertContentPadding;
        //标题
        if (self.alertTitle) {
            CGSize limitSize = CGSizeMake(contentW,1000);
            CGSize size = [self.alertTitle boundingRectWithSize:limitSize options:NSStringDrawingUsesLineFragmentOrigin attributes:self.alertTitleAttributes context:nil].size;
            [self.alertContentView addSubview:self.alertTitleLable];
            CGRect titleFrame = {{WWAlertContentPadding, y},{MAX(size.width, contentW),size.height}};
            
            [self.alertTitleLable setText:self.alertTitle];
            [self.alertTitleLable setFrame:titleFrame];
            y+=size.height;
        }
        
        y+=WWAlertContentPadding;
        //内容
        if (self.alertContentText) {
            CGSize limitSize = CGSizeMake(contentW,1000);
            CGSize size = [self.alertContentText boundingRectWithSize:limitSize options:NSStringDrawingUsesLineFragmentOrigin attributes:self.alertContentTextAttributes context:nil].size;
            [self.alertContentView addSubview:self.alertContentTextLable];
            CGRect frame = {{WWAlertContentPadding, y},{MAX(size.width, contentW),size.height}};
            
            //[self.alertContentTextLable setBackgroundColor:[UIColor greenColor]];
            [self.alertContentTextLable setText:self.alertContentText];
            [self.alertContentTextLable setFrame:frame];
            y+=size.height;
        }
        
        y+=WWAlertContentPadding;
        
        self.alertContentView.frame= CGRectMake(0, containerY, self.alertWidth,y);
        containerY += y;
    }
    
    [self.alertContainerView addSubview:self.alertContentView];
    
    NSInteger count = self.bottomButtons.count;
    CGFloat alertBottomHeight = 0;
    CGFloat alertBottomY= 0;
    if (count>0) {//计算底部按钮的位置和高度，
        containerY+=WWAlertContentPadding;
        CGFloat bottomPadding = 20;
        NSInteger count = self.bottomButtons.count;
        
        CGFloat buttonW = (contentW -bottomPadding*(count-1))/count;
        CGFloat buttonH = 35;
        CGFloat x = 0;
        if (!self.alertBottomContainerView) {
            self.alertBottomContainerView = [[UIView alloc] init];
            [self.alertBottomContainerView setBackgroundColor:[UIColor clearColor]];
            [self.alertContainerView addSubview:self.alertBottomContainerView];
        }
        
        for (int i =0; i<count; i++) {
            UIButton* btn = self.bottomButtons[i];
            btn.frame = CGRectMake(x, 0, buttonW, buttonH);
            [self.alertBottomContainerView addSubview:btn];
            x += (buttonW+bottomPadding);
        }
        alertBottomHeight = buttonH;
        containerY += alertBottomHeight;
        containerY += 2*WWAlertContentPadding;
    }
    
    containerY = MAX(self.alertViewHeightLimit.limitMin,containerY);
    containerY = MIN(self.alertViewHeightLimit.limitMax,containerY);
   
    
    alertBottomY = containerY-2*WWAlertContentPadding - alertBottomHeight;
    self.alertBottomContainerView.frame = CGRectMake(WWAlertContentPadding, alertBottomY,contentW, alertBottomHeight);
    
    
    
    
    self.alertContainerView.layer.cornerRadius = self.alertConerRedius;
    self.alertContainerView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.alertContainerView.frame =CGRectMake(0, alertContainerY, self.alertWidth,containerY);
    
    alertContainerY += containerY;

    [self.alertContainerView setClipsToBounds:YES];
    self.contentView.frame= CGRectMake(0, 0, self.alertWidth,alertContainerY);
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    
    [self.contentView bringSubviewToFront:self.alertIconImageView];
    
}


- (UIView *)contentView
{
    if (!_realAlertView) {
        _realAlertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        [_realAlertView setBackgroundColor:[UIColor whiteColor]];
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


- (NSMutableArray *)bottomButtons
{
    if (!_bottomButtons) {
        _bottomButtons = [NSMutableArray array];
    }
    return _bottomButtons;
}

- (UIView *)alertContainerView
{
    if (!_alertContainerView) {
        _alertContainerView = [[UIView alloc] init];
        [_alertContainerView setBackgroundColor:[UIColor whiteColor]];
    }
    return _alertContainerView;
}


@end
