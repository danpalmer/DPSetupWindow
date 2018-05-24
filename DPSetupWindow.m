//
//  DPSetupWindow.m
//  DPSetupWindow
//
//  Created by Dan Palmer on 05/10/2012.
//  Copyright (c) 2012 Dan Palmer. All rights reserved.
//

#import "DPSetupWindow.h"

@interface DPSetupWindow ()

@property (retain) NSImageView *imageView;
@property (retain) NSBox *contentBox;

@property (copy) void(^completionHandler)(BOOL);
@property (assign) NSViewController *currentViewController;

@end

@implementation DPSetupWindow

- (id)initWithViewControllers:(NSArray *)viewControllers completionHandler:(void (^)(BOOL completed))completionHandler {
    
    int initial_x = [[NSScreen mainScreen] frame].size.width / 2 - 290;
    int initial_y = [[NSScreen mainScreen] frame].size.height / 2 - 250;
    
    NSRect contentRect = NSMakeRect(initial_x, initial_y, 580, 500);
    
    self = [super initWithContentRect:contentRect styleMask:(NSTitledWindowMask|NSClosableWindowMask) backing:NSBackingStoreBuffered defer:YES];
    if (self == nil) return nil;
    
    if (!viewControllers || [viewControllers count] == 0) return nil;
    if (!completionHandler) return nil;
    
    currentStage = -1;
    _animates = YES;
    _funnelsRepresentedObjects = NO;
    [self setViewControllers:viewControllers];
    [self setCompletionHandler:completionHandler];
    
    [self setContentView:[self initialiseContentViewForRect:contentRect]];
    [self next:nil];
    [self addNotifications];
    
    return self;
}

- (void)dealloc{
    
    [self removeNotifications];
}

- (NSView *)initialiseContentViewForRect:(NSRect)contentRect {
    NSView *contentView = [[NSView alloc] initWithFrame:contentRect];
    
    _cancelButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, 13, 97, 32)];
    [_cancelButton setBezelStyle:NSRoundedBezelStyle];
    [_cancelButton setTarget:self];
    [_cancelButton setAction:@selector(cancel:)];
    [_cancelButton setTitle:@"Cancel"];
    [_cancelButton setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
    [contentView addSubview:_cancelButton];
    
    _backButton = [[NSButton alloc] initWithFrame:NSMakeRect(372, 13, 97, 32)];
    [_backButton setBezelStyle:NSRoundedBezelStyle];
    [_backButton setTarget:self];
    [_backButton setAction:@selector(back:)];
    [_backButton setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
    [contentView addSubview:_backButton];
    
    _nextButton = [[NSButton alloc] initWithFrame:NSMakeRect(469, 13, 97, 32)];
    [_nextButton setBezelStyle:NSRoundedBezelStyle];
    [_nextButton setTarget:self];
    [_nextButton setAction:@selector(next:)];
    [_nextButton setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
    [contentView addSubview:_nextButton];
    
    _imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(10, 60, 320, 320)];
    [_imageView setAlphaValue:0.3];
    [_imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [_imageView setImage:[[NSApplication sharedApplication] applicationIconImage]];
    [contentView addSubview:_imageView];
    
    _contentBox = [[NSBox alloc] initWithFrame:NSMakeRect(10, 60, 560, 420)];
    [_contentBox setTitlePosition:(NSNoTitle)];
    [contentView addSubview:_contentBox];
    
    return contentView;
}

- (void) addNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kDPNotification_addNextViewController
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSDictionary *userInfo = [note userInfo];
                                                      
                                                      NSViewController<DPSetupWindowStageViewController> *viewController = nil;
                                                      
                                                      viewController = [userInfo objectForKey:kDPNotification_key_viewController];
                                                      
                                                      if (viewController) {
                                                          
                                                          NSMutableArray *newViewControllers = [[self viewControllers] mutableCopy];
                                                          [newViewControllers insertObject:viewController atIndex:(currentStage + 1)];
                                                          [self setViewControllers:[NSArray arrayWithArray:newViewControllers]];
                                                      }
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kDPNotification_addFinalViewController
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSDictionary *userInfo = [note userInfo];
                                                      
                                                      NSViewController<DPSetupWindowStageViewController> *viewController = nil;
                                                      
                                                      viewController = [userInfo objectForKey:kDPNotification_key_viewController];
                                                      
                                                      if (viewController) {
                                                          
                                                          NSArray *newViewControllers = [[self viewControllers] arrayByAddingObject:viewController];
                                                          [self setViewControllers:newViewControllers];
                                                      }
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kDPNotification_deleteViewController
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSDictionary *userInfo = [note userInfo];
                                                      
                                                      id mustDeleteController = nil;
                                                      Class mustDeleteClass = nil;
                                                      mustDeleteClass = [userInfo objectForKey:kDPNotification_key_viewControllerClass];
                                                      
                                                      NSMutableArray *viewControllers = [[self viewControllers] mutableCopy];
                                                      for (id controller in viewControllers)
                                                          if ([controller class]==mustDeleteClass)
                                                              mustDeleteController = controller;
                                                      
                                                      if (mustDeleteController &&
                                                          mustDeleteController != [viewControllers objectAtIndex:currentStage]) {
                                                          
                                                          @try {
                                                              [self deregisterObserversForViewController:mustDeleteController];
                                                          }
                                                          @catch (NSException *exception) {}
                                                          
                                                          [viewControllers removeObject:mustDeleteController];
                                                          [self setViewControllers:[NSArray arrayWithArray:viewControllers]];
                                                      }
                                                  }];
}

