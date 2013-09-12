//
//  DPThirdViewController.h
//  DPSetupWindow
//
//  Created by Dan Palmer on 05/10/2012.
//  Copyright (c) 2012 Dan Palmer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DPSetupWindow.h"

@interface DPThirdViewController : NSViewController <DPSetupWindowStageViewController>

@property (weak) IBOutlet NSSecureTextField *usernameTextField;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
@end
