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
    //NSViewController *secondViewController = [[DPSecondViewController alloc] initWithNibName:@"DPSecondViewController" bundle:[NSBundle mainBundle]];
    NSViewController *thirdViewController = [[DPThirdViewController alloc] initWithNibName:@"DPThirdViewController" bundle:[NSBundle mainBundle]];
    
    void (^finished)(BOOL) = ^(BOOL completed){
        if (!completed) {
            NSLog(@"Cancelled setup process");
            
            [self.window endSheet:[self setupFlow] returnCode:NSModalResponseCancel];
        } else {
            NSLog(@"Completed setup process");
            
            [self.window endSheet:[self setupFlow] returnCode:NSModalResponseOK];
        }
        
        [[self setupFlow]setIsVisible:NO];
    };
    
    DPSetupWindow *setupFlow = [[DPSetupWindow alloc] initWithViewControllers:@[
                                                                                firstViewController,
                                                                                //secondViewController,
                                                                                thirdViewController
                                                                                ] completionHandler:^(BOOL completed) {
                                                                                    finished(completed);
                                                                                }];
    
    [setupFlow setBackgroundImage:[NSImage imageNamed:@"NSUserAccounts"]];
    [self setSetupFlow:setupFlow];
}

- (IBAction)showSetupSheet:(id)sender {
    [[self setupFlow] resetToZeroStage];
    
    [self.window beginSheet:[self setupFlow]  completionHandler:^(NSModalResponse returnCode) {
        switch (returnCode) {
            case NSModalResponseOK:
                NSLog(@"Finish button tapped in Custom Sheet");
                break;
            case NSModalResponseCancel:
                NSLog(@"Cancel button tapped in Custom Sheet");
                break;
                
            default:
                break;
        }
    }];
}

- (IBAction)showSetupWindow:(id)sender {
    [[self setupFlow] resetToZeroStage];
    [[self setupFlow] makeKeyAndOrderFront:self];
}

@end
