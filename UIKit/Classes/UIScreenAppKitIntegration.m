//  Created by Sean Heber on 10/12/10.
#import "UIScreenAppKitIntegration.h"
#import "UIScreen+UIPrivate.h"
#import <AppKit/AppKit.h>

extern NSMutableArray *_allScreens;

@implementation UIScreen (AppKitIntegration)
- (UIKitView *)UIKitView
{
	return _UIKitView;
}

- (CGPoint)convertPoint:(CGPoint)toConvert toScreen:(UIScreen *)toScreen
{
	if (toScreen == self) {
		return toConvert;
	} else {
		// Go all the way through OSX screen coordinates.
		NSPoint screenCoords = [[_UIKitView window] convertBaseToScreen:[_UIKitView convertPoint:NSPointFromCGPoint(toConvert) toView:nil]];
		
		if (toScreen) {
			// Now from there back to the toScreen's window's base
			return NSPointToCGPoint([[toScreen UIKitView] convertPoint:[[[toScreen UIKitView] window] convertScreenToBase:screenCoords] fromView:nil]);
		} else {
			return NSPointToCGPoint(screenCoords);
		}
	}
}

- (CGPoint)convertPoint:(CGPoint)toConvert fromScreen:(UIScreen *)fromScreen
{
	if (fromScreen == self) {
		return toConvert;
	} else {
		NSPoint screenCoords;
		
		if (fromScreen) {
			// Go all the way through OSX screen coordinates.
			screenCoords = [[[fromScreen UIKitView] window] convertBaseToScreen:[[fromScreen UIKitView] convertPoint:NSPointFromCGPoint(toConvert) toView:nil]];
		} else {
			screenCoords = NSPointFromCGPoint(toConvert);
		}
		
		// Now from there back to the our screen
		return NSPointToCGPoint([_UIKitView convertPoint:[[_UIKitView window] convertScreenToBase:screenCoords] fromView:nil]);
	}
}

- (CGRect)convertRect:(CGRect)toConvert toScreen:(UIScreen *)toScreen
{
	CGPoint origin = [self convertPoint:CGPointMake(CGRectGetMinX(toConvert),CGRectGetMinY(toConvert)) toScreen:toScreen];
	CGPoint bottom = [self convertPoint:CGPointMake(CGRectGetMaxX(toConvert),CGRectGetMaxY(toConvert)) toScreen:toScreen];
	return CGRectStandardize(CGRectMake(origin.x, origin.y, bottom.x-origin.x, bottom.y-origin.y));
}

- (CGRect)convertRect:(CGRect)toConvert fromScreen:(UIScreen *)fromScreen
{
	CGPoint origin = [self convertPoint:CGPointMake(CGRectGetMinX(toConvert),CGRectGetMinY(toConvert)) fromScreen:fromScreen];
	CGPoint bottom = [self convertPoint:CGPointMake(CGRectGetMaxX(toConvert),CGRectGetMaxY(toConvert)) fromScreen:fromScreen];
	return CGRectStandardize(CGRectMake(origin.x, origin.y, bottom.x-origin.x, bottom.y-origin.y));
}

- (void)becomeMainScreen
{
	NSValue *entry = [NSValue valueWithNonretainedObject:self];
	NSInteger index = [_allScreens indexOfObject:entry];
	[_allScreens removeObjectAtIndex:index];
	[_allScreens insertObject:entry atIndex:0];
}

@end

