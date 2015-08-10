//
//  YJCustomLabel.h
//  coreTextByYJ
//
//  Created by sniperYJ on 15/8/4.
//  Copyright (c) 2015年 sniperYJ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^clickBlock)(NSString *);
@interface YJCustomLabel : UIView

@property(nonatomic,copy)   NSString           *text;
@property(nonatomic,retain) UIFont             *font;
@property(nonatomic,retain) UIColor            *textColor;
@property(nonatomic)        NSTextAlignment    textAlignment;
@property (nonatomic ,assign) CGFloat lineSpace;///<行间距
@property (nonatomic ,assign) int wordSpace;///<每个字的间距
@property (nonatomic ,strong) NSMutableArray *restrainArray;///<添加正则表达式的数组
@property (nonatomic ,assign) float headSpace;///<首部空格距离
@property (nonatomic ,copy) clickBlock clickBlock;///<点击特殊字符的回调，并且附带内容

@end