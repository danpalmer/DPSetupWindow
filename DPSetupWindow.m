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
@property (retain) NSButton *cancelButton;
@property (retain) NSButton *backButton;
@property (retain) NSButton *nextButton;

@property (copy) void(^completionHandler)(BOOL);
@property (retain) NSArray *viewControllers;
@property (assign) NSViewController *currentViewController;

@end

@implementation DPSetupWindow

- (id)initWithViewControllers:(NSArray *)viewControllers completionHandler:(void (^)(BOOL completed))completionHandler {
	
	NSRect contentRect = NSMakeRect(0, 0, 580, 420);
	
    self = [super initWithContentRect:contentRect styleMask:(NSTitledWindowMask|NSClosableWindowMask) backing:NSBackingStoreBuffered defer:YES];
    if (self == nil) return nil;
    
	if (!viewControllers || [viewControllers count] == 0) return nil;
	if (!completionHandler) return nil;
	
	currentStage = -1;
	_animates = YES;
	[self setViewControllers:viewControllers];
	[self setCompletionHandler:completionHandler];
	
	[self setContentView:[self initialiseContentViewForRect:contentRect]];
	[self next:nil];
    return self;
}

- (NSView *)initialiseContentViewForRect:(NSRect)contentRect {
	NSView *contentView = [[NSView alloc] initWithFrame:contentRect];
	
	_cancelButton = [[NSButton alloc] initWithFrame:NSMakeRect(145, 13, 97, 32)];
	[_cancelButton setBezelStyle:NSRoundedBezelStyle];
	[_cancelButton setTarget:self];
	[_cancelButton setAction:@selector(cancel:)];
	[_cancelButton setTitle:@"Cancel"];
	[contentView addSubview:_cancelButton];
	
	_backButton = [[NSButton alloc] initWithFrame:NSMakeRect(372, 13, 97, 32)];
	[_backButton setBezelStyle:NSRoundedBezelStyle];
	[_backButton setTarget:self];
	[_backButton setAction:@selector(back:)];
	[_backButton setTitle:@"Back"];
	[contentView addSubview:_backButton];
	
	_nextButton = [[NSButton alloc] initWithFrame:NSMakeRect(469, 13, 97, 32)];
	[_nextButton setBezelStyle:NSRoundedBezelStyle];
	[_nextButton setTarget:self];
	[_nextButton setAction:@selector(next:)];
	[_nextButton setTitle:@"Continue"];
	[contentView addSubview:_nextButton];
	
	_imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(-40, 60, 320, 320)];
	[_imageView setAlphaValue:0.3];
	[_imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
	[_imageView setImage:[[NSApplication sharedApplication] applicationIconImage]];
	[contentView addSubview:_imageView];
	
	_contentBox = [[NSBox alloc] initWithFrame:NSMakeRect(148, 57, 415, 345)];
	[_contentBox setTitlePosition:(NSNoTitle)];
	[contentView addSubview:_contentBox];
	
	return contentView;
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

- (void)next:(id)sender {
	
	if (currentStage == [[self viewControllers] count]) {
		return; // we have already triggered the callback
	}
	
	NSViewController<DPSetupWindowStageViewController> *previousViewController = nil;
	if (currentStage >= 0 && currentStage < [[self viewControllers] count]) {
		previousViewController = [[self viewControllers] objectAtIndex:currentStage];
	}
	
	currentStage++;
	if (currentStage == [[self viewControllers] count]) {
		[self completionHandler](YES);
		return;
	}
	
	NSViewController<DPSetupWindowStageViewController> *nextViewController = [[self viewControllers] objectAtIndex:currentStage];
	NSView *view = [nextViewController view];
	
	if ([self animates] && previousViewController) {
		[NSAnimationContext beginGrouping];
		
		if ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) {
			[[NSAnimationContext currentContext] setDuration:3.0];
		}
		[[NSAnimationContext currentContext] setCompletionHandler:^{
			[[previousViewController view] removeFromSuperviewWithoutNeedingDisplay];
		}];
		
		[view setFrame:NSMakeRect(400, 0, 400, 330)];
		[[self contentBox] addSubview:view];
		[[view animator] setFrameOrigin:NSMakePoint(0, 0)];
		[[[previousViewController view] animator] setFrameOrigin:NSMakePoint(-400, 0)];
		
		[NSAnimationContext endGrouping];
	} else {
		[view setFrame:NSMakeRect(0, 0, 400, 330)];
		if (previousViewController) {
			[[previousViewController view] removeFromSuperviewWithoutNeedingDisplay];
		}
		[[self contentBox] addSubview:view];
	}
	
	[self registerObserversForPreviousViewController:previousViewController nextViewController:nextViewController];
	[self recalculateButtonEnabledStates];
}

- (void)back:(id)sender {
	
	if (currentStage == 0) {
		return;
	}
	
	NSViewController<DPSetupWindowStageViewController> *previousViewController = nil;
	if (currentStage >= 0 && currentStage < [[self viewControllers] count]) {
		previousViewController = [[self viewControllers] objectAtIndex:currentStage];
	}
	
	currentStage--;
	if (currentStage == [[self viewControllers] count]) {
		[self completionHandler](YES);
		return;
	}
	
	NSViewController<DPSetupWindowStageViewController> *nextViewController = [[self viewControllers] objectAtIndex:currentStage];
	NSView *view = [nextViewController view];
	
	if ([self animates] && previousViewController) {
		[NSAnimationContext beginGrouping];
		
		if ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) {
			[[NSAnimationContext currentContext] setDuration:2.0];
		}
		[[NSAnimationContext currentContext] setCompletionHandler:^{
			[[previousViewController view] removeFromSuperviewWithoutNeedingDisplay];
		}];
		
		[view setFrame:NSMakeRect(-400, 0, 400, 330)];
		[[self contentBox] addSubview:view];
		[[view animator] setFrameOrigin:NSMakePoint(0, 0)];
		[[[previousViewController view] animator] setFrameOrigin:NSMakePoint(400, 0)];
		
		[NSAnimationContext endGrouping];
	} else {
		[view setFrame:NSMakeRect(0, 0, 400, 330)];
		if (previousViewController) {
			[[previousViewController view] removeFromSuperviewWithoutNeedingDisplay];
		}
		[[self contentBox] addSubview:view];
	}
	
	[self registerObserversForPreviousViewController:previousViewController nextViewController:nextViewController];
	[self recalculateButtonEnabledStates];
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
	}
	
	if ([currentViewController respondsToSelector:@selector(canGoBack)]) {
		[[self backButton] setEnabled:[currentViewController canGoBack]];
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

@end