- (void) removeNotifications{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kDPNotification_addNextViewController
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kDPNotification_addFinalViewController
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kDPNotification_deleteViewController
                                                  object:nil];
}

#pragma mark -
#pragma mark Customisation

- (void)setBackgroundImage:(NSImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    [[self imageView] setImage:backgroundImage];
}

- (NSImage *)backgroundImage {
    return _backgroundImage;
}

#pragma mark -
#pragma mark Flow Control

typedef enum {
    DPSetupWindowNextDirection = 1,
    DPSetupWindowBackDirection = -1
} DPSetupWindowDirection;

- (void)progressToNextStage {
    [self shift:DPSetupWindowNextDirection];
}

- (void)revertToPreviousStage {
    [self shift:DPSetupWindowBackDirection];
}

- (void)resetToZeroStage{
    
    for (id viewController in [self viewControllers])
        if ([viewController respondsToSelector:@selector(resetToInitialState)])
            [viewController resetToInitialState];
    
    NSViewController<DPSetupWindowStageViewController> *previousViewController = nil;
    if(currentStage>0 &&
       currentStage<=[[self viewControllers] count])
        
        previousViewController = [[self viewControllers] objectAtIndex:currentStage];
    else
        return;
    
    
    //rewind
    currentStage = 0;
    NSViewController<DPSetupWindowStageViewController> *nextViewController = [[self viewControllers] objectAtIndex:currentStage];
    NSView *view = [nextViewController view];
    
    if(nextViewController != nil && [nextViewController respondsToSelector:@selector(willProgressToNextStage)]) {
        [nextViewController willProgressToStage];
    }
    
    void (^finished)() = ^{
        if(previousViewController != nil && [previousViewController respondsToSelector:@selector(didProgressToNextStage)]) {
            [previousViewController didProgressToNextStage];
        }
        
        if(nextViewController != nil && [nextViewController respondsToSelector:@selector(didProgressToStage)]) {
            [nextViewController didProgressToStage];
        }
    };
    
    [view setFrame:NSMakeRect(0, 0, 560, 420)];
    if (previousViewController)
        [[previousViewController view] removeFromSuperviewWithoutNeedingDisplay];
    
    [[self contentBox] addSubview:view];
    finished();
    
    
    [self registerObserversForPreviousViewController:previousViewController nextViewController:nextViewController];
    [self recalculateButtonEnabledStates];
    [self resetButtonTitles];
}

- (void)next:(id)sender {
    [self shift:DPSetupWindowNextDirection];
}

- (void)back:(id)sender {
    [self shift:DPSetupWindowBackDirection];
}

