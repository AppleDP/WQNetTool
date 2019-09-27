//
//  UIImage+WQCategory.m
//  WQCategory
//
//  Created by iOS on 2018/4/10.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "UIImage+WQExtension.h"

@implementation UIImage (WQExtension)
+ (UIImage *)wq_imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)wq_codeCreateWithType:(WQCodeType)codeType
                             String:(NSString *)str
                               size:(CGSize)size
                              color:(UIColor *)color
                          watermark:(UIImage *)watermark
                           position:(CGRect)rect {
    CGFloat red,green,blue,alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    // 滤镜
    CIFilter *filter;
    switch (codeType) {
        case WQBarCode:{
            if([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
#ifdef DEBUG
                // 条形码生成只在 iOS 8.0 后支持
                NSAssert([[UIDevice currentDevice].systemVersion floatValue] > 8.0, @"条形码生成只在 iOS 8.0 后支持");
#endif
                return nil;
            }
            // 生成条形码
            filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
            [filter setDefaults];
            
            // 生成条形码的上、下、左、右的 margins 值
            [filter setValue:@0.00 forKeyPath:@"inputQuietSpace"];
        }break;
        default:{
            // 生成二维码
            filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
            [filter setDefaults];
            
            // 纠错等级, "L"、"M"、"Q"、"H",越高越易识别
            [filter setValue:@"Q" forKeyPath:@"inputCorrectionLevel"];
        }break;
    }
    // 字符串转 NSData
    NSData *strData = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    // 将字符串数据放入滤镜
    [filter setValue:strData forKeyPath:@"inputMessage"];
    
    // 获得滤出图象
    CIImage *outputImg = [filter outputImage];
    
    // 得到重画图
    UIImage *resultImg = [self createNonInterPolateUIImageFormCIImage:outputImg size:size red:red*255.0 green:green*255.0 blue:blue*255.0];
    if (watermark != nil) {
        // 为图片添加水印
        resultImg = [resultImg wq_insertImage:watermark rect:rect];
    }
    return resultImg;
}

- (NSData *)wq_losslessCompressionWithExpectSize:(NSUInteger)expectSize {
    //先判断当前质量是否满足要求，不满足再进行压缩
    __block NSData *finallImageData = UIImageJPEGRepresentation(self,1.0);
    NSUInteger sizeOrigin   = finallImageData.length;
    NSUInteger sizeOriginKB = sizeOrigin/1024;
    
    if (sizeOriginKB <= expectSize) {
        return finallImageData;
    }
    
    //获取原图片宽高比
    CGFloat sourceImageAspectRatio = self.size.width/self.size.height;
    //先调整分辨率
    CGSize defaultSize = CGSizeMake(1024, 1024/sourceImageAspectRatio);
    UIImage *newImage = [self newSizeImage:defaultSize image:self];
    
    finallImageData = UIImageJPEGRepresentation(newImage,1.0);
    
    //保存压缩系数
    NSMutableArray *compressionQualityArr = [NSMutableArray array];
    CGFloat avg   = 1.0/250;
    CGFloat value = avg;
    for (int i = 250; i >= 1; i--) {
        value = i*avg;
        [compressionQualityArr addObject:@(value)];
    }
    
    /*
     调整大小
     说明：压缩系数数组compressionQualityArr是从大到小存储。
     */
    //思路：使用二分法搜索
    __block NSData *canCompressMinData = [NSData data];//当无法压缩到指定大小时，用于存储当前能够压缩到的最小值数据。
    [self halfFuntion:compressionQualityArr image:newImage sourceData:finallImageData maxSize:expectSize resultBlock:^(NSData *finallData, NSData *tempData) {
        finallImageData = finallData;
        canCompressMinData = tempData;
    }];
    //如果还是未能压缩到指定大小，则进行降分辨率
    while (finallImageData.length == 0) {
        //每次降100分辨率
        CGFloat reduceWidth = 100.0;
        CGFloat reduceHeight = 100.0/sourceImageAspectRatio;
        if (defaultSize.width-reduceWidth <= 0 || defaultSize.height-reduceHeight <= 0) {
            break;
        }
        defaultSize = CGSizeMake(defaultSize.width-reduceWidth, defaultSize.height-reduceHeight);
        UIImage *image = [self newSizeImage:defaultSize image:[UIImage imageWithData:UIImageJPEGRepresentation(newImage,[[compressionQualityArr lastObject] floatValue])]];
        [self halfFuntion:compressionQualityArr image:image sourceData:UIImageJPEGRepresentation(image,1.0) maxSize:expectSize resultBlock:^(NSData *finallData, NSData *tempData) {
            finallImageData = finallData;
            canCompressMinData = tempData;
        }];
    }
    //如果分辨率已经无法再降低，则直接使用能够压缩的那个最小值即可
    if (finallImageData.length==0) {
        finallImageData = canCompressMinData;
    }
    return finallImageData;
}

- (UIImage *)wq_imageWithTintColor:(UIColor *)tintColor {
    return [self wq_imageWithTintColor:tintColor
                             blendMode:kCGBlendModeDestinationIn];
}

- (UIImage *)wq_imageWithGradientTintColor:(UIColor *)tintColor {
    return [self wq_imageWithTintColor:tintColor
                             blendMode:kCGBlendModeOverlay];
}

- (UIImage *)wq_scaleToSize:(CGSize)size {
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (UIImage *)wq_ratioHeightWithWidth:(CGFloat)width {
    CGFloat fixHeight = self.size.height*width/self.size.width;
    return [self wq_scaleToSize:CGSizeMake(width, fixHeight)];
}

- (UIImage *)wq_ratioWidthWithHeight:(CGFloat)height {
    CGFloat fixWidth = self.size.width*height/self.size.height;
    return [self wq_scaleToSize:CGSizeMake(fixWidth, height)];
}

- (UIImage *)wq_insertImage:(UIImage *)image
                       rect:(CGRect)rect {
    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    //四个参数为水印图片的位置
    [image drawInRect:rect];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}


#pragma mak -- 私有方法 --
- (UIImage *)wq_imageWithTintColor:(UIColor *)tintColor
                         blendMode:(CGBlendMode)blendMode{
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    if (blendMode != kCGBlendModeDestinationIn) {
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}

+ (UIImage *)createNonInterPolateUIImageFormCIImage:(CIImage *)ciImage
                                               size:(CGSize)size
                                                red:(CGFloat)red
                                              green:(CGFloat)green
                                               blue:(CGFloat)blue{
    CGRect extentRect = CGRectIntegral(ciImage.extent);
    CGFloat scaleW = size.width / CGRectGetWidth(extentRect);
    CGFloat scaleH = size.height / CGRectGetHeight(extentRect);
    size_t width = CGRectGetWidth(extentRect) * scaleW;
    size_t height = CGRectGetHeight(extentRect) * scaleH;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:ciImage fromRect:extentRect];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scaleW, scaleH);
    CGContextDrawImage(bitmapRef, extentRect, bitmapImage);
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage *newImage = [UIImage imageWithCGImage:scaledImage];
    return [self imageBlackToTransparent:newImage withRed:red andGreen:green andBlue:blue];
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void *)data);
}

