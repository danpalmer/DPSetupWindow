//
//  DPFirstViewController.h
//  DPSetupWindow
//
//  Created by Dan Palmer on 05/10/2012.
//  Copyright (c) 2012 Dan Palmer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DPSetupWindow.h"

@interface DPFirstViewController : NSViewController <DPSetupWindowStageViewController>

@property(nonatomic, assign) BOOL needToAddSecondViewController;
- (IBAction)changeAddSecondController:(id)sender;
@end
