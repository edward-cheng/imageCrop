//
//  EdwImageCropVC.h
//  imageCrop
//
//  Created by EdwardCheng on 2018/11/1.
//  Copyright © 2018年 EdwardCheng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EdwImageCropVC : UIViewController
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) void(^imgBlock)(UIImage *img);
@end

NS_ASSUME_NONNULL_END
