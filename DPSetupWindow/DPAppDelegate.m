//
//  DPAppDelegate.m
//  DPSetupWindow
//
//  Created by Dan Palmer on 05/10/2012.
//  Copyright (c) 2012 Dan Palmer. All rights reserved.
//

#import "DPAppDelegate.h"

#import "DPSetupWindow.h"

@interface DPAppDelegate ()

@property (retain) DPSetupWindow *setupFlow;

@end

@implementation DPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	DPSetupWindow *setupFlow = [[DPSetupWindow alloc] initWithViewControllers:@[] completionHandler:^(BOOL completed) {
		if (!completed) {
			NSLog(@"Cancelled setup process");
		} else {
			NSLog(@"Completed setup process");
		}
		[[self setupFlow] orderOut:self];
	}];
	[self setSetupFlow:setupFlow];
}

- (IBAction)showSetupSheet:(id)sender {
	[[NSApplication sharedApplication] beginSheet:[self setupFlow] modalForWindow:[self window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
}

- (IBAction)showSetupWindow:(id)sender {
	[[self setupFlow] makeKeyAndOrderFront:self];
}

@end
