//
//  DPSecondViewController.m
//  DPSetupWindow
//
//  Created by Dan Palmer on 05/10/2012.
//  Copyright (c) 2012 Dan Palmer. All rights reserved.
//

#import "DPSecondViewController.h"

#import "DPFirstViewController.h"

@interface DPSecondViewController ()

@property (nonatomic, weak) DPSetupWindow *setupWindow;

@end

@implementation DPSecondViewController

@synthesize canContinue;
@synthesize canGoBack;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
    }
    
    return self;
}

- (void)willProgressToNextStage {
	DPFirstViewController *anotherFirstViewController = [[DPFirstViewController alloc] initWithNibName:@"DPFirstViewController" bundle:[NSBundle mainBundle]];
	[[self setupWindow] addNextViewController:anotherFirstViewController];
}

@end
