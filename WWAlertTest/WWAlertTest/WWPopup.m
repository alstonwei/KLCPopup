//
//  WWPopup.m
//  WWAlertTest
//
//  Created by Shouqiang Wei de Mac on 16/7/23.
//  Copyright © 2016年 shouqiangwei. All rights reserved.
//

#import "WWPopup.h"


static NSInteger const kAnimationOptionCurveIOS7 = (7 << 16);

WWPopupLayout WWPopupLayoutMake(WWPopupHorizontalLayout horizontal, WWPopupVerticalLayout vertical)
{
    WWPopupLayout layout;
    layout.horizontal = horizontal;
    layout.vertical = vertical;
    return layout;
}

const WWPopupLayout WWPopupLayoutCenter = { WWPopupHorizontalLayoutCenter, WWPopupVerticalLayoutCenter };


@interface NSValue (WWPopupLayout)
+ (NSValue*)valueWithWWPopupLayout:(WWPopupLayout)layout;
- (WWPopupLayout)WWPopupLayoutValue;
@end


@interface WWPopup () {
    // views
    UIView* _backgroundView;
    UIView* _containerView;
    
    // state flags
    BOOL _isBeingShown;
    BOOL _isShowing;
    BOOL _isBeingDismissed;
    WWPopupLayout _currentLayout;
}

- (void)updateForInterfaceOrientation;
- (void)didChangeStatusBarOrientation:(NSNotification*)notification;

// Used for calling dismiss:YES from selector because you can't pass primitives, thanks objc
- (void)dismiss;

@end


@implementation WWPopup

@synthesize backgroundView = _backgroundView;
@synthesize containerView = _containerView;
@synthesize isBeingShown = _isBeingShown;
@synthesize isShowing = _isShowing;
@synthesize isBeingDismissed = _isBeingDismissed;


- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // stop listening to notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (id)init {
    return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        
        self.shouldDismissOnBackgroundTouch = YES;
        self.shouldDismissOnContentTouch = NO;
        
        self.showType = WWPopupShowTypeShrinkIn;
        self.dismissType = WWPopupDismissTypeShrinkOut;
        self.maskType = WWPopupMaskTypeDimmed;
        self.dimmedMaskAlpha = 0.5;
        
        _isBeingShown = NO;
        _isShowing = NO;
        _isBeingDismissed = NO;
        
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor clearColor];
        _backgroundView.userInteractionEnabled = NO;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.frame = self.bounds;
        
        _containerView = [[UIView alloc] init];
        _containerView.autoresizesSubviews = NO;
        _containerView.userInteractionEnabled = YES;
        _containerView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_backgroundView];
        [self addSubview:_containerView];
        
        // register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeStatusBarOrientation:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
    }
    return self;
}


#pragma mark - UIView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView* hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        
        // Try to dismiss if backgroundTouch flag set.
        if (_shouldDismissOnBackgroundTouch) {
            [self dismiss:YES];
        }
        
        // If no mask, then return nil so touch passes through to underlying views.
        if (_maskType == WWPopupMaskTypeNone) {
            return nil;
        } else {
            return hitView;
        }
        
    } else {
        
        // If view is within containerView and contentTouch flag set, then try to hide.
        if ([hitView isDescendantOfView:_containerView]) {
            if (_shouldDismissOnContentTouch) {
                [self dismiss:YES];
            }
        }
        return hitView;
    }
}


#pragma mark - Class Public

+ (WWPopup*)popupWithContentView:(UIView*)contentView
{
    WWPopup* popup = [[[self class] alloc] init];
    popup.contentView = contentView;
    return popup;
}


