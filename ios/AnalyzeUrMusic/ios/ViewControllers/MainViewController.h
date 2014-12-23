//
//  MainViewController.h
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property UIImagePickerController* picker;

@property (weak, nonatomic) IBOutlet UIImageView *retrievedImg;
- (IBAction)retrieveFromPhotosBtnClick:(id)sender;
- (IBAction)startBtnClick:(id)sender;

@end
