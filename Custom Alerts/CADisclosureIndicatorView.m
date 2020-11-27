//
//  CADisclosureIndicatorView.m
//  Custom Alerts
//
//  Created by Richard Rindfuss on 11/14/20.
//  Copyright © 2020 Rich Rindfuss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CADisclosureIndicatorView.h"

@interface CADisclosureIndicatorView ()
@end

@implementation CADisclosureIndicatorView {
    UIColor *_tintColor;
}

- (void)tintColorDidChange
{
    [self setNeedsDisplay];
}

- (UIColor*)tintColor
{
    if ([[super superclass] instancesRespondToSelector:@selector(tintColor)])
        return [super tintColor];
    else
        return _tintColor;
}

- (void)setTintColor:(UIColor *)tintColor
{
    // On iOS 7, forward to the super (UIView).
    if ([[super superclass] instancesRespondToSelector:@selector(setTintColor:)])
        return [super setTintColor:tintColor];
    else
        _tintColor = tintColor;
}

- (CADisclosureIndicatorView *)initWithFrame:(CGRect)frame withColor:(UIColor *)color {
    self = [super initWithFrame:frame];
    self.tintColor = color;
    [self setNeedsDisplay];

    return self;
}

- (void)drawRect:(CGRect)rect
{
    const CGFloat size = MIN(self.bounds.size.width, self.bounds.size.height);
    CGAffineTransform transform = CGAffineTransformIdentity;
 
    // Account for non-square frames.
    if (self.bounds.size.width < self.bounds.size.height) {
        // Vertical Center
        transform = CGAffineTransformMakeTranslation(0, (self.bounds.size.height - self.bounds.size.width)/2);
    } else if (self.bounds.size.width > self.bounds.size.height) {
        // Horizontal Center
        transform = CGAffineTransformMakeTranslation((self.bounds.size.width - self.bounds.size.height)/2, 0);
    }
   
    // Draw the chevron
    {
        const CGFloat strokeWidth = 0.068359375f * size;
        const CGFloat checkBoxInset = 0.171875f * size;
        
// A small macro to scale the normalized control points for the
// bezier path to the size of the view.
#define P(POINT) (POINT * size)
        // draw a chevron (greater than sign >) that's on the right half of a unit-square box
        UIBezierPath *disclosurePath = [[UIBezierPath alloc] init];
        [disclosurePath moveToPoint:CGPointMake(P(0.5), checkBoxInset)];
        [disclosurePath addLineToPoint:CGPointMake(P(1)-checkBoxInset, P(0.5))];
        [disclosurePath addLineToPoint:CGPointMake(P(0.5), P(1)-checkBoxInset)];
                
        [disclosurePath applyTransform:transform];
        disclosurePath.lineWidth = strokeWidth;

        if (!self.tintColor) {
            self.tintColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
        }

        [self.tintColor setStroke];
        [disclosurePath stroke];
    }
        
#undef P
}
@end
