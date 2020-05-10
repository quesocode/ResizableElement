//
//  MysticResizeableLabelBorderView.m
//  MysticResizableLabel
//
//  Created by travis weerts on 8/15/13.
//  Copyright (c) 2013 Mystic. All rights reserved.
//

#import "MysticResizeableLabelBorderView.h"

@implementation MysticResizeableLabelBorderView

#define kSPUserResizableViewGlobalInset 5.0
#define kSPUserResizableViewDefaultMinWidth 48.0
#define kSPUserResizableViewDefaultMinHeight 48.0
#define kSPUserResizableViewInteractiveBorderSize 24.0
#define kSPUserResizableViewInteractiveBorderWidth 2.0

@synthesize borderColor, dashed, borderWidth;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Clear background to ensure the content view shows through.
        self.backgroundColor = [UIColor clearColor];
        self.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
        self.dashed = YES;
        self.borderWidth = kSPUserResizableViewInteractiveBorderWidth;
    }
    return self;
}
- (void) setBorderColor:(UIColor *)newColor;
{
    borderColor = newColor;
    [self setNeedsDisplay];
}
- (void) setDashed:(BOOL)value
{
    dashed = value;
    [self setNeedsDisplay];
}
- (void) setBorderWidth:(CGFloat)value
{
    borderWidth = value;
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    if(self.dashed)
    {
        CGFloat dashes[] = {2,2};
    
        CGContextSetLineDash(context, 0.0, dashes, 2);
    }
    
    
    CGContextSetLineWidth(context, self.borderWidth);
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    
    UIEdgeInsets insets = UIEdgeInsetsMake(-self.borderWidth/2, -self.borderWidth/2, -self.borderWidth/2, -self.borderWidth/2);
    CGRect newBounds = CGRectInset(self.bounds, kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewInteractiveBorderSize/2);
    newBounds = UIEdgeInsetsInsetRect(newBounds, insets);
	CGPathRef roundedRectPath = [self roundedRectPath:newBounds radius:5];
    
    
	CGContextAddPath(context, roundedRectPath);
    
    
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}



- (CGPathRef) roundedRectPath:(CGRect)rect radius:(CGFloat)radius
{
	CGMutablePathRef retPath = CGPathCreateMutable();
    
	CGRect innerRect = CGRectInset(rect, radius, radius);
    
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
    
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
    
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
    
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
    
	CGPathCloseSubpath(retPath);
    
	return retPath;
}

@end
