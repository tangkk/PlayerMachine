//
//  Drawing.m
//  PlayerMachine
//
//  Created by tangkk on 17/8/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "Drawing.h"

@interface Drawing ()

@end

@implementation Drawing

+ (void) drawCircleWithCenter:(CGPoint)center Radius:(CGFloat)radius onImage:(UIImageView *)Img withbrush:(UInt16)brush
                          Red:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue Alpha:(CGFloat)opacity Size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [Img.image drawInRect:CGRectMake(0, 0, Img.frame.size.width, Img.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
    //Try drawing a circle
    CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake(center.x-radius, center.y-radius, 2*radius, 2*radius));
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    CGContextFlush(UIGraphicsGetCurrentContext());
    Img.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

+ (void) drawLineWithPreviousPoint:(CGPoint)PP CurrentPoint:(CGPoint)CP onImage:(UIImageView *)Img withbrush:(UInt16)brush
                               Red:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue Alpha:(CGFloat)opacity Size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [Img.image drawInRect:CGRectMake(0, 0, Img.frame.size.width, Img.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), PP.x, PP.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), CP.x, CP.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    Img.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end
