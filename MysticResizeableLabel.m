//
//  MysticResizeableLabel.m
//  MysticResizableLabel
//
//  Created by travis weerts on 8/15/13.
//  Copyright (c) 2013 Mystic. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MysticResizeableLabel.h"



#define kSPUserResizableViewGlobalInset 5.0
#define kSPUserResizableViewDefaultMinWidth 48.0
#define kSPUserResizableViewInteractiveBorderSize 24.0
#define kMYSTICLABELControlSize 36.0
#define kMYSTICLABELInsetSize 5.0


@interface MysticResizeableLabel () <UITextFieldDelegate>
{
    CGFloat lastAngle, ratio, labelRatio;
    CGPoint mcenterPoint;
    UITextView *activeTarget, *textView;
    
}
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) CGSize size;
@property (strong, nonatomic) UIImageView *resizingControl;
@property (strong, nonatomic) UIImageView *deleteControl;
@property (strong, nonatomic) UIImageView *customControl;
@property (nonatomic) BOOL preventsLayoutWhileResizing;
@property (nonatomic) float deltaAngle;
@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGAffineTransform startTransform;
@property (nonatomic) CGPoint touchStart;
@property (nonatomic, retain) MysticCGLabel *label;

@end



@implementation MysticResizeableLabel

@synthesize text, lineBreakMode, label, insets, font, defaultText, editedBlock, editingBlock, movedBlock, selectBlock, singleTapBlock, doubleTapBlock, longPressBlock, deleteBlock, customTapBlock, keyboardWillShowBlock, keyboardWillHideBlock, borderView;
@synthesize touchStart;
@synthesize prevPoint, rotationSnapping;
@synthesize deltaAngle, startTransform; //rotation
@synthesize resizingControl, deleteControl, customControl;
@synthesize preventsPositionOutsideSuperview;
@synthesize preventsResizing;
@synthesize preventsDeleting;
@synthesize preventsCustomButton;
@synthesize minWidth, minHeight;
@synthesize selected, enabled;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupDefaultAttributes];
    }
    return self;
}


- (CGFloat) fontSize; { return self.label.fontSize; }
- (NSString *) text; { return self.label.text; }
- (void) setText:(NSString *)value; {  self.label.text = value; [self.label setFontSizeThatFits]; [self resizeLabelWithText:value]; [self.label setFontSizeThatFits];}


- (void) resizeLabelWithText:(NSString *)theText {
    CGRect frame = self.label.frame;
    CGSize size = [theText sizeWithFont:self.label.font
                  constrainedToSize:CGSizeMake(frame.size.width, 9999)
                      lineBreakMode:self.label.lineBreakMode];
    
    CGFloat hackHeight = self.label.rowHeight*[self.label numberOfBreaks:theText];
    size.height = hackHeight;
    //size.height = size.height > hackHeight ? hackHeight : size.height;
    frame.size.height = size.height+5;
    [self.label resetFrame:frame];
    labelRatio = frame.size.height/frame.size.width;
    [self sizeToFitLabel];
    
    frame.origin.x = kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2 + kMYSTICLABELInsetSize;
    frame.origin.y = kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2 + kMYSTICLABELInsetSize;
    self.label.frame = frame;
//    [self resizeScaledLabel];
    
}

- (void) resizeScaledLabel;
{
    CGRect scaledRect = self.label.frame;
    scaledRect.size.height = scaledRect.size.height*1.5;
    scaledRect.size.width = scaledRect.size.width*1.5;
    self.label.enlargedSize = scaledRect.size;
    
}

- (void) sizeToFitLabel;
{
    CGRect labelRect = self.label.bounds;
    if(CGRectEqualToRect(CGRectZero, labelRect)) return;
    if(!labelRatio)
    {
        labelRatio = labelRect.size.width > labelRect.size.height ? labelRect.size.height/labelRect.size.width : labelRect.size.width/labelRect.size.height;
    }
    
    
    CGRect outerRect = labelRect;
    outerRect.size.height += (kSPUserResizableViewGlobalInset*2) + kSPUserResizableViewInteractiveBorderSize + (kMYSTICLABELInsetSize*2);
    outerRect.size.width += (kSPUserResizableViewGlobalInset*2) + kSPUserResizableViewInteractiveBorderSize + (kMYSTICLABELInsetSize*2);
    
    
    
    self.size = outerRect.size;
    
    [super setCenter:mcenterPoint];
    
    deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                       self.frame.origin.x+self.frame.size.width - self.center.x);
    
    return;

}

