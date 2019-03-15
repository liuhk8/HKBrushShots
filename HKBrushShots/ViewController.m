//
//  ViewController.m
//  HKBrushShots
//
//  Created by 刘华坤 on 2019/3/15.
//  Copyright © 2019 刘华坤. All rights reserved.
//

#import "ViewController.h"

#import "HKCropView.h"
#import "HKLineView.h"

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,HKScreenShotImageViewRectDelegate>
{
    UIImagePickerController *_imagePicker;
}
// 原始选取的图片
@property (weak, nonatomic) IBOutlet UIImageView *originalImageView;
// 裁剪出来的图片
@property (weak, nonatomic) IBOutlet UIImageView *screenShotImageView;

@property (nonatomic, strong) HKCropView *cropView;
@property (nonatomic, strong) HKLineView *lineView;

@end

@implementation ViewController

// 画笔的属性在这里修改
- (HKLineView *)lineView {
    if (!_lineView) {
        _lineView = [[HKLineView alloc] init];
        _lineView.backgroundColor = [UIColor blackColor];
        _lineView.alpha = 0.5;
        _lineView.delegate = self;
        _lineView.currentLineColor = [UIColor whiteColor];
        _lineView.currentLineWidth = 20.0;
    }
    
    return _lineView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initObject];
}

- (void)initObject {
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
}

// 照片
- (IBAction)photoAction:(UIButton *)sender {
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //[self presentModalViewController:imagePicker animated:YES];
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

// 拍照
- (IBAction)cameraAction:(UIButton *)sender {
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //[self presentModalViewController:imagePicker animated:YES];
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

// 修复照片的方向问题
- (UIImage *)fixOrientation:(UIImage *)aImage {
    if (aImage.imageOrientation == UIImageOrientationUp)
        
        return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation)
    {
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
    
    switch (aImage.imageOrientation)
    {
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
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

#pragma Delegate method UIImagePickerControllerDelegate
//图像选取器的委托方法，选完图片后回调该方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    // 从相册直接获取的图片存在方向问题，适配一下
    UIImage *fixImage = [self fixOrientation:image];
    
    // 将获取到的原始图片展示出来
    if (self.originalImageView.image) {
        self.originalImageView.image = nil;
    }
    self.originalImageView.image = fixImage;
    
    // 在原始图片上蒙上一层半透黑底背景
    self.lineView.frame = self.originalImageView.frame;
    [self.view addSubview:self.lineView];
}

#pragma mark HKScreenShotImageViewRectDelegate
// 代理回调手指划出图片的区域rect
- (void)getScreenShotImageViewRect:(CGRect)rect {
    UIImage *screenShotImage = [self clipWithImageRect:rect clipImage:self.originalImageView];
    self.screenShotImageView.image = screenShotImage;
}

// 截图
- (UIImage *)clipWithImageRect:(CGRect)clipRect clipImage:(UIImageView *)orgiImageView {
    if (!_cropView) {
        // 初始化
        _cropView = [[HKCropView alloc] initWithImageView:orgiImageView];
    }
    
    UIImage *newImage = [_cropView getClipImageRect:clipRect];
    [_cropView removeFromSuperview];
    _cropView = nil;
    return newImage;
}


@end
