//
//  ViewController.m
//  imageCrop
//
//  Created by EdwardCheng on 2018/11/1.
//  Copyright © 2018年 EdwardCheng. All rights reserved.
//

#import "ViewController.h"
#import "EdwImageCropVC.h"

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.layer.borderWidth = 0.5;
    self.imageView.layer.borderColor = [UIColor blackColor].CGColor;
}

- (IBAction)didClickCameraBtn:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    picker.allowsEditing = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)didClickAlbum:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark -- UINavigationControllerDelegate, UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:NO completion:^{
        EdwImageCropVC *imgCropVC = [EdwImageCropVC new];
        imgCropVC.image = image;
        imgCropVC.imgBlock = ^(UIImage *img) {
            self.imageView.image = img;
        };
        [self.navigationController pushViewController:imgCropVC animated:YES];
    }];
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