- (void) setSize:(CGSize)newSize;
{

    
    CGRect labelRect = self.label.frame;
    labelRect.size.width = newSize.width-((kSPUserResizableViewGlobalInset*2) + kSPUserResizableViewInteractiveBorderSize + (kMYSTICLABELInsetSize*2));
    labelRect.size.height = labelRect.size.width * labelRatio;
    
    labelRect.origin.x = newSize.width/2 - labelRect.size.width/2;
    labelRect.origin.y = newSize.height/2 - labelRect.size.height/2;
    self.label.frame = labelRect;
    
    
    
    CGRect b = self.bounds;
    b.size = newSize;
    [super setBounds:b];
    [self layoutControls];    
    ratio = self.bounds.size.width > self.bounds.size.height ? self.bounds.size.height/self.bounds.size.width : self.bounds.size.width/self.bounds.size.height;
    
}

- (void) layoutControls;
{
    borderView.frame = CGRectInset(self.bounds,
                                   kSPUserResizableViewGlobalInset,
                                   kSPUserResizableViewGlobalInset);
    resizingControl.frame =CGRectMake(self.bounds.size.width-kMYSTICLABELControlSize,
                                      self.bounds.size.height-kMYSTICLABELControlSize,
                                      kMYSTICLABELControlSize,
                                      kMYSTICLABELControlSize);
    deleteControl.frame = CGRectMake(0,0,
                                     kMYSTICLABELControlSize, kMYSTICLABELControlSize);
    customControl.frame =CGRectMake(self.bounds.size.width,
                                    0,
                                    kMYSTICLABELControlSize,
                                    kMYSTICLABELControlSize);
    [borderView setNeedsDisplay];
    
    [self setNeedsDisplay];
}

- (void) setFont:(UIFont *)newFont;
{
    self.label.font = newFont;
    [self resizeLabelWithText:self.label.text];
}

- (UIFont *) font; { return self.label.font; }







- (BOOL) selected;
{
    return !borderView.hidden;
}

- (void) setEnabled:(BOOL)newValue;
{
    
    if(self.selected) self.selected = NO;
    
    enabled = newValue;    
}

- (void) setSelected:(BOOL)v
{
    if(!self.enabled) return;
    if(v)
    {
        [self showEditingHandles];
    }
    else
    {
        [self hideEditingHandles];
    }
    
    if([_delegate respondsToSelector:@selector(labelViewDidSelect:)]) {
        [_delegate labelViewDidSelect:self];
    }
    
    if(self.selectBlock) self.selectBlock(self);
}

#ifdef MYSTICLABEL_LONGPRESS
-(void)longPress:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if([_delegate respondsToSelector:@selector(labelViewDidLongPressed:)]) {
            [_delegate labelViewDidLongPressed:self];
        }
        else if(self.longPressBlock)
        {
            self.longPressBlock(self);
        }
    }
}
#endif
- (void) singleTap:(UITapGestureRecognizer *)recognizer;
{
    if(!self.enabled) return;

    if([_delegate respondsToSelector:@selector(labelViewDidSingleTap:)]) {
        [_delegate labelViewDidSingleTap:self];
    }
    else if(self.singleTapBlock)
    {
        self.singleTapBlock(self);
    }
    else
    {
        if(!self.selected) self.selected = YES;
    }
    
    
}
- (void) doubleTap:(UITapGestureRecognizer *)recognizer;
{
    if(!self.enabled) return;

    if([_delegate respondsToSelector:@selector(labelViewDidDoubleTap:)]) {
        [_delegate labelViewDidDoubleTap:self];
    }
    else if(self.doubleTapBlock)
    {
        self.doubleTapBlock(self);
    }
    else
    {
        [self becomeFirstResponder];
    }
    
    
}
-(void)deleteTap:(UIPanGestureRecognizer *)recognizer
{
    if(!self.enabled) return;

    if([_delegate respondsToSelector:@selector(labelViewDidClose:)]) {
        [_delegate labelViewDidClose:self];
    }
    else if(self.deleteBlock)
    {
        self.deleteBlock(self);
    }
    else
        if (NO == self.preventsDeleting) {
            UIView * close = (UIView *)[recognizer view];
            [close.superview removeFromSuperview];
        }
    
    
}

