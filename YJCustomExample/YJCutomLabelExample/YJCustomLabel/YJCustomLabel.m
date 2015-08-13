//
//  YJCustomLabel.m
//  coreTextByYJ
//
//  Created by sniperYJ on 15/8/4.
//  Copyright (c) 2015年 sniperYJ. All rights reserved.
//

#import "YJCustomLabel.h"
#import <CoreText/CoreText.h>

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

@implementation YJCustomLabel
{
    UIImageView *labelImageView;///<显示label内容的图片
    UIImageView *HighlightLabelImageView;///<显示点击后的label内容图片
    NSInteger row;//行高
    NSMutableDictionary *framesDict;///<储存特殊位置的数组
    NSRange currentRange;///<当前的点击区域
    BOOL highlighting;///<是否是点击后高亮
}


CTTextAlignment CTTextAlignmentFromUITextAlignment(NSTextAlignment alignment) {
    switch (alignment) {
        case NSTextAlignmentLeft: return kCTLeftTextAlignment;
        case NSTextAlignmentCenter: return kCTCenterTextAlignment;
        case NSTextAlignmentRight: return kCTRightTextAlignment;
        default: return kCTNaturalTextAlignment;
    }
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        framesDict = [NSMutableDictionary dictionary];
        labelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        labelImageView.contentMode = UIViewContentModeScaleAspectFit;
        labelImageView.tag = NSIntegerMin;
        labelImageView.clipsToBounds = YES;
        [self addSubview:labelImageView];
        
        HighlightLabelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        HighlightLabelImageView.contentMode = UIViewContentModeScaleAspectFit;
        HighlightLabelImageView.tag = NSIntegerMin;
        HighlightLabelImageView.clipsToBounds = YES;
        [self addSubview:HighlightLabelImageView];
        
        self.userInteractionEnabled = YES;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        _textAlignment = NSTextAlignmentLeft;
        _font = [UIFont systemFontOfSize:13];
        _textColor = [UIColor blackColor];
        _lineSpace = 5;
        _headSpace = 0;
        _wordSpace = 10;
        _restrainColor = [UIColor blueColor];
        
    }
    return self;
}



- (void)setText:(NSString *)text
{
    if (text == nil || text.length <= 0)
    {
        labelImageView.image = nil;
        HighlightLabelImageView.image = nil;
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *textMessage = text;
        _text = textMessage;
        UIColor *textColor = self.textColor;
        CGSize size = self.frame.size;
        UIGraphicsBeginImageContextWithOptions(size, ![self.backgroundColor isEqual:[UIColor clearColor]], 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context == NULL)
        {
            return;
        }
        if (![self.backgroundColor isEqual:[UIColor clearColor]]) {
            [self.backgroundColor set];
            CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
        }
        CGContextSetTextMatrix(context,CGAffineTransformIdentity);
        CGContextTranslateCTM(context,0,size.height);
        CGContextScaleCTM(context,1.0,-1.0);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, self.bounds);
        
        CGFloat minimumLineHeight = self.font.pointSize,maximumLineHeight = minimumLineHeight, linespace = self.lineSpace;
        CGFloat fristLineHead = _headSpace;
        CTLineBreakMode lineBreakMode = kCTLineBreakByCharWrapping;
        CTTextAlignment alignment = CTTextAlignmentFromUITextAlignment(self.textAlignment);
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate((CTParagraphStyleSetting[7]){{kCTParagraphStyleSpecifierAlignment,sizeof(alignment),&alignment},{kCTParagraphStyleSpecifierLineBreakMode,sizeof(lineBreakMode),&lineBreakMode},{kCTParagraphStyleSpecifierMaximumLineHeight,sizeof(maximumLineHeight),&maximumLineHeight},{kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(minimumLineHeight),&minimumLineHeight},{kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(linespace),&linespace},
            {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(linespace),&linespace},{kCTParagraphStyleSpecifierFirstLineHeadIndent,sizeof(fristLineHead),&fristLineHead}}, 7);
        
        
        //新增每个字的间距
        CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &_wordSpace);
        
        
        NSDictionary *attributeDic = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)textColor.CGColor,kCTForegroundColorAttributeName,font,kCTFontAttributeName,paragraphStyle,kCTParagraphStyleAttributeName,num,kCTKernAttributeName, nil];
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributeDic];
        //        [attributeString addAttribute:(NSString *)kCTKernAttributeName value:(__bridge id)(num) range:NSMakeRange(0, 3)];
        
        NSMutableAttributedString *attributeHighString = [self highlightString:attributeString];
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeHighString);
        
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, text.length), path, NULL);
        CGRect rect = CGRectMake(0, 0,(size.width),(size.height));
        [self drawFramesetter:framesetter attributedString:attributeHighString textRange:CFRangeMake(0, _text.length) inRect:rect context:context];
        
        CTFrameDraw(frame, context);
        UIImage *screenShotimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
    
            labelImageView.image = nil;
            HighlightLabelImageView.image = nil;
            
            if (highlighting)
            {
                HighlightLabelImageView.image = screenShotimage;
            }
            else
            {
                labelImageView.image = screenShotimage;
            }
            
            CFRelease(path);
            CFRelease(frame);
            CFRelease(framesetter);
            CFRelease(paragraphStyle);
            CFRelease(font);
            CFRelease(num);
        });
    });
}

