//
//  MainViewController.m
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import "MainViewController.h"
#import "MatTools.h"
#import "ImageTools.h"
#import "StaffAnalyzer.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    cv::Mat mat = cv::Mat::eye(100, 100, CV_8UC1)*255;
    [_retrievedImg setImage:[MatTools UIImageFromCVMat:mat]];
    [_retrievedImg setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [_retrievedImg setImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
}

- (IBAction)retrieveFromPhotosBtnClick:(id)sender {
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:_picker animated:YES completion:nil];
}

- (IBAction)startBtnClick:(id)sender {
    
    cv::Mat mat1 = [MatTools imreadGrayFromUIImage:_retrievedImg.image];
    cv::Mat mat2 = [MatTools imreadRGBFromUIImage:_retrievedImg.image];
    cv::Mat mat3 = [MatTools normalize2DMat:[MatTools resize2DMat:mat1 ByScale:.6]];
    mat3 = [MatTools binaryResultsComparedTo2DMat:mat3 WithLogic:@"<" WithValue:.6];
    mat3.convertTo(mat3, CV_8UC1);
    mat3 *= 255;
    std::vector<int> xx(mat2.cols, cvRound(mat2.rows/2.0)-10);
    std::vector<int> yy(mat2.cols, 0);
    for (int i = 0; i < yy.size(); i++)
        yy[i] = i;
    int l = 1;
    for (int i = 0; i < 2*l; i++) {
        mat2 = [ImageTools markImage3Data:mat2
                                WithXData:std::vector<int>(mat2.cols, cvRound(mat2.rows/2.0)-l+i)
                                WithYData:yy
                               WithColorR:0
                               WithColorG:255
                               WithColorB:0];
    }
//    NSLog(@"Image size: %d * %d * %zu", mat1.cols, mat1.rows, mat1.elemSize());
//    NSLog(@"Data type: %@", [MatTools stringWithType:mat1.type()]);
//    NSLog(@"Sampled Data: %d", mat1.at<uchar>(100, 100));
    NSLog(@"Image size: %d * %d * %zu", mat2.cols, mat2.rows, mat2.elemSize());
    NSLog(@"Data type: %@", [MatTools stringWithType:mat2.type()]);
    NSLog(@"Sampled Data: [%d, %d, %d]", (uchar)mat2.at<cv::Vec3b>(cvRound(mat2.rows/2.0), 10)[0],
          (uchar)mat2.at<cv::Vec3b>(cvRound(mat2.rows/2.0), 10)[1],
          (uchar)mat2.at<cv::Vec3b>(cvRound(mat2.rows/2.0), 10)[2]);
    [_retrievedImg setImage:[MatTools UIImageFromCVMat:mat2]];
}

@end