-(void)customTap:(UIPanGestureRecognizer *)recognizer
{
    if(!self.enabled) return;

    if (NO == self.preventsCustomButton) {
        if([_delegate respondsToSelector:@selector(labelViewDidCustomButtonTap:)]) {
            [_delegate labelViewDidCustomButtonTap:self];
        }
        else if(self.customTapBlock)
        {
            self.customTapBlock(self);
        }
    }
}

-(void)resizeTranslate:(UIPanGestureRecognizer *)recognizer
{
    
    if ([recognizer state]== UIGestureRecognizerStateBegan)
    {
        prevPoint = [recognizer locationInView:self];
        [self resizeScaledLabel];
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        if (self.bounds.size.width < minWidth || self.bounds.size.height < minHeight)
        {
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     minWidth+1,
                                     minHeight+1);
            resizingControl.frame =CGRectMake(self.bounds.size.width-kMYSTICLABELControlSize,
                                              self.bounds.size.height-kMYSTICLABELControlSize,
                                              kMYSTICLABELControlSize,
                                              kMYSTICLABELControlSize);
            deleteControl.frame = CGRectMake(0, 0,
                                             kMYSTICLABELControlSize, kMYSTICLABELControlSize);
            customControl.frame =CGRectMake(self.bounds.size.width-kMYSTICLABELControlSize,
                                            0,
                                            kMYSTICLABELControlSize,
                                            kMYSTICLABELControlSize);
            prevPoint = [recognizer locationInView:self];
            
            
        } else {
            CGPoint point = [recognizer locationInView:self];
            float wChange = 0.0, hChange = 0.0;
            
            wChange = (point.x - prevPoint.x);
            hChange = (point.y - prevPoint.y);
            
            if (ABS(wChange) > 20.0f || ABS(hChange) > 20.0f) {
                prevPoint = [recognizer locationInView:self];
                return;
            }
            
            if (YES == self.preventsLayoutWhileResizing) {
                if (wChange < 0.0f && hChange < 0.0f) {
                    float change = MIN(wChange, hChange);
                    wChange = change;
                    hChange = change;
                }
                if (wChange < 0.0f) {
                    hChange = wChange;
                } else if (hChange < 0.0f) {
                    wChange = hChange;
                } else {
                    float change = MAX(wChange, hChange);
                    wChange = change;
                    hChange = change;
                }
            }
            
            CGRect b = self.bounds;
            b.size.width += wChange;
            b.size.height += hChange;
            CGSize nc = b.size;
            if(b.size.width > b.size.height)
            {
                nc.height = nc.width *ratio;
                
            }
            else
            {
                nc.width = nc.height *ratio;
            }
            

            self.size = nc;

            prevPoint = [recognizer locationInView:self];
            
        }
        
        /* Rotation */
        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
                          [recognizer locationInView:self.superview].x - self.center.x);
        float angleDiff = deltaAngle - ang;
        
        if(rotationSnapping)
        {
            BOOL shouldRotate = angleDiff < -0.12 || angleDiff > 0.12 ? YES : NO;
            angleDiff = shouldRotate ? angleDiff : 0;
        }
        if (NO == preventsResizing) {
            self.transform = CGAffineTransformMakeRotation(-angleDiff);
            lastAngle = -angleDiff;
        }
    
        
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
}

- (void) setDefaultText:(NSString *)value
{
    defaultText = value;
    if([self.text isEqualToString:@"Double Tap To Edit"]) self.text = defaultText;
}


