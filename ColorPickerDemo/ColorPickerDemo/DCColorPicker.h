//
//  DCColorPicker.h
//  ddd
//
//  Created by sven on 2020/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kIndicatorViewWidth (52) //指示器宽高
#define kSpace (kIndicatorViewWidth/2) //圆留白区

typedef struct {float h, s, v;} HSVType;
HSVType HSVTypeMake(float h, float s, float v);


@interface CustomIndicator : UIView
- (instancetype)initWithFrame:(CGRect)frame;
@end

///////////////////////////////////////////////////////////////

@interface DCColorPicker : UIView

@property (copy, nonatomic) void(^currentColorBlock)(UIColor *color, int x, int y);
@property (copy, nonatomic) void(^touchBegin)(void);
@property (copy, nonatomic) void(^touchEnd)(void);

- (instancetype)initWithFrame:(CGRect)frame bgImage:(UIImage *)image;

//设置初始x/y
- (void)changeIndicatorPointX:(int)x pointY:(int)y;

//设置指示器size和白边宽 默认size（52,52）白边宽 4
- (void)changeIndicatorSize:(CGSize)size borderWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