+ (UIImage *)imageBlackToTransparent:(UIImage *)image
                             withRed:(CGFloat)red
                            andGreen:(CGFloat)green
                             andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    int pixelNum = imageWidth * imageHeight;
    uint32_t *pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i ++, pCurPtr ++) {
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) {
            uint8_t *ptr = (uint8_t *)pCurPtr;
            ptr[3] = red;
            ptr[2] = green;
            ptr[1] = blue;
        }else {
            uint8_t *ptr = (uint8_t *)pCurPtr;
            ptr[0] = 0;
        }
    }
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage *resultUIImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

- (UIImage *)newSizeImage:(CGSize)size
                    image:(UIImage *)sourceImage {
    // 调整图片分辨率/尺寸（等比例缩放）
    CGSize newSize = CGSizeMake(sourceImage.size.width, sourceImage.size.height);
    CGFloat tempHeight = newSize.height / size.height;
    CGFloat tempWidth = newSize.width / size.width;
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempWidth, sourceImage.size.height / tempWidth);
    } else if (tempHeight > 1.0 && tempWidth < tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempHeight, sourceImage.size.height / tempHeight);
    }
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1);
    [sourceImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)halfFuntion:(NSArray *)arr
              image:(UIImage *)image
         sourceData:(NSData *)finallImageData
            maxSize:(NSInteger)maxSize
        resultBlock:(void(^)(NSData *finallData, NSData *tempData))block {
    // 二分法，block回调中finallData长度不为零表示最终压缩到了指定的大小，如果为零则表示压缩不到指定大小。tempData表示当前能够压缩到的最小值。
    NSData *tempData = [NSData data];
    NSUInteger start = 0;
    NSUInteger end = arr.count - 1;
    NSUInteger index = 0;
    NSUInteger difference = NSIntegerMax;
    while(start <= end) {
        index = start + (end - start)/2;
        finallImageData = UIImageJPEGRepresentation(image,[arr[index] floatValue]);
        NSUInteger sizeOrigin = finallImageData.length;
        NSUInteger sizeOriginKB = sizeOrigin / 1024;
        if (sizeOriginKB > maxSize) {
            start = index + 1;
        } else if (sizeOriginKB < maxSize) {
            if (maxSize-sizeOriginKB < difference) {
                difference = maxSize-sizeOriginKB;
                tempData = finallImageData;
            }
            if (index<=0) {
                break;
            }
            end = index - 1;
        } else {
            break;
        }
    }
    NSData *d = [NSData data];
    if (tempData.length==0) {
        d = finallImageData;
    }
    if (block) {
        block(tempData, d);
    }
}
@end
