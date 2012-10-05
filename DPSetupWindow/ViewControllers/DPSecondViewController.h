//
//  DPSecondViewController.h
//  DPSetupWindow
//
//  Created by Dan Palmer on 05/10/2012.
//  Copyright (c) 2012 Dan Palmer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DPSetupWindow.h"

@interface DPSecondViewController : NSViewController <DPSetupWindowStageViewController>

@property (assign) IBOutlet NSButton *checkBox;

@property (readwrite) BOOL canContinue;
@property (readwrite) BOOL canGoBack;

@end
