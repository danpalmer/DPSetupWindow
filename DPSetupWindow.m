//
//  DPSetupWindow.m
//  DPSetupWindow
//
//  Created by Dan Palmer on 05/10/2012.
//  Copyright (c) 2012 Dan Palmer. All rights reserved.
//

#import "DPSetupWindow.h"

@interface DPSetupWindow ()

@property (assign) IBOutlet NSImageView *backgroundImageView;
@property (copy) void(^completionHandler)(BOOL);

@end

@implementation DPSetupWindow

- (id)initWithViewControllers:(NSArray *)viewControllers completionHandler:(void (^)(BOOL completed))completionHandler {
	
	NSRect contentRect = NSMakeRect(0, 0, 580, 420);
	
    self = [super initWithContentRect:contentRect styleMask:(NSTitledWindowMask|NSClosableWindowMask) backing:NSBackingStoreBuffered defer:YES];
    if (self == nil) return nil;
    
	currentStage = 0;
	[self setCompletionHandler:completionHandler];
	
	[self setContentView:[self initialiseContentViewForRect:contentRect]];
    return self;
}

- (NSView *)initialiseContentViewForRect:(NSRect)contentRect {
	NSView *contentView = [[NSView alloc] initWithFrame:contentRect];
	
	NSButton *cancelButton = [[NSButton alloc] initWithFrame:NSMakeRect(145, 13, 97, 32)];
	[cancelButton setBezelStyle:NSRoundedBezelStyle];
	[cancelButton setTarget:self];
	[cancelButton setAction:@selector(cancel:)];
	[cancelButton setTitle:@"Cancel"];
	[contentView addSubview:cancelButton];
	
	NSButton *backButton = [[NSButton alloc] initWithFrame:NSMakeRect(372, 13, 97, 32)];
	[backButton setBezelStyle:NSRoundedBezelStyle];
	[backButton setTarget:self];
	[backButton setAction:@selector(back:)];
	[backButton setTitle:@"Back"];
	[contentView addSubview:backButton];
	
	NSButton *nextButton = [[NSButton alloc] initWithFrame:NSMakeRect(469, 13, 97, 32)];
	[nextButton setBezelStyle:NSRoundedBezelStyle];
	[nextButton setTarget:self];
	[nextButton setAction:@selector(next:)];
	[nextButton setTitle:@"Continue"];
	[contentView addSubview:nextButton];
	
	NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(-40, 60, 320, 320)];
	[imageView setAlphaValue:0.3];
	[imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
	[imageView setImage:[[NSApplication sharedApplication] applicationIconImage]];
	[contentView addSubview:imageView];
	
	NSBox *box = [[NSBox alloc] initWithFrame:NSMakeRect(148, 57, 415, 345)];
	[box setTitlePosition:(NSNoTitle)];
	[contentView addSubview:box];
	
	return contentView;
}

- (void)setBackgroundImage:(NSImage *)backgroundImage {
	_backgroundImage = backgroundImage;
	[[self backgroundImageView] setImage:backgroundImage];
}

- (NSImage *)backgroundImage {
	return _backgroundImage;
}

- (void)cancelOperation:(id)sender {
	[self cancel:sender];
}

#pragma mark -
#pragma mark Flow Control

- (void)cancel:(id)sender {
	[[NSApplication sharedApplication] endSheet:self returnCode:0];
	[self completionHandler](NO);
}

- (void)back:(id)sender {
	
}

- (void)next:(id)sender {
	
}

@end
