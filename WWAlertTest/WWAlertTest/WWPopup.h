//
//  WWPopup.h
//  WWAlertTest
//
//  Created by Shouqiang Wei de Mac on 16/7/23.
//  Copyright © 2016年 shouqiangwei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WWPopupShowType) {
    WWPopupShowTypeNone = 0,
    WWPopupShowTypeFadeIn,
    WWPopupShowTypeGrowIn,
    WWPopupShowTypeShrinkIn,
    WWPopupShowTypeSlideInFromTop,
    WWPopupShowTypeSlideInFromBottom,
    WWPopupShowTypeSlideInFromLeft,
    WWPopupShowTypeSlideInFromRight,
    WWPopupShowTypeBounceIn,
    WWPopupShowTypeBounceInFromTop,
    WWPopupShowTypeBounceInFromBottom,
    WWPopupShowTypeBounceInFromLeft,
    WWPopupShowTypeBounceInFromRight,
    WWPopupShowTypeResize,
};

// WWPopupDismissType: Controls how the popup will be dismissed.
typedef NS_ENUM(NSInteger, WWPopupDismissType) {
    WWPopupDismissTypeNone = 0,
    WWPopupDismissTypeFadeOut,
    WWPopupDismissTypeGrowOut,
    WWPopupDismissTypeShrinkOut,
    WWPopupDismissTypeSlideOutToTop,
    WWPopupDismissTypeSlideOutToBottom,
    WWPopupDismissTypeSlideOutToLeft,
    WWPopupDismissTypeSlideOutToRight,
    WWPopupDismissTypeBounceOut,
    WWPopupDismissTypeBounceOutToTop,
    WWPopupDismissTypeBounceOutToBottom,
    WWPopupDismissTypeBounceOutToLeft,
    WWPopupDismissTypeBounceOutToRight,
};



// WWPopupHorizontalLayout: Controls where the popup will come to rest horizontally.
typedef NS_ENUM(NSInteger, WWPopupHorizontalLayout) {
    WWPopupHorizontalLayoutCustom = 0,
    WWPopupHorizontalLayoutLeft,
    WWPopupHorizontalLayoutLeftOfCenter,
    WWPopupHorizontalLayoutCenter,
    WWPopupHorizontalLayoutRightOfCenter,
    WWPopupHorizontalLayoutRight,
};

// WWPopupVerticalLayout: Controls where the popup will come to rest vertically.
typedef NS_ENUM(NSInteger, WWPopupVerticalLayout) {
    WWPopupVerticalLayoutCustom = 0,
    WWPopupVerticalLayoutTop,
    WWPopupVerticalLayoutAboveCenter,
    WWPopupVerticalLayoutCenter,
    WWPopupVerticalLayoutBelowCenter,
    WWPopupVerticalLayoutBottom,
};

// WWPopupMaskType
typedef NS_ENUM(NSInteger, WWPopupMaskType) {
    WWPopupMaskTypeNone = 0, // Allow interaction with underlying views.
    WWPopupMaskTypeClear, // Don't allow interaction with underlying views.
    WWPopupMaskTypeDimmed, // Don't allow interaction with underlying views, dim background.
};

// WWPopupLayout structure and maker functions
struct WWPopupLayout {
    WWPopupHorizontalLayout horizontal;
    WWPopupVerticalLayout vertical;
};
typedef struct WWPopupLayout WWPopupLayout;

extern WWPopupLayout WWPopupLayoutMake(WWPopupHorizontalLayout horizontal, WWPopupVerticalLayout vertical);

extern const WWPopupLayout WWPopupLayoutCenter;



@interface WWPopup : UIView

// This is the view that you want to appear in Popup.
// - Must provide contentView before or in willStartShowing.
// - Must set desired size of contentView before or in willStartShowing.
@property (nonatomic, strong) UIView* contentView;

// Animation transition for presenting contentView. default = shrink in
@property (nonatomic, assign) WWPopupShowType showType;

// Animation transition for dismissing contentView. default = shrink out
@property (nonatomic, assign) WWPopupDismissType dismissType;

// Mask prevents background touches from passing to underlying views. default = dimmed.
@property (nonatomic, assign) WWPopupMaskType maskType;

// Overrides alpha value for dimmed background mask. default = 0.5
@property (nonatomic, assign) CGFloat dimmedMaskAlpha;

// If YES, then popup will get dismissed when background is touched. default = YES.
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;

// If YES, then popup will get dismissed when content view is touched. default = NO.
@property (nonatomic, assign) BOOL shouldDismissOnContentTouch;

// Block gets called after show animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^didFinishShowingCompletion)();

// Block gets called when dismiss animation starts. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^willStartDismissingCompletion)();

// Block gets called after dismiss animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^didFinishDismissingCompletion)();

// Convenience method for creating popup with default values (mimics UIAlertView).
+ (WWPopup*)popupWithContentView:(UIView*)contentView;

// Convenience method for creating popup with custom values.
+ (WWPopup*)popupWithContentView:(UIView*)contentView
                         showType:(WWPopupShowType)showType
                      dismissType:(WWPopupDismissType)dismissType
                         maskType:(WWPopupMaskType)maskType
         dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
            dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch;

// Dismisses all the popups in the app. Use as a fail-safe for cleaning up.
+ (void)dismissAllPopups;

// Show popup with center layout. Animation determined by showType.
- (void)show;

// Show with specified layout.
- (void)showWithLayout:(WWPopupLayout)layout;

// Show and then dismiss after duration. 0.0 or less will be considered infinity.
- (void)showWithDuration:(NSTimeInterval)duration;

// Show with layout and dismiss after duration.
- (void)showWithLayout:(WWPopupLayout)layout duration:(NSTimeInterval)duration;

// Show centered at point in view's coordinate system. If view is nil use screen base coordinates.
- (void)showAtCenter:(CGPoint)center inView:(UIView*)view;

// Show centered at point in view's coordinate system, then dismiss after duration.
- (void)showAtCenter:(CGPoint)center inView:(UIView *)view withDuration:(NSTimeInterval)duration;

// Dismiss popup. Uses dismissType if animated is YES.
- (void)dismiss:(BOOL)animated;

- (void)layoutContentView;

#pragma mark Subclassing
@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, assign, readonly) BOOL isBeingShown;
@property (nonatomic, assign, readonly) BOOL isShowing;
@property (nonatomic, assign, readonly) BOOL isBeingDismissed;

- (void)willStartShowing;
- (void)didFinishShowing;
- (void)willStartDismissing;
- (void)didFinishDismissing;

@end


#pragma mark - UIView Category
@interface UIView(WWPopup)
- (void)forEachPopupDoBlock:(void (^)(WWPopup* popup))block;
- (void)dismissPresentingPopup;
@end