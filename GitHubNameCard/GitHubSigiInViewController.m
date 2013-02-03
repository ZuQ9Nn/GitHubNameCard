//
//  GitHubSigiInViewController.m
//  GitHubNameCard
//
//  Created by kazuki_tanaka on 2013/02/03.
//  Copyright (c) 2013年 ZuQ9Nn. All rights reserved.
//

#import "GitHubSigiInViewController.h"

#import "GitHubNameCardViewController.h"

#import "UAGithubEngine.h"

@interface GitHubSigiInViewController ()
    <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *userNameTextField;
@property (nonatomic, strong) UITextField *passwrodTextField;

@end

@implementation GitHubSigiInViewController

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

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 100, 100)];
    imageView.image = [UIImage imageNamed:@"octocat.gif"];
    [self.view addSubview:imageView];

    self.userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.height - 200) / 2, 15, 200, 30)];
    self.userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.userNameTextField.placeholder = @"Username or Email";
    self.userNameTextField.delegate = self;
    [self.view addSubview:self.userNameTextField];

    self.passwrodTextField = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.height - 200) / 2,
                                                                           self.userNameTextField.frame.origin.y + self.userNameTextField.frame.size.height + 10, 200, 30)];
    self.passwrodTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwrodTextField.placeholder = @"Password";
    self.passwrodTextField.secureTextEntry = YES;
    self.passwrodTextField.delegate = self;
    [self.view addSubview:self.passwrodTextField];

    UIButton *signInButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [signInButton setTitle:@"Sign In" forState:UIControlStateNormal];
    [signInButton setFrame:CGRectMake(self.userNameTextField.frame.origin.x, self.passwrodTextField.frame.origin.y + self.passwrodTextField.frame.size.height + 10, 73, 44)];
    [signInButton addTarget:self action:@selector(signInButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signInButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIButton action method
- (void)signInButtonClick:(UIButton *)button
{
    UAGithubEngine *engine = [[UAGithubEngine alloc] initWithUsername:self.userNameTextField.text
                                                             password:self.passwrodTextField.text
                                                     withReachability:YES];

    [engine userWithSuccess:^(id response) {

        GitHubNameCardViewController *controller =
            [[GitHubNameCardViewController alloc] initWithResponse:response uaGithubEngene:engine];
        [self presentViewController:controller animated:NO completion:NULL];

    } failure:^(NSError *error) {

        self.userNameTextField.text = @"";
        self.passwrodTextField.text = @"";

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"cancel"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }];
}

@end
