//
//  UIImage+ReDraw.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/27.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "UIImage+ReDraw.h"

@implementation UIImage(ReDraw)

+ (UIImage *)drawImage:(UIImage *)image width:(CGFloat)width{
    CGFloat minValue = MIN(image.size.width, image.size.height);
    float scaleFloat = width/minValue;
    CGSize size = CGSizeMake(scaleFloat*image.size.width, scaleFloat*image.size.height);

    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform = CGAffineTransformScale(transform, scaleFloat, scaleFloat);
    CGContextConcatCTM(context, transform);
    
    // Draw the image into the transformed context and return the image
    [image drawAtPoint: CGPointMake(0, 0)];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect imageRect = (CGRect){CGPointZero,newimg.size};
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, newimg.scale);
    
    context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -(imageRect.size.height));
    
    CGContextClipToMask(context, imageRect, newimg.CGImage);//选中选区 获取不透明区域路径
//    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);//设置颜色
    CGContextFillRect(context, imageRect);//绘制
    CGContextDrawImage(context, imageRect, newimg.CGImage);
    
    newimg = UIGraphicsGetImageFromCurrentImageContext();//提取图片
    UIGraphicsEndImageContext();
    
    return newimg;
}

- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
