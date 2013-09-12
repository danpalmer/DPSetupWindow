//
//  DPAppDelegate.m
//  DPSetupWindow
//
//  Created by Dan Palmer on 05/10/2012.
//  Copyright (c) 2012 Dan Palmer. All rights reserved.
//

#import "DPAppDelegate.h"

#import "DPSetupWindow.h"

#import "DPFirstViewController.h"
#import "DPSecondViewController.h"
#import "DPThirdViewController.h"

@interface DPAppDelegate ()

@property (retain) DPSetupWindow *setupFlow;

@end

@implementation DPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	
	NSViewController *firstViewController = [[DPFirstViewController alloc] initWithNibName:@"DPFirstViewController" bundle:[NSBundle mainBundle]];
	NSViewController *secondViewController = [[DPSecondViewController alloc] initWithNibName:@"DPSecondViewController" bundle:[NSBundle mainBundle]];
	NSViewController *thirdViewController = [[DPThirdViewController alloc] initWithNibName:@"DPThirdViewController" bundle:[NSBundle mainBundle]];
	
	DPSetupWindow *setupFlow = [[DPSetupWindow alloc] initWithViewControllers:@[
								firstViewController,
								secondViewController,
								thirdViewController
	] completionHandler:^(BOOL completed) {
		if (!completed) {
			NSLog(@"Cancelled setup process");
		} else {
			NSLog(@"Completed setup process");
		}
		[[self setupFlow] orderOut:self];
	}];
	[setupFlow setBackgroundImage:[NSImage imageNamed:@"NSUserAccounts"]];
	[self setSetupFlow:setupFlow];
}

- (IBAction)showSetupSheet:(id)sender {
    [[self setupFlow] resetToZeroStage];
	[[NSApplication sharedApplication] beginSheet:[self setupFlow] modalForWindow:[self window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
}

- (IBAction)showSetupWindow:(id)sender {
    [[self setupFlow] resetToZeroStage];
	[[self setupFlow] makeKeyAndOrderFront:self];
}

@end
