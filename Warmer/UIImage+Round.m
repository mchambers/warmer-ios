//
//  UIImage+Round.m
//  Warmer
//
//  Created by Marc Chambers on 3/13/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "UIImage+Round.h"

@implementation UIImage (Round)

- (UIImage*)roundVersion
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    
    //[[UIBezierPath bezierPathWithRoundedRect:(CGRect){CGPointZero, self.size}
    //                            cornerRadius:r] addClip];
    [[UIBezierPath bezierPathWithOvalInRect:(CGRect){CGPointZero, self.size}] addClip];
    
    [self drawInRect:(CGRect){CGPointZero, self.size}];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

@end
