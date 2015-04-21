//
//  ViewController.m
//  iosAPIHAck
//
//  Created by Tomas Kamarauskas on 20/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()

@end

@implementation ViewController

@synthesize activityManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![CMMotionActivityManager isActivityAvailable]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No atctivity" message:@"Nothing detected" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    activityManager = [CMMotionActivityManager new];
    [activityManager startActivityUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMMotionActivity *activity) {
        NSLog(@"The type of activity is %@", activity.description);
        [self performSelectorOnMainThread:@selector(updateActivity:) withObject:activity waitUntilDone:YES];
    }];
}

- (void)updateActivity:(CMMotionActivity*)activity{
    
    if (activity.walking) {
        _activityLabel.text = @"walking";
            }
    else{
        _activityLabel.text = @"unwalking";
        [self fetchImages];

    }

}

- (void)fetchImages{
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.instagram.com/v1/tags/walking/media/recent?access_token=32423874.0425678.ce6b198642fa4116893baddd7c5a9bcf"]];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary * arrayOfImages = [json valueForKey:@"data"];
        NSDictionary * allImages = [arrayOfImages valueForKey:@"images"];
        NSDictionary * standardImgs = [allImages valueForKey:@"standard_resolution"];
        NSArray * imageUrls = [standardImgs valueForKey:@"url"];
        NSLog(@" the images has %lu elements and they are: %@", (unsigned long)imageUrls.count, imageUrls);
        
    }];
    
    [task resume];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
