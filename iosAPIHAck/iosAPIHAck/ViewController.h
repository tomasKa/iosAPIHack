//
//  ViewController.h
//  iosAPIHAck
//
//  Created by Tomas Kamarauskas on 20/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController : UIViewController

@property (nonatomic, strong)CMMotionActivityManager *activityManager;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;



@end