- (void)setupDefaultAttributes
{
    self.enabled = YES;
    [self registerForKeyboardNotifications];
    defaultText = @"Double Tap To Edit";
    lastAngle = 0;
    self.backgroundColor = [UIColor clearColor];
    mcenterPoint  = self.center;
    rotationSnapping = NO;
    self.clipsToBounds = YES;
    self.minimumFontSize = 10;
    self.insets = UIEdgeInsetsMake(kMYSTICLABELInsetSize, kMYSTICLABELInsetSize, kMYSTICLABELInsetSize, kMYSTICLABELInsetSize);
    MysticCGLabel *newLabel = [[MysticCGLabel alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, self.insets)];
    newLabel.numberOfLines = 0;
    newLabel.textAlignment = NSTextAlignmentCenter;
    newLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    newLabel.backgroundColor = [UIColor clearColor];
    newLabel.text = defaultText;
    newLabel.clipsToBounds = YES;
    self.label = newLabel;
    
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];

    
    borderView = [[MysticResizeableLabelBorderView alloc] initWithFrame:CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset)];
    [borderView setHidden:NO];
    [self addSubview:borderView];
    

    
    if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width*0.5) {
        self.minWidth = kSPUserResizableViewDefaultMinWidth;
        self.minHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
    } else {
        self.minWidth = self.bounds.size.width*0.5;
        self.minHeight = self.bounds.size.height*0.5;
    }
    self.preventsPositionOutsideSuperview = YES;
    self.preventsLayoutWhileResizing = YES;
    self.preventsResizing = NO;
    self.preventsDeleting = NO;
    self.preventsCustomButton = YES;
#ifdef MYSTICLABEL_LONGPRESS
    UILongPressGestureRecognizer* longpress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(longPress:)];
    [self addGestureRecognizer:longpress];
#endif
    deleteControl = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,
                                                                 kMYSTICLABELControlSize, kMYSTICLABELControlSize)];
    deleteControl.backgroundColor = [UIColor clearColor];
    deleteControl.image = [UIImage imageNamed:@"delete-Circle.png" ];
    deleteControl.userInteractionEnabled = YES;
    UITapGestureRecognizer * deleteTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(deleteTap:)];
    [deleteControl addGestureRecognizer:deleteTap];
    [self addSubview:deleteControl];
    
    resizingControl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-kMYSTICLABELControlSize,
                                                                   self.frame.size.height-kMYSTICLABELControlSize,
                                                                   kMYSTICLABELControlSize, kMYSTICLABELControlSize)];
    resizingControl.backgroundColor = [UIColor clearColor];
    resizingControl.userInteractionEnabled = YES;
    resizingControl.image = [UIImage imageNamed:@"resize-Circle.png" ];
    UIPanGestureRecognizer* panResizeGesture = [[UIPanGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(resizeTranslate:)];
    [resizingControl addGestureRecognizer:panResizeGesture];
    [self addSubview:resizingControl];
    
    customControl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-kMYSTICLABELControlSize,
                                                                 0,
                                                                 kMYSTICLABELControlSize, kMYSTICLABELControlSize)];
    customControl.backgroundColor = [UIColor clearColor];
    customControl.userInteractionEnabled = YES;
    customControl.image = nil;
    UITapGestureRecognizer * customTapGesture = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(customTap:)];
    [customControl addGestureRecognizer:customTapGesture];
    [self addSubview:customControl];
    
    
    deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                       self.frame.origin.x+self.frame.size.width - self.center.x);
    [self.label setFontSizeThatFits];
    [self resizeLabelWithText:self.label.text];
    
}



- (void)setLabel:(MysticCGLabel *)newLabel {
    [label removeFromSuperview];
    label = newLabel;
    label.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    [self addSubview:label];
    

    [self bringSubviewToFront:borderView];
    [self bringSubviewToFront:resizingControl];
    [self bringSubviewToFront:deleteControl];
    [self bringSubviewToFront:customControl];
}

- (void)setFrame:(CGRect)newFrame {
    ratio = newFrame.size.width > newFrame.size.height ? newFrame.size.height/newFrame.size.width : newFrame.size.width/newFrame.size.height;
    [super setFrame:newFrame];
    if(CGPointEqualToPoint(mcenterPoint, CGPointZero)) mcenterPoint = self.center;
    [self layoutControls];
    [self sizeToFitLabel];
}

- (void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self sizeToFitLabel];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    touchStart = [touch locationInView:self.superview];
    if([_delegate respondsToSelector:@selector(labelViewDidBeginMoving:)]) {
        [_delegate labelViewDidBeginMoving:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(labelViewDidEndMoving:)]) {
        [_delegate labelViewDidEndMoving:self];
    }
    else if(self.movedBlock) self.movedBlock(self);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(labelViewDidCancelMoving:)]) {
        [_delegate labelViewDidCancelMoving:self];
    }
}

- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    if(!self.selected) return;
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x,
                                    self.center.y + touchPoint.y - touchStart.y);
    if (self.preventsPositionOutsideSuperview) {
        // Ensure the translation won't cause the view to move offscreen.
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX) {
            newCenter.x = self.superview.bounds.size.width - midPointX;
        }
        if (newCenter.x < midPointX) {
            newCenter.x = midPointX;
        }
        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY) {
            newCenter.y = self.superview.bounds.size.height - midPointY;
        }
        if (newCenter.y < midPointY) {
            newCenter.y = midPointY;
        }
    }
    mcenterPoint = newCenter;
    self.center = newCenter;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(resizingControl.frame, touchLocation)) {
        return;
    }
    
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    [self translateUsingTouchLocation:touch];
    touchStart = touch;
}

- (void)hideDelHandle
{
    deleteControl.hidden = YES;
}

- (void)showDelHandle
{
    deleteControl.hidden = NO;
}

- (void)hideEditingHandles
{
    resizingControl.hidden = YES;
    deleteControl.hidden = YES;
    customControl.hidden = YES;
    [borderView setHidden:YES];
}

- (void)showEditingHandles
{
    if (NO == preventsCustomButton) {
        customControl.hidden = NO;
    } else {
        customControl.hidden = YES;
    }
    if (NO == preventsDeleting) {
        deleteControl.hidden = NO;
    } else {
        deleteControl.hidden = YES;
    }
    if (NO == preventsResizing) {
        resizingControl.hidden = NO;
    } else {
        resizingControl.hidden = YES;
    }
    [borderView setHidden:NO];
}

- (void)showCustmomHandle
{
    customControl.hidden = NO;
}

- (void)hideCustomHandle
{
    customControl.hidden = YES;
}

- (void)setButton:(MYSTICLABEL_BUTTONS)type image:(UIImage*)image
{
    switch (type) {
        case MYSTICLABEL_BUTTON_RESIZE:
            resizingControl.image = image;
            break;
        case MYSTICLABEL_BUTTON_DEL:
            deleteControl.image = image;
            break;
        case MYSTICLABEL_BUTTON_CUSTOM:
            customControl.image = image;
            break;
            
        default:
            break;
    }
}

- (void) removeFromSuperview;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}
#pragma mark - Keyboard Interactions


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    
    activeTarget = (UITextView *)[textView.inputAccessoryView viewWithTag:1];
    [activeTarget becomeFirstResponder];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if(self.keyboardWillHideBlock) self.keyboardWillHideBlock(self);
}
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    if(self.keyboardWillShowBlock) self.keyboardWillShowBlock(self);
}





- (UIView *) toolbar;
{
    if(self.inputAccessoryView) return self.inputAccessoryView;
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.backgroundColor = [UIColor blackColor];
    toolbar.autoresizesSubviews = YES;
    
    UITextView *atextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 1, toolbar.frame.size.width-44, 43)];
    atextView.font = [UIFont fontWithName:@"Helvetica" size:22];
    atextView.delegate = (id)self;
    atextView.text = self.label.text;
    atextView.tag = 1;
    atextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [toolbar addSubview:atextView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    [btn setImage:[UIImage imageNamed:@"check-Button.png"] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor blackColor];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(atextView.frame.size.width, 1, 44, 43);
    [toolbar addSubview:btn];
    return toolbar;
    
    
}


- (BOOL) resignFirstResponder;
{
    self.text = activeTarget.text;
    self.text = activeTarget.text; // hack to resize text correctly called 2X
    [activeTarget resignFirstResponder];
    [textView resignFirstResponder];
    [textView removeFromSuperview];
    textView = nil;
    if([_delegate respondsToSelector:@selector(labelViewDidEndEditing:)]) {
        [_delegate labelViewDidEndEditing:self];
    }
    else if(self.editedBlock) self.editedBlock(self);
    return YES;
}

- (BOOL) becomeFirstResponder;
{
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(self.frame.size.width*2, self.frame.size.height*2, 10, 10)];
    textView.inputAccessoryView = [self toolbar];
    [self addSubview:textView];
    textView.text = self.label.text;
    activeTarget = textView;
    if(activeTarget) [activeTarget becomeFirstResponder];
    if([_delegate respondsToSelector:@selector(labelViewDidBeginEditing:)]) {
        [_delegate labelViewDidBeginEditing:self];
    } 
    else if(self.editingBlock) self.editingBlock(self);
    return YES;
    
}



@end
