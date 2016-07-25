//
//  ViewController.m
//  WWAlertTest
//
//  Created by Shouqiang Wei de Mac on 16/7/23.
//  Copyright © 2016年 shouqiangwei. All rights reserved.
//

#import "ViewController.h"
#import "WWAlertView.h"

@interface ViewController ()
{
    WWAlertView* _alertView;
    BOOL isResize;
}
- (IBAction)btnTestClicked:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)testAlert
{
    //_alertView = [WWAlertView showAlertWithTitle:@"这是一个提示测试。" ];
    
//    _alertView = [WWAlertView showAlertWithTitle:@"这是一个提示测试这是一个提示测试这是一个提示测试这是一个提示测试" contentText:@"这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,这是一个提示测试,"];
    
    //*
    _alertView = [WWAlertView alertWithTitle:@"test" contentText:@"内容违法！！"];
    [_alertView addButtonWithTitle:@"知道了" configBlock:^(UIButton *btn, id otherInfo) {
        
    } actionBlock:^BOOL(UIButton *btn, id otherInfo) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"test" message:@"msg" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        return YES;
    }];
    [_alertView show];
     //*/

}

- (IBAction)btnTestClicked:(id)sender {
    [self testAlert];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
   
}

-(void)btnResize:(id)sender
{
    isResize = !isResize;
    UIView* _realAlertView =  [_alertView valueForKey:@"_realAlertView"];
    CGFloat height = isResize?400:200;
    [_realAlertView setFrame:CGRectMake(0, 0, 200, height)];
    [_alertView layoutContentView];
}



@end
