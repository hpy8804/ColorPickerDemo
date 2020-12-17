//
//  DCColorPicker.m
//  ddd
//
//  Created by sven on 2020/10/13.
//

#import "DCColorPicker.h"

inline HSVType HSVTypeMake(float h, float s, float v)
{
    HSVType hsv = {h, s, v};
    return hsv;
}

#define kBaseMeasure (1000.0)
#define kcicleWidth (4) //圆环宽
#define kOffSet (3)

@interface CustomIndicator ()
{
    UIView *_indicatorView;
}
@end

@implementation CustomIndicator

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildUI:frame];
    }
    return self;
}

- (void)buildUI:(CGRect)frame
{
    self.layer.cornerRadius = frame.size.width/2.0;
    self.layer.borderWidth = kcicleWidth;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [self.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.layer setShadowRadius:5];
    [self.layer setShadowOpacity:0.5];
    [self.layer setShadowColor:[UIColor blackColor].CGColor];
}

@end

///////////////////////////////////////////////////////////////

@interface DCColorPicker ()
{
    UIImageView *_imgCicle; //背景圆
    CustomIndicator *_indicator;
    HSVType _currentHSVWithNew;
}
@end

@implementation DCColorPicker

- (instancetype)initWithFrame:(CGRect)frame bgImage:(UIImage *)image
{
    if (self = [super initWithFrame:frame]) {
        [self buildUI:frame image:image];
    }
    return self;
}

- (void)buildUI:(CGRect)frame image:(UIImage *)image
{
    _imgCicle = [[UIImageView alloc] initWithFrame:CGRectMake(kSpace, kSpace, frame.size.width - kSpace*2, frame.size.height- kSpace*2)];
    _imgCicle.image = image;
    [self addSubview:_imgCicle];

    
    _indicator = [[CustomIndicator alloc] initWithFrame:CGRectMake(0, 0, kIndicatorViewWidth, kIndicatorViewWidth)];
    [self addSubview:_indicator];
    _indicator.userInteractionEnabled = NO;
    _indicator.center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
}

- (void)changeIndicatorPointX:(int)x pointY:(int)y
{
    if (fabs(sqrt(pow(kBaseMeasure/2.0+ kSpace, 2) + pow(kBaseMeasure/2.0+ kSpace, 2)) - sqrt(pow(x + kSpace, 2) + pow(y+ kSpace, 2))) > kBaseMeasure/2.0) {
        NSLog(@"探测到异常值");
        return;
    }
    
    _indicator.center = CGPointMake(_imgCicle.frame.size.width/kBaseMeasure * x + kSpace, _imgCicle.frame.size.height/kBaseMeasure * y + kSpace);
    
    //计算颜色偏移
    if (x + kSpace <= kBaseMeasure/2.0 + kSpace && y + kSpace <= kBaseMeasure/2.0 + kSpace) {
        _indicator.backgroundColor = [self colorAtPixel:CGPointMake(_imgCicle.frame.size.width/kBaseMeasure * x+kOffSet + kSpace, _imgCicle.frame.size.height/kBaseMeasure * y+kOffSet + kSpace)];
    }else if (x + kSpace >= kBaseMeasure/2.0 + kSpace && y + kSpace <= kBaseMeasure/2.0 + kSpace) {
        _indicator.backgroundColor = [self colorAtPixel:CGPointMake(_imgCicle.frame.size.width/kBaseMeasure * x-kOffSet + kSpace, _imgCicle.frame.size.height/kBaseMeasure * y+kOffSet + kSpace)];
    }else if (x + kSpace <= kBaseMeasure/2.0 + kSpace && y + kSpace >= kBaseMeasure/2.0 + kSpace) {
        _indicator.backgroundColor = [self colorAtPixel:CGPointMake(_imgCicle.frame.size.width/kBaseMeasure * x+kOffSet + kSpace, _imgCicle.frame.size.height/kBaseMeasure * y-kOffSet + kSpace)];
    }else if (x + kSpace >= kBaseMeasure/2.0 + kSpace && y + kSpace >= kBaseMeasure/2.0 + kSpace) {
        _indicator.backgroundColor = [self colorAtPixel:CGPointMake(_imgCicle.frame.size.width/kBaseMeasure * x-kOffSet + kSpace, _imgCicle.frame.size.height/kBaseMeasure * y-kOffSet + kSpace)];
    }
    
}

- (void)changeIndicatorSize:(CGSize)size borderWidth:(CGFloat)width
{
    _indicator.frame = CGRectMake(0, 0, size.width, size.height);
    _indicator.layer.borderWidth = width;
    _indicator.layer.cornerRadius = size.width/2.0;
}

#pragma mark --

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_touchBegin) {
        _touchBegin();
    }
    [self showAnimation:YES];
    [self calculateShowColor:touches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self calculateShowColor:touches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self showAnimation:NO];
    [self calculateShowColor:touches];
    if (_touchEnd) {
        _touchEnd();
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_touchEnd) {
        _touchEnd();
    }
}

