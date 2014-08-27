//
//  UITouch-KIFAdditions.m
//  KIF
//
//  Created by Eric Firestone on 5/20/11.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "UITouch-KIFAdditions.h"
#import "LoadableCategory.h"
#import <objc/runtime.h>

MAKE_CATEGORIES_LOADABLE(UITouch_KIFAdditions)

typedef struct {
    unsigned int _firstTouchForView:1;
    unsigned int _isTap:1;
    unsigned int _isDelayed:1;
    unsigned int _sentTouchesEnded:1;
    unsigned int _abandonForwardingRecord:1;
} UITouchFlags;


@interface UITouch ()

@property(assign) BOOL isTap;
@property(assign) NSUInteger tapCount;
@property(assign) UITouchPhase phase;
@property(retain) UIView *view;
@property(retain) UIWindow *window;
@property(assign) NSTimeInterval timestamp;
@property(assign) CGPoint currentLocation;
- (void)setGestureView:(UIView *)view;
- (void)_setLocationInWindow:(CGPoint)location resetPrevious:(BOOL)resetPrevious;
- (void)_setIsFirstTouchForView:(BOOL)firstTouchForView;
- (void)_setPreviousLocationInWindow:(CGPoint)l;
- (void)setPreviousLocationInWindow:(CGPoint)l;
- (CGPoint)previousLocationInView:(UIView*)v;
- (void)_updateMovementMagnitudeForLocation:(CGPoint)arg1;
- (void)_setPathMajorRadius:(float)arg1;;
@end

@implementation UITouch (KIFAdditions)

- (void)setTapCountInternal:(NSInteger)tapCount {
    self.tapCount = tapCount;
}

- (id)initInView:(UIView *)view; {
    CGRect frame = view.frame;    
    CGPoint centerPoint = CGPointMake(frame.size.width * 0.5f, frame.size.height * 0.5f);
    return [self initAtPoint:centerPoint inView:view];
}

- (id)initAtPoint:(CGPoint)point inWindow:(UIWindow *)window;
{
	self = [super init];
	if (self == nil) {
        return nil;
    }
    
    // Create a fake tap touch
    [self setWindow:window]; // Wipes out some values.  Needs to be first.
    
    [self setTapCount:1];
    [self _setLocationInWindow:point resetPrevious:YES];
    
	UIView *hitTestView = [window hitTest:point withEvent:nil];
    
    [self setView:hitTestView];
    [self setPhase:UITouchPhaseBegan];
    [self _setIsFirstTouchForView:YES];
    [self setIsTap:YES];
    [self setTimestamp: [NSDate timeIntervalSinceReferenceDate]];
    if ([self respondsToSelector:@selector(setGestureView:)]) {
        [self setGestureView:hitTestView];
    }
    
	return self;
}

- (id)initAtPoint:(CGPoint)point inView:(UIView *)view; {
    return [self initAtPoint:[view.window convertPoint:point fromView:view] inWindow:view.window];
}

- (void)setLocationInWindow:(CGPoint)location {
    [self setTimestamp: [NSDate timeIntervalSinceReferenceDate]];
    [self _setLocationInWindow:location resetPrevious:NO];
}

- (void)setPhaseAndUpdateTimestamp:(UITouchPhase)phase {
    [self setTimestamp: [NSDate timeIntervalSinceReferenceDate]];
    [self setPhase:phase];
}

@end