- (void)drawFramesetter:(CTFramesetterRef)framesetter
       attributedString:(NSAttributedString *)attributedString
              textRange:(CFRange)textRange
                 inRect:(CGRect)rect
                context:(CGContextRef)c
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, textRange, path, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = CFArrayGetCount(lines);
    BOOL truncateLastLine = NO;//tailMode
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        lineOrigin = CGPointMake(CGFloat_ceil(lineOrigin.x), CGFloat_ceil(lineOrigin.y));
        
        CGContextSetTextPosition(c, lineOrigin.x, lineOrigin.y);
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        CGFloat descent = 0.0f;
        CGFloat ascent = 0.0f;
        CGFloat lineLeading;
        CTLineGetTypographicBounds((CTLineRef)line, &ascent, &descent, &lineLeading);
        
        CGFloat flushFactor = NSTextAlignmentLeft;
        CGFloat penOffset;
        CGFloat y;
        if (lineIndex == numberOfLines - 1 && truncateLastLine) {
            CFRange lastLineRange = CTLineGetStringRange(line);
            
            if (!(lastLineRange.length == 0 && lastLineRange.location == 0) && lastLineRange.location + lastLineRange.length < textRange.location + textRange.length) {
                
                CTLineTruncationType truncationType = kCTLineTruncationEnd;
                CFIndex truncationAttributePosition = lastLineRange.location;
                
                NSString *truncationTokenString = @"\u2026";
                
                NSDictionary *truncationTokenStringAttributes = [attributedString attributesAtIndex:(NSUInteger)truncationAttributePosition effectiveRange:NULL];
                
                NSAttributedString *attributedTokenString = [[NSAttributedString alloc] initWithString:truncationTokenString attributes:truncationTokenStringAttributes];
                CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedTokenString);
                
                NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange((NSUInteger)lastLineRange.location, (NSUInteger)lastLineRange.length)] mutableCopy];
                if (lastLineRange.length > 0) {
                    // Remove any newline at the end (we don't want newline space between the text and the truncation token). There can only be one, because the second would be on the next line.
                    unichar lastCharacter = [[truncationString string] characterAtIndex:(NSUInteger)(lastLineRange.length - 1)];
                    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastCharacter]) {
                        [truncationString deleteCharactersInRange:NSMakeRange((NSUInteger)(lastLineRange.length - 1), 1)];
                    }
                }
                [truncationString appendAttributedString:attributedTokenString];
                CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
                
                // Truncate the line in case it is too long.
                CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
                if (!truncatedLine) {
                    // If the line is not as wide as the truncationToken, truncatedLine is NULL
                    truncatedLine = CFRetain(truncationToken);
                }
                
                penOffset = (CGFloat)CTLineGetPenOffsetForFlush(truncatedLine, flushFactor, rect.size.width);
                y = lineOrigin.y - descent - self.font.descender;
                CGContextSetTextPosition(c, penOffset, y);
                
                //                CTLineDraw(truncatedLine, c);
                
                CFRelease(truncatedLine);
                CFRelease(truncationLine);
                CFRelease(truncationToken);
            } else {
                penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
                y = lineOrigin.y - descent - self.font.descender;
                CGContextSetTextPosition(c, penOffset, y);
                //                CTLineDraw(line, c);
            }
        } else {
            penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
            y = lineOrigin.y - descent - self.font.descender;
            CGContextSetTextPosition(c, penOffset, y);
            //            CTLineDraw(line, c);
        }
        if (!highlighting) {
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            for (int j = 0; j < CFArrayGetCount(runs); j++) {
                CGFloat runAscent;
                CGFloat runDescent;
                CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                NSDictionary* attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
                if (!CGColorEqualToColor((__bridge CGColorRef)([attributes valueForKey:@"CTForegroundColor"]), self.textColor.CGColor)
                    && framesDict!=nil) {
                    CFRange range = CTRunGetStringRange(run);
                    CGRect runRect;
                    runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                    float offset = CTLineGetOffsetForStringIndex(line, range.location, NULL);
                    float height = runAscent;
                    runRect=CGRectMake(lineOrigin.x + offset, (self.frame.size.height)-y-height+runDescent/2, runRect.size.width, height);
                    NSRange nRange = NSMakeRange(range.location, range.length);
                    
                    if ([NSValue valueWithCGRect:runRect] == nil)
                    {
                        
                    }
                    else
                    {
//                        [framesDict setValue:[NSValue valueWithCGRect:runRect] forKeyPath:NSStringFromRange(nRange)];
                        [framesDict setObject:[NSValue valueWithCGRect:runRect] forKey:NSStringFromRange(nRange)];
//                        [framesDict setValue:[NSValue valueWithCGRect:runRect] forKey:NSStringFromRange(nRange)];
                    }
                }
            }
        }
    }
    
