//
//  EdwImageCropVC.m
//  imageCrop
//
//  Created by EdwardCheng on 2018/11/1.
//  Copyright © 2018年 EdwardCheng. All rights reserved.
//

#import "EdwImageCropVC.h"

@interface EdwImageCropVC ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;       //需要裁剪的图片

@property (nonatomic, strong) UIView *cropView;             //裁剪区域
@property (nonatomic, strong) UIImageView *mengbanView;     //预览图
@property (nonatomic, strong) CAShapeLayer *shapeLayer;     //周边阴影

@property (nonatomic, strong) UIToolbar *mohu1;
@property (nonatomic, strong) UIToolbar *mohu2;
@property (nonatomic, strong) UIToolbar *mohu3;
@property (nonatomic, strong) UIToolbar *mohu4;

@property (nonatomic, assign) CGFloat minScale;
@property (nonatomic, assign) CGPoint resetPoint;
@end

@implementation EdwImageCropVC

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI{
    self.title = @"Crop";
    self.view.backgroundColor = [UIColor blackColor];
    self.view.layer.masksToBounds = YES;
    //主要针对大于2m的图片处理，防止旋转
    self.image = [self fixOrientation:self.image];
    
    UIView *cropView = [[UIView alloc]init];
    cropView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.6];
    cropView.userInteractionEnabled = NO;
    [self.view addSubview:cropView];
    self.cropView = cropView;
    
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.bounces = YES;
    scrollView.delegate = self;
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    scrollView.clipsToBounds = YES;
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapScrollView:)];
    [scrollView addGestureRecognizer:tapGes];
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.backgroundColor = [UIColor yellowColor];
    imageView.image = self.image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:imageView];
    self.imageView = imageView;
    
    //毛玻璃
    UIToolbar *mohu1 = [[UIToolbar alloc]init];
    mohu1.barStyle = UIBarStyleBlackTranslucent;
    mohu1.alpha = 0;
    mohu1.userInteractionEnabled = NO;
    [self.view addSubview:mohu1];
    self.mohu1 = mohu1;
    
    UIToolbar *mohu2 = [[UIToolbar alloc]init];
    mohu2.barStyle = UIBarStyleBlackTranslucent;
    mohu2.alpha = 0;
    mohu2.userInteractionEnabled = NO;
    [self.view addSubview:mohu2];
    self.mohu2 = mohu2;
    
    UIToolbar *mohu3 = [[UIToolbar alloc]init];
    mohu3.barStyle = UIBarStyleBlackTranslucent;
    mohu3.alpha = 0;
    mohu3.userInteractionEnabled = NO;
    [self.view addSubview:mohu3];
    self.mohu3 = mohu3;
    
    UIToolbar *mohu4 = [[UIToolbar alloc]init];
    mohu4.barStyle = UIBarStyleBlackTranslucent;
    mohu4.alpha = 0;
    mohu4.userInteractionEnabled = NO;
    [self.view addSubview:mohu4];
    self.mohu4 = mohu4;
    
    UIImageView *mengbanView = [[UIImageView alloc]init];
    mengbanView.image = [UIImage imageNamed:@"edit_userCover_mengban"];
    mengbanView.userInteractionEnabled = NO;
    mengbanView.alpha = 0;
    [self.view addSubview:mengbanView];
    self.mengbanView = mengbanView;
    
    UIButton *cancelBtn =[[UIButton alloc]init];
    [cancelBtn setTitle:@"cancel" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(didClickCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    UIButton *enterBtn =[[UIButton alloc]init];
    [enterBtn setTitle:@"OK" forState:UIControlStateNormal];
    [enterBtn addTarget:self action:@selector(didClickOkBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enterBtn];
    
    UIButton *resetBtn =[[UIButton alloc]init];
    [resetBtn setTitle:@"reset" forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(didClickResetBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetBtn];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(10);
        make.bottom.mas_equalTo(self.view).mas_offset(-10);
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];
    
    [enterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).mas_offset(-10);
        make.bottom.mas_equalTo(cancelBtn);
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];
    
    [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(enterBtn);
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).mas_offset(kEdwNavBarStatuBarHeight);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(cancelBtn.mas_top);
    }];
    
    [cropView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(scrollView);
        make.centerX.mas_equalTo(scrollView);
        make.size.mas_equalTo(CGSizeMake(kEdwScreenWidth - 24, (kEdwScreenWidth - 24)*9/16));
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(scrollView);
        make.width.mas_equalTo(scrollView);
        make.height.mas_equalTo(scrollView.mas_width).multipliedBy(self.image.size.height/self.image.size.width);
    }];
    
    [mohu1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(cropView.mas_top);
    }];
    
    [mohu2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(self.view);
        make.right.mas_equalTo(cropView.mas_left);
    }];
    
    [mohu3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(cropView.mas_bottom);
    }];
    
    [mohu4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(self.view);
        make.left.mas_equalTo(cropView.mas_right);
    }];
    
    [mengbanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cropView.mas_centerY);
        make.centerX.mas_equalTo(cropView);
        make.width.mas_equalTo(cropView);
        make.height.mas_equalTo(cropView.mas_width).multipliedBy(mengbanView.image.size.height/mengbanView.image.size.width);
    }];
    
    [self.view layoutIfNeeded];
    
    //算出最小比例
    //图片 宽 > 高  计算高度比例   截图比例是 宽：高 = 16：9
    CGFloat height = cropView.edw_width * self.image.size.height / self.image.size.width;
    if (height < cropView.edw_height) {
        self.minScale = cropView.edw_height / imageView.edw_height;
    }else{
        self.minScale = (imageView.edw_width - 24) / imageView.edw_width;
    }
    [scrollView setMinimumZoomScale:self.minScale];
    [scrollView setMaximumZoomScale:3];
    
    CGFloat insetTop = cropView.edw_top - scrollView.edw_top - imageView.edw_top;
    CGFloat insetBottom = self.scrollView.edw_bottom - cropView.edw_bottom + imageView.edw_top;
    [scrollView setContentInset:UIEdgeInsetsMake(insetTop, cropView.edw_left, insetBottom, kEdwScreenWidth - cropView.edw_right)];
    [scrollView setZoomScale:self.minScale];
    
