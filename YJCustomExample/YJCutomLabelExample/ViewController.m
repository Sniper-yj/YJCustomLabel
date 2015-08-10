//
//  ViewController.m
//  YJCutomLabelExample
//
//  Created by sniperYJ on 15/8/9.
//  Copyright (c) 2015年 sniperYJ. All rights reserved.
//

#import "ViewController.h"
#import "YJCustomLabel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    YJCustomLabel *label = [[YJCustomLabel alloc] initWithFrame:CGRectMake(10, 100, 200, 300)];
    label.font = [UIFont systemFontOfSize:14];
    //头部空格
    label.headSpace = 28;
    label.restrainArray = [NSMutableArray arrayWithObject:@"@[\u4e00-\u9fa5a-zA-Z0-9_-]{2,30}"];
    label.text = @"@小明，小明你太坏了，怎么喜欢你姐姐小红？@小红 因为姐姐是百度大神啊~@小红。";
    label.wordSpace = 5;
    label.clickBlock = ^(NSString *string){
        NSLog(@"click word %@",string);
    };
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