//    CFRelease(frame);
//    CFRelease(path);
}

#pragma mark - highlight

- (NSMutableAttributedString *)highlightString:(NSMutableAttributedString *)attributString
{
    NSString *string = attributString.string;
    NSRange range = NSMakeRange(0, string.length);
    for (NSString *str in _restrainArray)
    {
        NSArray *mathes = [[NSRegularExpression regularExpressionWithPattern:str options:NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:string options:0 range:range];
        for (NSTextCheckingResult *match in mathes)
        {
            if (highlighting)
            {
                if (labelImageView.image != nil && currentRange.location!=-1 && currentRange.location>=match.range.location && currentRange.length+currentRange.location<=match.range.length+match.range.location)
                {
                    [attributString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[UIColor redColor].CGColor range:match.range];
                    NSString *str = [attributString.string substringWithRange:match.range];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (self.clickBlock)
                        {
                            self.clickBlock(str);
                        }
                    });
                }
                else
                {
                    [attributString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)self.restrainColor.CGColor range:match.range];
                }
            }
            else
            {
                
                [attributString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)self.restrainColor.CGColor range:match.range];
            }
            
            
        }
    }
    return attributString;
}

#pragma mark - getter and setter

-(void)setRestrainColor:(UIColor *)restrainColor
{
    _restrainColor = restrainColor;
    [self setText:_text];
}

-(void)setRestrainArray:(NSMutableArray *)restrainArray
{
    _restrainArray = restrainArray;
    [self setText:_text];
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    [self setText:_text];
}

- (void)setHeadSpace:(float)headSpace
{
    _headSpace = headSpace;
    [self setText:_text];
}

-(void)setLineSpace:(CGFloat)lineSpace
{
    _lineSpace = lineSpace;
    [self setText:_text];
}

- (void)setFrame:(CGRect)frame{
    if (!CGSizeEqualToSize(labelImageView.image.size, frame.size)) {
        labelImageView.image = nil;
    }
    labelImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [self setText:_text];
    [super setFrame:frame];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _textAlignment = textAlignment;
    [self setText:_text];
}
- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self setText:_text];
}

- (void)setWordSpace:(int)wordSpace
{
    _wordSpace = wordSpace;
    [self setText:_text];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint location = [[touches anyObject] locationInView:self];
    for (NSString *key in framesDict.allKeys) {
        CGRect frame = [[framesDict valueForKey:key] CGRectValue];
        if (CGRectContainsPoint(frame, location)) {
            NSRange range = NSRangeFromString(key);
            range = NSMakeRange(range.location, range.length-1);
            currentRange = range;
            highlighting = YES;
            [self setText:_text];
        }
    }
}


-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        highlighting = NO;
        [self setText:_text];
    });
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    highlighting = NO;
    [self setText:_text];
}

@end
