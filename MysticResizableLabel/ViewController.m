//
//  ViewController.m
//  MysticResizableLabel
//
//  Created by travis weerts on 8/15/13.
//  Copyright (c) 2013 Mystic. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "MysticResizeableLabel.h"

@interface ViewController () <UITextViewDelegate, MysticResizeableLabelDelegate>
{
    MysticResizeableLabelFontType fontType;
    UITextView *activeTarget;
    NSInteger fontIndex, textIndex;
}

@property (nonatomic, retain) MysticResizeableLabel *label;
@property (nonatomic, retain) UITextView *textView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    fontIndex = 0;
    textIndex = 0;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Toggle Font" style:UIBarButtonItemStyleBordered target:self action:@selector(fontTouched:)];
    
    UIBarButtonItem *buttonItem2 = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editText:)];
    
    UIBarButtonItem *buttonItem3 = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStyleBordered target:self action:@selector(reset:)];
    
    UIBarButtonItem *buttonItem4 = [[UIBarButtonItem alloc] initWithTitle:@"Toggle" style:UIBarButtonItemStyleBordered target:self action:@selector(toggle:)];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, 320, 50)];
    
    toolBar.items = [NSArray arrayWithObjects:buttonItem, buttonItem2, buttonItem3, buttonItem4, nil];
    
    [self.view addSubview:toolBar];
    
    [self reset:nil];
    
}



- (void) toggle:(id)sender;
{
    self.label.enabled = !self.label.enabled;
}
- (void) reset:(id)sender;
{
    
    
    fontIndex = 0;
    textIndex = 0;
    for (UIView *s in self.view.subviews) {
        if([s isKindOfClass:[MysticResizeableLabel class]]) [s removeFromSuperview];
    }
    self.textView = nil;
    self.label = nil;
    activeTarget = nil;
    
    fontType = MysticResizeableLabelFontTypeDefault;
    self.label = [[MysticResizeableLabel alloc] initWithFrame:CGRectMake(50, 50, 220, 100)];
    self.label.preventsPositionOutsideSuperview = NO;
    self.label.delegate = self;
    self.label.borderView.borderColor = [UIColor redColor];
    self.label.borderView.borderWidth = 1;
    [self.view addSubview:self.label];
    
    
    
    
    
}
- (void) editText:(id)sender;
{
    [self.label becomeFirstResponder];
}



- (void) fontTouched:(id)sender;
{
    
    switch (fontType) {
        case MysticResizeableLabelFontTypeDefault:
            self.label.font = [UIFont fontWithName:@"Helvetica" size:self.label.fontSize];
            break;
        case MysticResizeableLabelFontType1:
            self.label.font = [UIFont fontWithName:@"Georgia-Italic" size:self.label.fontSize];
            break;
        case MysticResizeableLabelFontType2:
            self.label.font = [UIFont fontWithName:@"HoeflerText-BlackItalic" size:self.label.fontSize];
            break;
        case MysticResizeableLabelFontType3:
            self.label.font = [UIFont fontWithName:@"SnellRoundhand" size:self.label.fontSize];
            break;
        case MysticResizeableLabelFontType4:
            self.label.font = [UIFont fontWithName:@"Zapfino" size:self.label.fontSize];
            break;
        case MysticResizeableLabelFontType5:
            self.label.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:self.label.fontSize];
            break;
        default:
            break;
    }
    
    fontType++;
    if(fontType > MysticResizeableLabelFontType5) fontType = MysticResizeableLabelFontTypeDefault;
    fontIndex++;
}


- (void) labelViewDidBeginEditing:(MysticResizeableLabel *)labelView;
{
    NSLog(@"Editing text");
}

- (void) labelViewDidEndEditing:(MysticResizeableLabel *)labelView;
{
    NSLog(@"Finished edits: %@", labelView.text);
}


@end