+ (WWPopup*)popupWithContentView:(UIView*)contentView
                         showType:(WWPopupShowType)showType
                      dismissType:(WWPopupDismissType)dismissType
                         maskType:(WWPopupMaskType)maskType
         dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
            dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch
{
    WWPopup* popup = [[[self class] alloc] init];
    popup.contentView = contentView;
    popup.showType = showType;
    popup.dismissType = dismissType;
    popup.maskType = maskType;
    popup.shouldDismissOnBackgroundTouch = shouldDismissOnBackgroundTouch;
    popup.shouldDismissOnContentTouch = shouldDismissOnContentTouch;
    return popup;
}


+ (void)dismissAllPopups {
    NSArray* windows = [[UIApplication sharedApplication] windows];
    for (UIWindow* window in windows) {
        [window forEachPopupDoBlock:^(WWPopup *popup) {
            [popup dismiss:NO];
        }];
    }
}


#pragma mark - Public

- (void)show {
    [self showWithLayout:WWPopupLayoutCenter];
}


- (void)showWithLayout:(WWPopupLayout)layout {
    [self showWithLayout:layout duration:0.0];
}


- (void)showWithDuration:(NSTimeInterval)duration {
    [self showWithLayout:WWPopupLayoutCenter duration:duration];
}


- (void)showWithLayout:(WWPopupLayout)layout duration:(NSTimeInterval)duration {
    NSDictionary* parameters = @{@"layout" : [NSValue valueWithWWPopupLayout:layout],
                                 @"duration" : @(duration)};
    _currentLayout = layout;
    [self showWithParameters:parameters];
}


- (void)showAtCenter:(CGPoint)center inView:(UIView*)view {
    [self showAtCenter:center inView:view withDuration:0.0];
}


- (void)showAtCenter:(CGPoint)center inView:(UIView *)view withDuration:(NSTimeInterval)duration {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSValue valueWithCGPoint:center] forKey:@"center"];
    [parameters setValue:@(duration) forKey:@"duration"];
    [parameters setValue:view forKey:@"view"];
    [self showWithParameters:[NSDictionary dictionaryWithDictionary:parameters]];
}


