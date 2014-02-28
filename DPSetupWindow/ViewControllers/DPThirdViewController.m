//
//  DPThirdViewController.m
//  DPSetupWindow
//
//  Created by Dan Palmer on 05/10/2012.
//  Copyright (c) 2012 Dan Palmer. All rights reserved.
//

#import "DPThirdViewController.h"

@implementation DPThirdViewController

- (NSString *)continueButtonTitle {
	return @"Finish";
}

- (void) resetToInitialState{
    
    [_usernameTextField setStringValue:@""];
    [_passwordTextField setStringValue:@""];
}

@end
