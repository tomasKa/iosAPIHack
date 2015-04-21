//
//  ViewController.m
//  iosAPIHAck
//
//  Created by Tomas Kamarauskas on 20/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import "ViewController.h"
#import "photoCellCollectionViewCell.h"



@interface ViewController ()
{
    NSMutableArray * imagesArray;
    NSString *currentActivity;
    NSString *previousActivity;
}
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
    
    imagesArray = [[NSMutableArray alloc] init];
    currentActivity = [NSString new];
    previousActivity = [NSString new];

    //Collection view
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    
}
- (void)updateActivity:(CMMotionActivity*)activity{
    previousActivity = currentActivity;
    
    if (activity.walking) {
        currentActivity = @"walking";
    }
    else if (activity.cycling){
        currentActivity = @"cycling";
    }
    else if (activity.running){
     currentActivity =@"running";
    }
    
    else if (activity.automotive){
        currentActivity = @"driving";
    }
    else if (activity.stationary){
        currentActivity = @"lazy";
    }
    else if (activity.unknown){
        currentActivity = @"unsure";
    }
    
    if (![previousActivity isEqualToString:currentActivity]) {
        [self fetchImagesForActivity:currentActivity];
        [imagesArray removeAllObjects];
        
    }
    NSLog(@"previous: %@", previousActivity);
    NSLog(@"current: %@", currentActivity);
}

- (void)fetchImagesForActivity:(NSString*)activity{

    NSString *urlStringForActivity = [NSString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?access_token=32423874.0425678.ce6b198642fa4116893baddd7c5a9bcf", activity];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStringForActivity]];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary * dataObjectsDict = [json valueForKey:@"data"];
        NSDictionary * allImagesDictioannaries = [dataObjectsDict valueForKey:@"images"];
        NSDictionary * standardImgs = [allImagesDictioannaries valueForKey:@"thumbnail"];
        NSArray * imageUrls = [standardImgs valueForKey:@"url"];
        
        for (NSString *stringURL in imageUrls){
            
            [self performSelectorOnMainThread:@selector(addImageWithUrlString:) withObject:[NSURL URLWithString:stringURL] waitUntilDone:YES];
        }
    }];
    [task resume];
}


- (void)addImageWithUrlString:(NSURL*)url{
    
    self.activityLabel.text = currentActivity;
    if (imagesArray.count< 20){
        
        UIImage * imageFromURL = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        [imagesArray addObject:imageFromURL];
        [self performSelectorOnMainThread:@selector(reloadCollectionView) withObject:nil waitUntilDone:YES];
    }
}

- (void) reloadCollectionView{
    
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
        return imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
       photoCellCollectionViewCell *cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    if(indexPath.item < imagesArray.count){
        
        cell.imageView.image = [imagesArray objectAtIndex:indexPath.item];
    }
    
    
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