- (void)showAnimation:(BOOL)isShow
{
    [UIView animateWithDuration:0.3 animations:^{
        if (isShow) {
            self->_indicator.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }else{
            self->_indicator.transform = CGAffineTransformIdentity;
        }
    }];
}

#pragma mark --
- (void)calculateShowColor:(NSSet<UITouch *> *)touches{
    UITouch *touchObj = touches.anyObject;
    CGPoint movePoint = [touchObj locationInView:self];                       // 得到滑动的点
    
    [self calculateCenterPointInView:movePoint];            //  计算得到真正的中心点和颜色
}

- (void)calculateCenterPointInView:(CGPoint)point{
    
    CGPoint center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);  // 中心点
    double radius = self.frame.size.width/2 - kSpace;          // 半径
    double dx = ABS(point.x - center.x);
    double dy = ABS(point.y - center.y);
    double angle = atan(dy/dx);
    if (isnan(angle)) angle = 0.0;
    double dist = sqrt(pow(dx,2) + pow(dy,2));
    double saturation = MIN(dist/radius,1.0);
    
    if (dist < 10) saturation = 0;
    if (point.x < center.x) angle = M_PI - angle;
    if (point.y > center.y) angle = 2.0*M_PI - angle;
    
    HSVType currentHSV = HSVTypeMake(angle/(2.0*M_PI), saturation, 1.0);
    
    [self centerPointValue:currentHSV];    // 计算中心点位置
}

- (void)centerPointValue:(HSVType)currentHSV{
    
    _currentHSVWithNew = currentHSV;
    _currentHSVWithNew.v = 1.0;
    double angle = _currentHSVWithNew.h*2.0*M_PI;
    CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    double radius = self.frame.size.width/2-kSpace;  //往里偏移一点
    radius *= _currentHSVWithNew.s;
    
    CGFloat x = center.x + cosf(angle)*radius;
    CGFloat y = center.y - sinf(angle)*radius;
    
    x = roundf(x - _indicator.frame.size.width/2) + _indicator.frame.size.width/2;
    y = roundf(y - _indicator.frame.size.height/2) + _indicator.frame.size.height/2;
    
    //计算颜色偏移(先转换成1000坐标)
    CGFloat X = (x - kSpace)/_imgCicle.frame.size.width*kBaseMeasure;
    CGFloat Y = (y - kSpace)/_imgCicle.frame.size.width*kBaseMeasure;
    
    CGPoint colorPoint = CGPointMake(x,y);
    CGFloat indicatorCenterX = (x - kSpace)/_imgCicle.frame.size.width*kBaseMeasure;
    CGFloat indicatorCenterY = (y - kSpace)/_imgCicle.frame.size.height*kBaseMeasure;
    if (X <= kBaseMeasure/2.0 + kSpace && Y <= kBaseMeasure/2.0 + kSpace) {
        colorPoint = CGPointMake(x + kOffSet, y + kOffSet);
        indicatorCenterX += kOffSet;
        indicatorCenterY += kOffSet;
    }else if (X >= kBaseMeasure/2.0 + kSpace && Y <= kBaseMeasure/2.0 + kSpace) {
        colorPoint = CGPointMake(x - kOffSet, y + kOffSet);
        indicatorCenterX -= kOffSet;
        indicatorCenterY += kOffSet;
    }else if (X <= kBaseMeasure/2.0 + kSpace && Y >= kBaseMeasure/2.0 + kSpace) {
        colorPoint = CGPointMake(x + kOffSet, y - kOffSet);
        indicatorCenterX += kOffSet;
        indicatorCenterY -= kOffSet;
    }else if (X >= kBaseMeasure/2.0 + kSpace && Y >= kBaseMeasure/2.0 + kSpace) {
        colorPoint = CGPointMake(x - kOffSet, y - kOffSet);
        indicatorCenterX -= kOffSet;
        indicatorCenterY -= kOffSet;
    }
    
    _indicator.center = CGPointMake(_imgCicle.frame.size.width/kBaseMeasure * indicatorCenterX + kSpace, _imgCicle.frame.size.height/kBaseMeasure * indicatorCenterY + kSpace);
    
    UIColor *color = [self colorAtPixel:colorPoint];
    if (color) {
        _indicator.backgroundColor = color;
        
        if (_currentColorBlock) {
            _currentColorBlock(color, roundf(indicatorCenterX), roundf(indicatorCenterY));
        }
    }
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return scaledImage;
}

//获取图片某一点的颜色
- (UIColor *)colorAtPixel:(CGPoint)point {
    if (!CGRectContainsPoint(CGRectMake(0.0f + kSpace, 0.0f + kSpace, _imgCicle.frame.size.width, _imgCicle.frame.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x-kSpace);
    NSInteger pointY = trunc(point.y-kSpace);
    UIImage *tmpImg = [self scaleImage:_imgCicle.image toScale:_imgCicle.frame.size.width/_imgCicle.image.size.width];
    CGImageRef cgImage = tmpImg.CGImage;
    NSUInteger width = tmpImg.size.width;
    NSUInteger height = tmpImg.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast |     kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    NSLog(@"R:%f* G:%f* B%f* A:%f",red,green,blue,alpha);
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
