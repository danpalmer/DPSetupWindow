//
//  DPFirstViewController.m
//  DPSetupWindow
//
//  Created by Dan Palmer on 05/10/2012.
//  Copyright (c) 2012 Dan Palmer. All rights reserved.
//

#import "DPFirstViewController.h"
#import "DPSecondViewController.h"

@implementation DPFirstViewController

- (IBAction)changeAddSecondController:(id)sender {
    
    _needToAddSecondViewController = ([sender state] == NSOnState);
    if (_needToAddSecondViewController) {
        
        DPSecondViewController *second = [[DPSecondViewController alloc] initWithNibName:@"DPSecondViewController"
                                                                                  bundle:[NSBundle mainBundle]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDPNotification_addNextViewController
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:second
                                                                                               forKey:kDPNotification_key_viewController]];
    }else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDPNotification_deleteViewController
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:[DPSecondViewController class]
                                                                                               forKey:kDPNotification_key_viewControllerClass]];
    }
}

@end
