//
//  MysticCGLabel.h
//  MysticResizableLabel
//
//  Created by travis weerts on 8/15/13.
//  Copyright (c) 2013 Mystic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MysticCGLabel : UILabel


// Note: The built-in UILabel adjustsFontSizeToFitWidth has its problems, that is
//       why ARLabel uses its own logic to apply the font size. If you want the
//       same functionality also when the text is changing then remeber to set
//       the following property to YES.

// Set this property to YES to automatically adjust the font size of the text to fit
// current label frame on every text change. The default value is NO and the font size
// is calculated only the first time the text is set. The reason for this is better
// performance in the scenario that the label text is changed very frequently.
@property (assign, nonatomic) BOOL autoAdjustFontSizeWithTextChange;

// This property allows you to set a sort of template text to calculate the font
// size by, but which will never be displayed on the label. This is useful if you
// don't want to use the above autoAdjustFontSizeWithTextChange property but still
// want that text with different lengths fits the label. For example if you are
// going to display different dates inside the same label "24 June 2013" will
// obviously not have the same width as "24 September 2013", so you can set this
// property to the text with the greatest length that you are going to encounter
// and the font will be adjusted to that one. This is also handy for text with
// the same length, but that will still have different width because the font used
// is not a monospaced(fixed-width) font.
@property (strong, nonatomic) NSString *textForFontSizeCalculation;

// This property is responsible for better and clear looking text in case you are
// enlarging the size of the label greater than its initial size. If this property is
// not set the text is going to look blurry when enlarged. So set this to the maximum
// size you anticipate your label is going to change.
@property (assign, nonatomic) CGSize enlargedSize;
@property (readonly) CGFloat fontSize, rowHeight;
@property (nonatomic) NSInteger numberOfBreaks;
- (NSInteger) numberOfBreaks:(NSString *)newText;
- (void)setFontSizeThatFits;
- (void) resetFrame:(CGRect)frame;

@end
