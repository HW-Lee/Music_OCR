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
#import "MBProgressHUD.h"
#import "StaffIndicationViewController.h"

#define MODE_CUSTOM NO
#define MODE_ENGINEER YES

@interface MainViewController ()

@property MBProgressHUD *myProgress;
@property BOOL mode;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _mode = MODE_CUSTOM;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"StaffIndication"]) {
        StaffIndicationViewController *controller =
            (StaffIndicationViewController *)segue.destinationViewController;
        controller.imgData = [MatTools resize2DMat:[MatTools imreadRGBFromUIImage:_retrievedImg.image]
                                           ByScale:.6];
        if ([sender isKindOfClass:[NSArray class]]) {
            controller.staffInfoArr = sender;
        }
    }
}

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
    static cv::Mat mat1;
    static NSArray *infoArr;
    _myProgress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_myProgress];
    [_myProgress setLabelText:@"Processing..."];
    [_myProgress showAnimated:YES
          whileExecutingBlock:^{
              cv::Mat imgMat = [MatTools imreadRGBFromUIImage:_retrievedImg.image];
              imgMat = [MatTools resize2DMat:imgMat ByScale:.6];
              infoArr = [StaffAnalyzer findStafflinesWithImageData:imgMat];
          } completionBlock:^{
              [_myProgress removeFromSuperview];
              _myProgress = nil;
              for (int i = 0; i < [infoArr count]; i++) {
                  NSLog(@"Object %d", i);
                  [[infoArr objectAtIndex:i] info];
              }
              [self performSegueWithIdentifier:@"StaffIndication" sender:infoArr];
          }];
}

- (IBAction)toggleMode:(id)sender {
}

@end