- (void)shift:(DPSetupWindowDirection)direction {
    
    if ((currentStage == [[self viewControllers] count] && direction == DPSetupWindowNextDirection) ||
        (currentStage == 0 && direction == DPSetupWindowBackDirection)) {
        return;
    }
    
    NSViewController<DPSetupWindowStageViewController> *previousViewController = nil;
    if (currentStage >= 0 && currentStage < [[self viewControllers] count]) {
        previousViewController = [[self viewControllers] objectAtIndex:currentStage];
    }
    
    if (direction == DPSetupWindowNextDirection) {
        if(previousViewController != nil && [previousViewController respondsToSelector:@selector(willProgressToNextStage)]) {
            [previousViewController willProgressToNextStage];
        }
    } else if (direction == DPSetupWindowBackDirection) {
        if(previousViewController != nil && [previousViewController respondsToSelector:@selector(willRevertToPreviousStage)]) {
            [previousViewController willRevertToPreviousStage];
        }
    }
    
    NSInteger nextStage = currentStage + direction;
    if (nextStage == [[self viewControllers] count]) {
        //[self deregisterObserversForViewController:previousViewController];
        [self completionHandler](YES);
        return;
    }
    
    NSViewController<DPSetupWindowStageViewController> *nextViewController = [[self viewControllers] objectAtIndex:nextStage];
    NSView *view = [nextViewController view];
    
    if (direction == DPSetupWindowNextDirection) {
        if(nextViewController != nil && [nextViewController respondsToSelector:@selector(willProgressToStage)]) {
            [nextViewController willProgressToStage];
        }
    } else if (direction == DPSetupWindowBackDirection) {
        if(nextViewController != nil && [nextViewController respondsToSelector:@selector(willRevertToStage)]) {
            [nextViewController willRevertToStage];
        }
    }
    
    void (^finished)() = ^{
        if (direction == DPSetupWindowNextDirection) {
            if(previousViewController != nil && [previousViewController respondsToSelector:@selector(didProgressToNextStage)]) {
                [previousViewController didProgressToNextStage];
            }
            
            if(nextViewController != nil && [nextViewController respondsToSelector:@selector(didProgressToStage)]) {
                [nextViewController didProgressToStage];
            }
        } else if (direction == DPSetupWindowBackDirection) {
            if(previousViewController != nil && [previousViewController respondsToSelector:@selector(didRevertToPreviousStage)]) {
                [previousViewController didRevertToPreviousStage];
            }
            
            if(nextViewController != nil && [nextViewController respondsToSelector:@selector(didRevertToStage)]) {
                [nextViewController didRevertToStage];
            }
        }
    };
    
    if ([self funnelsRepresentedObjects]) {
        [nextViewController setRepresentedObject:[previousViewController representedObject]];
    }
    
    if ([self animates] && previousViewController) {
        [NSAnimationContext beginGrouping];
        
        if ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) {
            [[NSAnimationContext currentContext] setDuration:3.0];
        }
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [[previousViewController view] removeFromSuperviewWithoutNeedingDisplay];
            finished();
        }];
        
        [view setFrame:NSMakeRect((560 * direction), 0, 560, 420)];
        [[self contentBox] addSubview:view];
        [[view animator] setFrameOrigin:NSMakePoint(0, 0)];
        [[[previousViewController view] animator] setFrameOrigin:NSMakePoint((-560 * direction), 0)];
        
        [NSAnimationContext endGrouping];
    } else {
        [view setFrame:NSMakeRect(0, 0, 560, 420)];
        if (previousViewController) {
            [[previousViewController view] removeFromSuperviewWithoutNeedingDisplay];
        }
        [[self contentBox] addSubview:view];
        finished();
    }
    
    currentStage = nextStage;
    [self registerObserversForPreviousViewController:previousViewController nextViewController:nextViewController];
    [self recalculateButtonEnabledStates];
    [self resetButtonTitles];
}

- (void)cancelOperation:(id)sender {
    [self cancel:sender];
}

- (void)cancel:(id)sender {
    [[NSApplication sharedApplication] endSheet:self returnCode:0];
    [self completionHandler](NO);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self recalculateButtonEnabledStates];
}

- (void)recalculateButtonEnabledStates {
    NSViewController<DPSetupWindowStageViewController> *currentViewController = [[self viewControllers] objectAtIndex:currentStage];
    if ([currentViewController respondsToSelector:@selector(canContinue)]) {
        [[self nextButton] setEnabled:[currentViewController canContinue]];
    } else {
        [[self nextButton] setEnabled:YES];
    }
    
    if ([currentViewController respondsToSelector:@selector(canGoBack)]) {
        [[self backButton] setEnabled:[currentViewController canGoBack]];
    } else {
        [[self backButton] setEnabled:YES];
    }
    
    if (currentStage == 0) {
        [[self backButton] setEnabled:NO];
    }
}

- (void)registerObserversForPreviousViewController:(NSViewController *)previousViewController nextViewController:(NSViewController *)nextViewController {
    
    [previousViewController removeObserver:self forKeyPath:@"canContinue"];
    [previousViewController removeObserver:self forKeyPath:@"canGoBack"];
    [nextViewController addObserver:self forKeyPath:@"canContinue" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
    [nextViewController addObserver:self forKeyPath:@"canGoBack" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
}

- (void)deregisterObserversForViewController:(NSViewController *)viewController {
    [viewController removeObserver:self forKeyPath:@"canContinue"];
    [viewController removeObserver:self forKeyPath:@"canGoBack"];
}

- (void)resetButtonTitles {
    NSViewController<DPSetupWindowStageViewController> *currentViewController = [[self viewControllers] objectAtIndex:currentStage];
    if ([currentViewController respondsToSelector:@selector(continueButtonTitle)]) {
        [[self nextButton] setTitle:[currentViewController continueButtonTitle]];
    } else {
        [[self nextButton] setTitle:@"Continue"];
    }
    
    if ([currentViewController respondsToSelector:@selector(cancelButtonTitle)]) {
        [[self cancelButton] setTitle:[currentViewController cancelButtonTitle]];
    } else {
        [[self cancelButton] setTitle:@"Cancel"];
    }
    
    if ([currentViewController respondsToSelector:@selector(backButtonTitle)]) {
        [[self backButton] setTitle:[currentViewController backButtonTitle]];
    } else {
        [[self backButton] setTitle:@"Back"];
    }
}

@end
