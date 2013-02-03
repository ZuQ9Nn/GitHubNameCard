//
//  GitHubNameCardViewController.h
//  GitHubNameCard
//
//  Created by kazuki_tanaka on 2013/02/03.
//  Copyright (c) 2013年 ZuQ9Nn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UAGithubEngine.h"

@interface GitHubNameCardViewController : UIViewController

- (id)initWithResponse:(id)response uaGithubEngene:(UAGithubEngine *)engine;

@end
