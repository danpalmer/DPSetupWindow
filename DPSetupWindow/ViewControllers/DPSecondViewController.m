//
//  DPSecondViewController.m
//  DPSetupWindow
//
//  Created by Dan Palmer on 05/10/2012.
//  Copyright (c) 2012 Dan Palmer. All rights reserved.
//

#import "DPSecondViewController.h"

#import "DPFirstViewController.h"

@implementation DPSecondViewController

@synthesize canContinue;
@synthesize canGoBack;

/*
- (void)willProgressToNextStage {
    
	DPFirstViewController *anotherFirstViewController = [[DPFirstViewController alloc] initWithNibName:@"DPFirstViewController" bundle:[NSBundle mainBundle]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDPNotification_addNextViewController
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:anotherFirstViewController
                                                                                           forKey:kDPNotification_key_viewController]];
}
*/

- (void)resetToInitialState{
    
    [self setCanContinue:NO];
    [self setCanGoBack:NO];
}

@end
