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

@property (nonatomic ,strong) YJCustomLabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    YJCustomLabel *label = [[YJCustomLabel alloc] initWithFrame:CGRectMake(10, 100, 200, 300)];
    _label = label;
    //字体大小
    label.font = [UIFont systemFontOfSize:14];
    //头部空格
    label.headSpace = 28;
    //正则数组
    label.restrainArray = [NSMutableArray arrayWithObject:@"@[\u4e00-\u9fa5a-zA-Z0-9_-]{2,30}"];
    //内容
    label.text = @"@小明，小[明你]太坏了阿斯达，怎么[喜]欢[weixiosa]小红？@小红 因为姐姐是百[度大]神啊~@小红。";
    //每个字的间距
    label.wordSpace = 5;
    //属于正则的字体颜色
    label.restrainColor = [UIColor blueColor];
    //点击后的回调
    label.clickBlock = ^(NSString *string){
        NSLog(@"click word %@",string);
        NSString *str = [NSString stringWithFormat:@"您点击了 %@",string];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    };
    [self.view addSubview:label];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
