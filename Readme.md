## DPSetupWindow

DPSetupWindow makes it easy to add setup style modal sheets or windows to your
Objective-C and Cocoa applications on Mac OS. Simply create a set of view
controllers and DPSetupWindow will take care of moving between them. 

```
NSViewController *firstViewController = ...;
NSViewController *secondViewController = ...;
NSViewController *thirdViewController = ...;

DPSetupWindow *setupFlow = [[DPSetupWindow alloc] initWithViewControllers: @[
	firstViewController,
	secondViewController,
	thirdViewController
] completionHandler:(void (^)(BOOL completed) {
	[setupFlow orderOut:self];
}];

[[NSApplication sharedApplication] beginSheet:setupFlow modalForWindow:[self window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
```