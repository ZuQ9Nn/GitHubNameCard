//
//  GitHubNameCardViewController.m
//  GitHubNameCard
//
//  Created by kazuki_tanaka on 2013/02/03.
//  Copyright (c) 2013年 ZuQ9Nn. All rights reserved.
//

#import "GitHubNameCardViewController.h"

#import "FollowUserNameCardViewController.h"

#import <GameKit/GameKit.h>

@interface GitHubNameCardViewController ()
    <GKPeerPickerControllerDelegate>

@property (nonatomic, strong) NSArray *response;
@property (nonatomic, strong) UAGithubEngine *engine;
@property (nonatomic, strong) GKSession *session;

@end

@implementation GitHubNameCardViewController

- (id)initWithResponse:(id)response uaGithubEngene:(UAGithubEngine *)engine
{
    self = [super init];

    if (self) {
        self.response = (NSArray *)response;
        self.engine = engine;
    }

    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSDictionary *dict = [self.response objectAtIndex:0];

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 250, 60)];
    nameLabel.font = [UIFont boldSystemFontOfSize:30];
    nameLabel.text = ([dict objectForKey:@"name"] != NULL) ? [dict objectForKey:@"name"] : @"";
    [self.view addSubview:nameLabel];

    UILabel *loginLabel  = [[UILabel alloc] initWithFrame:
                            CGRectMake(10, nameLabel.frame.origin.y + nameLabel.frame.size.height + 5, 250, 30)];
    loginLabel.textColor = [UIColor darkGrayColor];
    loginLabel.text = ([dict objectForKey:@"login"] != NULL) ? [dict objectForKey:@"login"] : @"";
    [self.view addSubview:loginLabel];

    UILabel *emailLabel = [[UILabel alloc] initWithFrame:
                           CGRectMake(10, loginLabel.frame.origin.y + loginLabel.frame.size.height + 5, 250, 30)];
    emailLabel.font = [UIFont systemFontOfSize:15];
    emailLabel.text = ([dict objectForKey:@"email"] != NULL) ? [NSString stringWithFormat:@"E-mail : %@",[dict objectForKey:@"email"]] : @"";
    [self.view addSubview:emailLabel];

    UILabel *companyLabel = [[UILabel alloc] initWithFrame:
                             CGRectMake(10, emailLabel.frame.origin.y + emailLabel.frame.size.height + 20, 250, 30)];
    companyLabel.font = [UIFont boldSystemFontOfSize:20];

    if ([dict objectForKey:@"company"] == nil) {
        NSLog(@"AAAAAA = %@",[dict objectForKey:@"company"]);
    }
    
    //companyLabel.text = ([dict objectForKey:@"company"] != NULL) ? [dict objectForKey:@"company"] : @"";
    [self.view addSubview:companyLabel];

    UILabel *locationLabel = [[UILabel alloc] initWithFrame:
                              CGRectMake(10, companyLabel.frame.origin.y + companyLabel.frame.size.height + 5, 400, 30)];
    locationLabel.font = [UIFont systemFontOfSize:15];
    locationLabel.text = ([dict objectForKey:@"location"] != NULL) ? [dict objectForKey:@"location"] : @"";
    [self.view addSubview:locationLabel];

    if ([dict objectForKey:@"avatar_url"] != NULL) {

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width + 25,
                                                                           nameLabel.frame.origin.y + 10, 150, 150)];
        imageView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:imageView];

        UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] init];
        ai.frame = CGRectMake(0, 0, 50, 50);
        ai.center = imageView.center;
        ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self.view addSubview:ai];
        [ai startAnimating];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSString *imageUrl = [dict objectForKey:@"avatar_url"];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];

            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = image;
                [ai stopAnimating];
                [ai removeFromSuperview];
            });
        });
    }

    UISwipeGestureRecognizer* swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftGesture:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeLeftGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleSwipeLeftGesture:(UISwipeGestureRecognizer *)sender
{
    GKPeerPickerController* picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [picker show];
}

- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    [session setDataReceiveHandler:self withContext:nil];
    self.session = session;

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.response];

    NSError* error = nil;
    [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];

    if (error)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:nil];

        [alertView show];
    }

    picker.delegate = nil;
    [picker dismiss];
    picker = nil;
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    picker.delegate = nil;
    [picker dismiss];
    picker = nil;
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    __block NSArray *list = [NSKeyedUnarchiver unarchiveObjectWithData:data];;

    NSDictionary *dic = [list objectAtIndex:0];
    
    [self.engine follow:[dic objectForKey:@"login"] success:^(BOOL resutl){

        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{

                             [self.view setFrame:CGRectMake(self.view.frame.origin.x - self.view.frame.size.width,
                                                             0,
                                                             self.view.frame.size.width,
                                                             self.view.frame.size.height)];

                         } completion:^(BOOL finished){

                             
                             [UIView animateWithDuration:0.5f
                                                   delay:0.0f
                                                 options:UIViewAnimationOptionAllowUserInteraction
                                              animations:^{

                                                  for (UIView *view in self.view.subviews) {
                                                      [view removeFromSuperview];
                                                  }
                                                  
                                                  FollowUserNameCardViewController *controller = [[FollowUserNameCardViewController alloc] initWithResponse:list uaGithubEngene:self.engine];

                                                  [self.view addSubview:controller.view];

                                                  [self.view setFrame:CGRectMake(self.view.frame.size.width + self.view.frame.origin.x,
                                                                                 0,
                                                                                 self.view.frame.size.width,
                                                                                 self.view.frame.size.height)];
                                                  
                             } completion:^(BOOL finished){
                                 
                                }];
                         }];


    } failure:^(NSError *error){

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
    }];
}

@end