- (void)dismiss:(BOOL)animated {
    
    if (_isShowing && !_isBeingDismissed) {
        _isBeingShown = NO;
        _isShowing = NO;
        _isBeingDismissed = YES;
        
        // cancel previous dismiss requests (i.e. the dismiss after duration call).
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
        
        [self willStartDismissing];
        
        if (self.willStartDismissingCompletion != nil) {
            self.willStartDismissingCompletion();
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            
            // Animate background if needed
            void (^backgroundAnimationBlock)(void) = ^(void) {
                _backgroundView.alpha = 0.0;
            };
            
            if (animated && (_showType != WWPopupShowTypeNone)) {
                // Make fade happen faster than motion. Use linear for fades.
                [UIView animateWithDuration:0.15
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:backgroundAnimationBlock
                                 completion:NULL];
            } else {
                backgroundAnimationBlock();
            }
            
            // Setup completion block
            void (^completionBlock)(BOOL) = ^(BOOL finished) {
                
                [self removeFromSuperview];
                
                _isBeingShown = NO;
                _isShowing = NO;
                _isBeingDismissed = NO;
                
                [self didFinishDismissing];
                
                if (self.didFinishDismissingCompletion != nil) {
                    self.didFinishDismissingCompletion();
                }
            };
            
            NSTimeInterval bounce1Duration = 0.13;
            NSTimeInterval bounce2Duration = (bounce1Duration * 2.0);
            
            // Animate content if needed
            if (animated) {
                switch (_dismissType) {
                    case WWPopupDismissTypeFadeOut: {
                        [UIView animateWithDuration:0.15
                                              delay:0
                                            options:UIViewAnimationOptionCurveLinear
                                         animations:^{
                                             _containerView.alpha = 0.0;
                                         } completion:completionBlock];
                        break;
                    }
                        
                    case WWPopupDismissTypeGrowOut: {
                        [UIView animateWithDuration:0.15
                                              delay:0
                                            options:kAnimationOptionCurveIOS7
                                         animations:^{
                                             _containerView.alpha = 0.0;
                                             _containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                                         } completion:completionBlock];
                        break;
                    }
                        
                    case WWPopupDismissTypeShrinkOut: {
                        [UIView animateWithDuration:0.15
                                              delay:0
                                            options:kAnimationOptionCurveIOS7
                                         animations:^{
                                             _containerView.alpha = 0.0;
                                             _containerView.transform = CGAffineTransformMakeScale(0.8, 0.8);
                                         } completion:completionBlock];
                        break;
                    }
                        
                    case WWPopupDismissTypeSlideOutToTop: {
                        [UIView animateWithDuration:0.30
                                              delay:0
                                            options:kAnimationOptionCurveIOS7
                                         animations:^{
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.y = -CGRectGetHeight(finalFrame);
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:completionBlock];
                        break;
                    }
                        
                    case WWPopupDismissTypeSlideOutToBottom: {
                        [UIView animateWithDuration:0.30
                                              delay:0
                                            options:kAnimationOptionCurveIOS7
                                         animations:^{
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.y = CGRectGetHeight(self.bounds);
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:completionBlock];
                        break;
                    }
                        
                    case WWPopupDismissTypeSlideOutToLeft: {
                        [UIView animateWithDuration:0.30
                                              delay:0
                                            options:kAnimationOptionCurveIOS7
                                         animations:^{
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.x = -CGRectGetWidth(finalFrame);
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:completionBlock];
                        break;
                    }
                        
                    case WWPopupDismissTypeSlideOutToRight: {
                        [UIView animateWithDuration:0.30
                                              delay:0
                                            options:kAnimationOptionCurveIOS7
                                         animations:^{
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.x = CGRectGetWidth(self.bounds);
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:completionBlock];
                        
                        break;
                    }
                        
                    case WWPopupDismissTypeBounceOut: {
                        [UIView animateWithDuration:bounce1Duration
                                              delay:0
                                            options:UIViewAnimationOptionCurveEaseOut
                                         animations:^(void){
                                             _containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                                         }
                                         completion:^(BOOL finished){
                                             
                                             [UIView animateWithDuration:bounce2Duration
                                                                   delay:0
                                                                 options:UIViewAnimationOptionCurveEaseIn
                                                              animations:^(void){
                                                                  _containerView.alpha = 0.0;
                                                                  _containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                                              }
                                                              completion:completionBlock];
                                         }];
                        
                        break;
                    }
                        
                    case WWPopupDismissTypeBounceOutToTop: {
                        [UIView animateWithDuration:bounce1Duration
                                              delay:0
                                            options:UIViewAnimationOptionCurveEaseOut
                                         animations:^(void){
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.y += 40.0;
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:^(BOOL finished){
                                             
                                             [UIView animateWithDuration:bounce2Duration
                                                                   delay:0
                                                                 options:UIViewAnimationOptionCurveEaseIn
                                                              animations:^(void){
                                                                  CGRect finalFrame = _containerView.frame;
                                                                  finalFrame.origin.y = -CGRectGetHeight(finalFrame);
                                                                  _containerView.frame = finalFrame;
                                                              }
                                                              completion:completionBlock];
                                         }];
                        
                        break;
                    }
                        
                    case WWPopupDismissTypeBounceOutToBottom: {
                        [UIView animateWithDuration:bounce1Duration
                                              delay:0
                                            options:UIViewAnimationOptionCurveEaseOut
                                         animations:^(void){
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.y -= 40.0;
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:^(BOOL finished){
                                             
                                             [UIView animateWithDuration:bounce2Duration
                                                                   delay:0
                                                                 options:UIViewAnimationOptionCurveEaseIn
                                                              animations:^(void){
                                                                  CGRect finalFrame = _containerView.frame;
                                                                  finalFrame.origin.y = CGRectGetHeight(self.bounds);
                                                                  _containerView.frame = finalFrame;
                                                              }
                                                              completion:completionBlock];
                                         }];
                        
                        break;
                    }
                        
                    case WWPopupDismissTypeBounceOutToLeft: {
                        [UIView animateWithDuration:bounce1Duration
                                              delay:0
                                            options:UIViewAnimationOptionCurveEaseOut
                                         animations:^(void){
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.x += 40.0;
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:^(BOOL finished){
                                             
                                             [UIView animateWithDuration:bounce2Duration
                                                                   delay:0
                                                                 options:UIViewAnimationOptionCurveEaseIn
                                                              animations:^(void){
                                                                  CGRect finalFrame = _containerView.frame;
                                                                  finalFrame.origin.x = -CGRectGetWidth(finalFrame);
                                                                  _containerView.frame = finalFrame;
                                                              }
                                                              completion:completionBlock];
                                         }];
                        break;
                    }
                        
                    case WWPopupDismissTypeBounceOutToRight: {
                        [UIView animateWithDuration:bounce1Duration
                                              delay:0
                                            options:UIViewAnimationOptionCurveEaseOut
                                         animations:^(void){
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.x -= 40.0;
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:^(BOOL finished){
                                             
                                             [UIView animateWithDuration:bounce2Duration
                                                                   delay:0
                                                                 options:UIViewAnimationOptionCurveEaseIn
                                                              animations:^(void){
                                                                  CGRect finalFrame = _containerView.frame;
                                                                  finalFrame.origin.x = CGRectGetWidth(self.bounds);
                                                                  _containerView.frame = finalFrame;
                                                              }
                                                              completion:completionBlock];
                                         }];
                        break;
                    }
                        
                    default: {
                        self.containerView.alpha = 0.0;
                        completionBlock(YES);
                        break;
                    }
                }
            } else {
                self.containerView.alpha = 0.0;
                completionBlock(YES);
            }
            
        });
    }
}


#pragma mark - Private

- (void)showWithParameters:(NSDictionary*)parameters {
    
    // If popup can be shown
    if (!_isBeingShown && !_isShowing && !_isBeingDismissed) {
        _isBeingShown = YES;
        _isShowing = NO;
        _isBeingDismissed = NO;
        
        [self willStartShowing];
        [self resetContainerFrame:YES];
    }
}

- (void)layoutContentView
{
    [self resetContainerFrame:NO];
}

-(void)resetContainerFrame:(BOOL)isResize
{
    NSDictionary* parameters = @{@"layout" : [NSValue valueWithWWPopupLayout:_currentLayout],
                                 @"duration" : @(0)};
    dispatch_async( dispatch_get_main_queue(), ^{
        
        // Prepare by adding to the top window.
        if(!self.superview){
            NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
            
            for (UIWindow *window in frontToBackWindows) {
                if (window.windowLevel == UIWindowLevelNormal) {
                    [window addSubview:self];
                    
                    break;
                }
            }
        }
        
        // Before we calculate layout for containerView, make sure we are transformed for current orientation.
        [self updateForInterfaceOrientation];
        
        // Make sure we're not hidden
        self.hidden = NO;
        self.alpha = 1.0;
        
        WWPopupShowType showType = isResize?_showType: WWPopupShowTypeResize;
        
        
        // Animate background if needed
        void (^backgroundAnimationBlock)(void) = ^(void) {
            _backgroundView.alpha = 1.0;
        };
        if (_maskType == WWPopupMaskTypeDimmed) {
            _backgroundView.backgroundColor = [UIColor colorWithRed:(0.0/255.0f) green:(0.0/255.0f) blue:(0.0/255.0f) alpha:self.dimmedMaskAlpha];
        } else {
            _backgroundView.backgroundColor = [UIColor clearColor];
        }
        
        if (showType != WWPopupShowTypeNone && showType != WWPopupShowTypeResize) {
            _backgroundView.alpha = 0.0;
            
            // Make fade happen faster than motion. Use linear for fades.
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:backgroundAnimationBlock
                             completion:NULL];
        } else {
            backgroundAnimationBlock();
        }
        
        // Determine duration. Default to 0 if none provided.
        NSTimeInterval duration;
        NSNumber* durationNumber = [parameters valueForKey:@"duration"];
        if (durationNumber != nil) {
            duration = [durationNumber doubleValue];
        } else {
            duration = 0.0;
        }
        
        // Setup completion block
        void (^completionBlock)(BOOL) = ^(BOOL finished) {
            _isBeingShown = NO;
            _isShowing = YES;
            _isBeingDismissed = NO;
            
            [self didFinishShowing];
            
            if (self.didFinishShowingCompletion != nil) {
                self.didFinishShowingCompletion();
            }
            
            // Set to hide after duration if greater than zero.
            if (duration > 0.0) {
                [self performSelector:@selector(dismiss) withObject:nil afterDelay:duration];
            }
        };
        
        // Add contentView to container
        if (self.contentView.superview != _containerView) {
            [_containerView addSubview:self.contentView];
        }
        
        // Re-layout (this is needed if the contentView is using autoLayout)
        [self.contentView layoutIfNeeded];
        
        // Size container to match contentView
        CGRect containerFrame = _containerView.frame;
        containerFrame.size = self.contentView.frame.size;
        _containerView.frame = containerFrame;
        // Position contentView to fill it
        CGRect contentViewFrame = self.contentView.frame;
        contentViewFrame.origin = CGPointZero;
        self.contentView.frame = contentViewFrame;
        
        // Reset _containerView's constraints in case contentView is uaing autolayout.
        UIView* contentView = self.contentView;
        NSDictionary* views = NSDictionaryOfVariableBindings(contentView);
        
        [_containerView removeConstraints:_containerView.constraints];
        [_containerView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        [_containerView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        // Determine final position and necessary autoresizingMask for container.
        CGRect finalContainerFrame = containerFrame;
        UIViewAutoresizing containerAutoresizingMask = UIViewAutoresizingNone;
        
        // Use explicit center coordinates if provided.
        NSValue* centerValue = [parameters valueForKey:@"center"];
        if (centerValue != nil) {
            
            CGPoint centerInView = [centerValue CGPointValue];
            CGPoint centerInSelf;
            
            // Convert coordinates from provided view to self. Otherwise use as-is.
            UIView* fromView = [parameters valueForKey:@"view"];
            if (fromView != nil) {
                centerInSelf = [self convertPoint:centerInView fromView:fromView];
            } else {
                centerInSelf = centerInView;
            }
            
            finalContainerFrame.origin.x = (centerInSelf.x - CGRectGetWidth(finalContainerFrame)/2.0);
            finalContainerFrame.origin.y = (centerInSelf.y - CGRectGetHeight(finalContainerFrame)/2.0);
            containerAutoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        }
        else {// Otherwise use relative layout. Default to center if none provided.
            
            NSValue* layoutValue = [parameters valueForKey:@"layout"];
            WWPopupLayout layout;
            if (layoutValue != nil) {
                layout = [layoutValue WWPopupLayoutValue];
            } else {
                layout = WWPopupLayoutCenter;
            }
            _currentLayout = layout;
            switch (layout.horizontal) {
                    
                case WWPopupHorizontalLayoutLeft: {
                    finalContainerFrame.origin.x = 0.0;
                    containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleRightMargin;
                    break;
                }
                    
                case WWPopupHorizontalLayoutLeftOfCenter: {
                    finalContainerFrame.origin.x = floorf(CGRectGetWidth(self.bounds)/3.0 - CGRectGetWidth(containerFrame)/2.0);
                    containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                    break;
                }
                    
                case WWPopupHorizontalLayoutCenter: {
                    finalContainerFrame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(containerFrame))/2.0);
                    containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                    break;
                }
                    
                case WWPopupHorizontalLayoutRightOfCenter: {
                    finalContainerFrame.origin.x = floorf(CGRectGetWidth(self.bounds)*2.0/3.0 - CGRectGetWidth(containerFrame)/2.0);
                    containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                    break;
                }
                    
                case WWPopupHorizontalLayoutRight: {
                    finalContainerFrame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(containerFrame);
                    containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin;
                    break;
                }
                    
                default:
                    break;
            }
            
            // Vertical
            switch (layout.vertical) {
                    
                case WWPopupVerticalLayoutTop: {
                    finalContainerFrame.origin.y = 0;
                    containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleBottomMargin;
                    break;
                }
                    
                case WWPopupVerticalLayoutAboveCenter: {
                    finalContainerFrame.origin.y = floorf(CGRectGetHeight(self.bounds)/3.0 - CGRectGetHeight(containerFrame)/2.0);
                    containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                    break;
                }
                    
                case WWPopupVerticalLayoutCenter: {
                    finalContainerFrame.origin.y = floorf((CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame))/2.0);
                    containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                    break;
                }
                    
                case WWPopupVerticalLayoutBelowCenter: {
                    finalContainerFrame.origin.y = floorf(CGRectGetHeight(self.bounds)*2.0/3.0 - CGRectGetHeight(containerFrame)/2.0);
                    containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                    break;
                }
                    
                case WWPopupVerticalLayoutBottom: {
                    finalContainerFrame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame);
                    containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin;
                    break;
                }
                    
                default:
                    break;
            }
        }
        
        _containerView.autoresizingMask = containerAutoresizingMask;
       
        // Animate content if needed
        switch (showType) {
            case WWPopupShowTypeFadeIn: {
                
                _containerView.alpha = 0.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:0.15
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     _containerView.alpha = 1.0;
                                 }
                                 completion:completionBlock];
                break;
            }
                
            case WWPopupShowTypeGrowIn: {
                
                _containerView.alpha = 0.0;
                // set frame before transform here...
                CGRect startFrame = finalContainerFrame;
                _containerView.frame = startFrame;
                _containerView.transform = CGAffineTransformMakeScale(0.85, 0.85);
                
                [UIView animateWithDuration:0.15
                                      delay:0
                                    options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                 animations:^{
                                     _containerView.alpha = 1.0;
                                     // set transform before frame here...
                                     _containerView.transform = CGAffineTransformIdentity;
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                
                break;
            }
                
            case WWPopupShowTypeShrinkIn: {
                _containerView.alpha = 0.0;
                // set frame before transform here...
                CGRect startFrame = finalContainerFrame;
                _containerView.frame = startFrame;
                _containerView.transform = CGAffineTransformMakeScale(1.25, 1.25);
                
                [UIView animateWithDuration:0.15
                                      delay:0
                                    options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                 animations:^{
                                     _containerView.alpha = 1.0;
                                     // set transform before frame here...
                                     _containerView.transform = CGAffineTransformIdentity;
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
                
            case WWPopupShowTypeSlideInFromTop: {
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.y = -CGRectGetHeight(finalContainerFrame);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:0.30
                                      delay:0
                                    options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
                
            case WWPopupShowTypeSlideInFromBottom: {
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.y = CGRectGetHeight(self.bounds);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:0.30
                                      delay:0
                                    options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
                
            case WWPopupShowTypeSlideInFromLeft: {
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.x = -CGRectGetWidth(finalContainerFrame);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:0.30
                                      delay:0
                                    options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
                
            case WWPopupShowTypeSlideInFromRight: {
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.x = CGRectGetWidth(self.bounds);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:0.30
                                      delay:0
                                    options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                
                break;
            }
                
            case WWPopupShowTypeBounceIn: {
                _containerView.alpha = 0.0;
                // set frame before transform here...
                CGRect startFrame = finalContainerFrame;
                _containerView.frame = startFrame;
                _containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                
                [UIView animateWithDuration:0.6
                                      delay:0.0
                     usingSpringWithDamping:0.8
                      initialSpringVelocity:15.0
                                    options:0
                                 animations:^{
                                     _containerView.alpha = 1.0;
                                     _containerView.transform = CGAffineTransformIdentity;
                                 }
                                 completion:completionBlock];
                
                break;
            }
                
            case WWPopupShowTypeBounceInFromTop: {
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.y = -CGRectGetHeight(finalContainerFrame);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:0.6
                                      delay:0.0
                     usingSpringWithDamping:0.8
                      initialSpringVelocity:10.0
                                    options:0
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
                
            case WWPopupShowTypeBounceInFromBottom: {
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.y = CGRectGetHeight(self.bounds);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:0.6
                                      delay:0.0
                     usingSpringWithDamping:0.8
                      initialSpringVelocity:10.0
                                    options:0
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
                
            case WWPopupShowTypeBounceInFromLeft: {
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.x = -CGRectGetWidth(finalContainerFrame);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:0.6
                                      delay:0.0
                     usingSpringWithDamping:0.8
                      initialSpringVelocity:10.0
                                    options:0
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
                
            case WWPopupShowTypeBounceInFromRight: {
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.x = CGRectGetWidth(self.bounds);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:0.6
                                      delay:0.0
                     usingSpringWithDamping:0.8
                      initialSpringVelocity:10.0
                                    options:0
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
            case WWPopupShowTypeResize: {
                self.containerView.alpha = 1.0;
                self.containerView.transform = CGAffineTransformIdentity;
               
                
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                      self.containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
                
                
            default: {
                self.containerView.alpha = 1.0;
                self.containerView.transform = CGAffineTransformIdentity;
                self.containerView.frame = finalContainerFrame;
                
                completionBlock(YES);
                
                break;
            }
        }
    });
}

- (void)dismiss {
    [self dismiss:YES];
}


- (void)updateForInterfaceOrientation {
    
    // We must manually fix orientation prior to iOS 8
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        CGFloat angle;
        
        switch (orientation) {
            case UIInterfaceOrientationPortraitUpsideDown:
                angle = M_PI;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                angle = -M_PI/2.0f;;
                
                break;
            case UIInterfaceOrientationLandscapeRight:
                angle = M_PI/2.0f;
                
                break;
            default: // as UIInterfaceOrientationPortrait
                angle = 0.0;
                break;
        }
        
        self.transform = CGAffineTransformMakeRotation(angle);
    }
    
    self.frame = self.window.bounds;
}


#pragma mark - Notification handlers

- (void)didChangeStatusBarOrientation:(NSNotification*)notification {
    [self updateForInterfaceOrientation];
}


#pragma mark - Subclassing

- (void)willStartShowing {
    
}


- (void)didFinishShowing {
    
}


- (void)willStartDismissing {
    
}


- (void)didFinishDismissing {
    
}

@end




#pragma mark - Categories

@implementation UIView(WWPopup)


- (void)forEachPopupDoBlock:(void (^)(WWPopup* popup))block {
    for (UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:[WWPopup class]])
        {
            block((WWPopup *)subview);
        } else {
            [subview forEachPopupDoBlock:block];
        }
    }
}


- (void)dismissPresentingPopup {
    
    // Iterate over superviews until you find a WWPopup and dismiss it, then gtfo
    UIView* view = self;
    while (view != nil) {
        if ([view isKindOfClass:[WWPopup class]]) {
            [(WWPopup*)view dismiss:YES];
            break;
        }
        view = [view superview];
    }
}

@end




@implementation NSValue (WWPopupLayout)

+ (NSValue *)valueWithWWPopupLayout:(WWPopupLayout)layout
{
    return [NSValue valueWithBytes:&layout objCType:@encode(WWPopupLayout)];
}

- (WWPopupLayout)WWPopupLayoutValue
{
    WWPopupLayout layout;
    
    [self getValue:&layout];
    
    return layout;
}

@end