//
//  MysticResizeableLabel.h
//  MysticResizableLabel
//
//  Created by travis weerts on 8/15/13.
//  Copyright (c) 2013 Mystic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticCGLabel.h"
#import "MysticResizeableLabelBorderView.h"

@protocol MysticResizeableLabelDelegate;
@class MysticResizeableLabel;

typedef enum {
    MYSTICLABEL_BUTTON_NULL,
    MYSTICLABEL_BUTTON_DEL,
    MYSTICLABEL_BUTTON_RESIZE,
    MYSTICLABEL_BUTTON_CUSTOM,
    MYSTICLABEL_BUTTON_MAX
} MYSTICLABEL_BUTTONS;

typedef void (^MysticResizeLabelBlock)(MysticResizeableLabel *label);





@interface MysticResizeableLabel : UIView

@property (nonatomic, copy) MysticResizeLabelBlock editingBlock;
@property (nonatomic, copy) MysticResizeLabelBlock editedBlock;
@property (nonatomic, copy) MysticResizeLabelBlock selectBlock;
@property (nonatomic, copy) MysticResizeLabelBlock movedBlock, longPressBlock, singleTapBlock, doubleTapBlock, deleteBlock, customTapBlock, keyboardWillShowBlock, keyboardWillHideBlock;

@property (nonatomic, retain) NSString *defaultText;
@property (nonatomic, retain) MysticResizeableLabelBorderView *borderView;
@property (nonatomic, assign) NSString *text;
@property (nonatomic) NSLineBreakMode lineBreakMode;
@property (nonatomic) CGFloat minimumFontSize, fontSize;
@property (nonatomic, assign) UIFont *font;
@property (nonatomic, assign) BOOL selected, enabled;
@property (nonatomic) BOOL preventsPositionOutsideSuperview; //default = YES
@property (nonatomic) BOOL rotationSnapping;
@property (nonatomic) BOOL preventsResizing; //default = NO
@property (nonatomic) BOOL preventsDeleting; //default = NO
@property (nonatomic) BOOL preventsCustomButton; //default = YES
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;
//@property (nonatomic, retain) UIView *inputAccessory;
@property (strong, nonatomic) id <MysticResizeableLabelDelegate> delegate;


- (void)hideDelHandle;
- (void)showDelHandle;
- (void)hideEditingHandles;
- (void)showEditingHandles;
- (void)showCustmomHandle;
- (void)hideCustomHandle;
- (void)setButton:(MYSTICLABEL_BUTTONS)type image:(UIImage*)image;

@end


@protocol MysticResizeableLabelDelegate <NSObject>
@required
@optional

- (void)labelViewDidSelect:(MysticResizeableLabel *)labelView;
- (void)labelViewDidDoubleTap:(MysticResizeableLabel *)labelView;
- (void)labelViewDidSingleTap:(MysticResizeableLabel *)labelView;

- (void)labelViewDidBeginMoving:(MysticResizeableLabel *)labelView;
- (void)labelViewDidEndMoving:(MysticResizeableLabel *)labelView;
- (void)labelViewDidCancelMoving:(MysticResizeableLabel *)labelView;

- (void)labelViewDidBeginEditing:(MysticResizeableLabel *)labelView;

- (void)labelViewDidEndEditing:(MysticResizeableLabel *)labelView;
- (void)labelViewDidClose:(MysticResizeableLabel *)labelView;
#ifdef MYSTICLABEL_LONGPRESS
- (void)labelViewDidLongPressed:(MysticResizeableLabel *)labelView;
#endif
- (void)labelViewDidCustomButtonTap:(MysticResizeableLabel *)labelView;
@end