//    self.minScale 为 1时，scrollView的ContentOffset为（0，0）可以让子视图居中，不为1需要计算。
    if (height < cropView.edw_height) {
        self.resetPoint = CGPointMake((imageView.edw_width - scrollView.edw_width) * 0.5,scrollView.contentOffset.y);
    }else{
        //将图片宽度与父视图scrollView宽度等比例计算  得出高度
        CGFloat height = scrollView.edw_width * self.image.size.height / self.image.size.width;
        //高度相减
        height = (imageView.edw_height - height) * 9 / 16;
        self.resetPoint = CGPointMake(scrollView.contentOffset.x,height);
    }
    
    [self updateVisible:NO];
    [self addShaperLayer];
}

//阴影
- (void)addShaperLayer
{
    CGMutablePathRef path = CGPathCreateMutableCopy([UIBezierPath bezierPathWithRect:CGRectMake(0, 0, kEdwScreenWidth, kEdwScreenHeight)].CGPath);
    
    UIBezierPath *cutBezierPath = [UIBezierPath bezierPathWithRect:self.cropView.frame];
    CGMutablePathRef cutPath = CGPathCreateMutableCopy(cutBezierPath.CGPath);
    CGPathAddPath(path, nil, cutPath);
    
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    shapeLayer.path = path;
    shapeLayer.fillColor = [UIColor colorWithWhite:0.1 alpha:0.6].CGColor;
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    [self.view.layer insertSublayer:shapeLayer below:self.mengbanView.layer];
    CGPathRelease(cutPath);
    CGPathRelease(path);
    
}

#pragma mark -- UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

//开始缩放
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    self.mengbanView.alpha = 0;
    self.mohu1.alpha = 0;
    self.mohu2.alpha = 0;
    self.mohu3.alpha = 0;
    self.mohu4.alpha = 0;
}

//缩放结束
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    [self showMengBanView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
}

//开始拖动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.mengbanView.alpha = 0;
    self.mohu1.alpha = 0;
    self.mohu2.alpha = 0;
    self.mohu3.alpha = 0;
    self.mohu4.alpha = 0;
}

//手指松开时触发
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate == NO){
        // scrollView已经完全静止
        [self showMengBanView];
    }
}

//减速停止的时候开始执行
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // scrollView已经完全静止
    [self showMengBanView];
}

- (void)didTapScrollView:(UITapGestureRecognizer *)tap{
    self.mengbanView.alpha = 0;
    self.mohu1.alpha = 0;
    self.mohu2.alpha = 0;
    self.mohu3.alpha = 0;
    self.mohu4.alpha = 0;
    [self showMengBanView];
}

- (void)showMengBanView{
    [UIView animateWithDuration:0.5 delay:1.0 options:0 animations:^{
        self.mengbanView.alpha = 1;
        self.mohu1.alpha = 1;
        self.mohu2.alpha = 1;
        self.mohu3.alpha = 1;
        self.mohu4.alpha = 1;
    } completion:nil];
}

#pragma mark -- action
- (void)didClickCancel:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didClickOkBtn:(UIButton *)sender{
    UIImage *img = [self cropImage];
    self.imgBlock(img);
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didClickResetBtn:(UIButton *)sender{
    [self updateVisible:YES];
}

- (void)updateVisible:(BOOL)animate{
    [self.scrollView setZoomScale:self.minScale animated:animate];
    [self.scrollView setContentOffset:self.resetPoint animated:animate];
}

// 裁剪图片
- (UIImage *)cropImage
{
    //算出截图位置相对图片的坐标
    CGRect rect = [self.view convertRect:self.cropView.frame toView:self.imageView];
    CGFloat scale = self.image.size.width / self.imageView.frame.size.width *
    self.imageView.transform.a;
    CGRect cropRect= CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
    
    CGImageRef sourceImageRef = [self.imageView.image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, cropRect);
    return [UIImage imageWithCGImage:newImageRef];
}

//处理图片（系统会对2M以上的图片旋转90，我们要还原）
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
