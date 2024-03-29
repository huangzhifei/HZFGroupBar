//
//  SFIMGroupBarChart.m
//  HZFGroupBar
//
//  Created by Eric Huang on 2019/12/8.
//  Copyright © 2019 hzf. All rights reserved.
//

#import "SFIMGroupBarChart.h"
#import "XAbscissaView.h"
#import "XAnimationLabel.h"
#import "XAuxiliaryCalculationHelper.h"
#import "Colours.h"
#import "CALayer+XLayerSelectHelper.h"

#define GradientFillColor1            \
    [UIColor colorWithRed:117 / 255.0 \
                    green:184 / 255.0 \
                     blue:245 / 255.0 \
                    alpha:1]          \
        .CGColor

#define GradientFillColor2                                                       \
    [UIColor colorWithRed:24 / 255.0 green:141 / 255.0 blue:240 / 255.0 alpha:1] \
        .CGColor

#define BarBackgroundFillColor \
    [UIColor colorWithRed:232 / 255.0 green:232 / 255.0 blue:232 / 255.0 alpha:1]

#define animationDuration 3

@interface SFIMGroupBarChart ()

@property (nonatomic, strong) XAbscissaView *abscissaView;
@property (nonatomic, strong) CABasicAnimation *pathAnimation;
@property (nonatomic, strong) NSMutableArray<UIColor *> *colorArray;
@property (nonatomic, strong) NSMutableArray<NSString *> *dataDescribeArray;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *dataNumberArray;
@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *layerArray;           // value layer
@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *backgroundLayerArray; // background layer
@property (nonatomic, strong) CALayer *coverLayer;
//@property(nonatomic, strong) NSMutableArray<XAnimationLabel*>* animationLabelArray;
@property (nonatomic, assign) BOOL isAnimation;

@end

@implementation SFIMGroupBarChart

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isAnimation = YES;
        self.bounces = NO;
        self.coverLayer = [CALayer layer];
    }
    return self;
}

- (void)refreshGroupBarChart {
    self.backgroundColor = [UIColor whiteColor];
    self.contentSize = [self computeContentSize];
}

//计算是否需要滚动
- (CGSize)computeContentSize {
    CGFloat width = self.frame.size.width / 6.0 * self.dataItemArray.count;
    CGFloat height = self.frame.size.height;
    return CGSizeMake(width, height);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self startAnimation:self.isAnimation];
}

- (void)refreshView {
    [self cleanPreDrawAndData];
    [self strokeChart];
}

- (void)startAnimation:(BOOL)animation {
    [self refreshView];
}

- (void)cleanPreDrawAndData {
    // remove layer
    [self.layerArray enumerateObjectsUsingBlock:^(CAShapeLayer *_Nonnull obj, NSUInteger idx,
                                                  BOOL *_Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    [self.backgroundLayerArray enumerateObjectsUsingBlock:^(CAShapeLayer *_Nonnull obj, NSUInteger idx,
                                                            BOOL *_Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    //    [self.animationLabelArray enumerateObjectsUsingBlock:^(XAnimationLabel *_Nonnull obj,
    //                                                           NSUInteger idx, BOOL *_Nonnull stop) {
    //        [obj removeFromSuperview];
    //    }];
    [self.coverLayer removeFromSuperlayer];

    // clean array
    //    [self.animationLabelArray removeAllObjects];
    [self.layerArray removeAllObjects];
    [self.backgroundLayerArray removeAllObjects];
    [self.colorArray removeAllObjects];
    [self.dataNumberArray removeAllObjects];
}

- (void)strokeChart {
    // data filter
    [self.dataItemArray
        enumerateObjectsUsingBlock:^(SFIMGroupBarItem *_Nonnull obj, NSUInteger idx,
                                     BOOL *_Nonnull stop) {
            //            [self.colorArray addObject:obj.color];
//            [self.dataNumberArray addObject:obj.dataNumberA];
            [self.dataNumberArray addObject:obj.datas[0].numberValue];
            [self.dataDescribeArray addObject:obj.dataDescribe];
        }];

    // background layer
    NSMutableArray<NSNumber *> *xArray = [[self getxArray] copy];
    NSMutableArray<NSValue *> *rectArray = [self getBackgroundRectArrayWithXArray:xArray];
    self.backgroundLayerArray = [self getBackgroundLayerWithRectArray:rectArray];
    [self.backgroundLayerArray enumerateObjectsUsingBlock:^(CAShapeLayer *_Nonnull obj, NSUInteger idx,
                                                            BOOL *_Nonnull stop) {
        [self.layer addSublayer:obj];
    }];

    // fill layer
    NSMutableArray<NSNumber *> *fillHeightArray = [[NSMutableArray alloc] init];
    [self.dataItemArray enumerateObjectsUsingBlock:^(SFIMGroupBarItem *_Nonnull obj, NSUInteger idx,
                                                     BOOL *_Nonnull stop) {
        CGFloat height = [[XAuxiliaryCalculationHelper shareCalculationHelper]
                             calculateTheProportionOfHeightByTop:self.top.doubleValue
                                                          bottom:self.bottom.doubleValue
                                                          height:self.dataNumberArray[idx]
                                                                     .doubleValue] *
                         self.bounds.size.height;
        [fillHeightArray addObject:@(height)];
    }];

    NSMutableArray<NSValue *> *fillRectArray = [[NSMutableArray alloc] init];
    [xArray enumerateObjectsUsingBlock:^(NSNumber *_Nonnull obj, NSUInteger idx,
                                         BOOL *_Nonnull stop) {
        // height - fillHeightArray[idx].doubleValue 计算起始Y
        CGRect fillRect = CGRectMake(
            obj.doubleValue - [self getBarWidthWithItemCount:xArray.count] / 2,
            [self getTotalBarHeight] - fillHeightArray[idx].doubleValue,
            [self getBarWidthWithItemCount:xArray.count],
            fillHeightArray[idx].doubleValue);
        [fillRectArray addObject:[NSValue valueWithCGRect:fillRect]];
    }];

    NSMutableArray *fillShapeLayerArray = [[NSMutableArray alloc] init];
    [fillRectArray enumerateObjectsUsingBlock:^(NSValue *_Nonnull obj,
                                                NSUInteger idx,
                                                BOOL *_Nonnull stop) {
        CGRect fillRect = obj.CGRectValue;
//        CAShapeLayer *fillRectShapeLayer = [self rectAnimationLayerWithBounds:fillRect fillColor:self.dataItemArray[idx].color];
        CAShapeLayer *fillRectShapeLayer = [self rectAnimationLayerWithBounds:fillRect fillColor:[UIColor waveColor]];
        
        // animation number label
        XAnimationLabel *topLabel = [self
            topLabelWithRect:CGRectMake(fillRect.origin.x, fillRect.origin.y - 15,
                                        fillRect.size.width, 15)
                   fillColor:[UIColor clearColor]
                        text:self.dataNumberArray[idx].stringValue];

        [self addSubview:topLabel];
//        [self.animationLabelArray addObject:topLabel];

        [topLabel countFromCurrentTo:topLabel.text.floatValue
                            duration:animationDuration];

        // toplabel center change
        CGPoint tempCenter = topLabel.center;
        topLabel.center = CGPointMake(topLabel.center.x,
                                      topLabel.center.y + fillRect.size.height);
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             topLabel.center = tempCenter;
                         }];

        [self.layer addSublayer:fillRectShapeLayer];
        [self.layerArray addObject:fillRectShapeLayer];
        [fillShapeLayerArray addObject:fillRectShapeLayer];
    }];
}

- (CGFloat)getTotalBarHeight {
    return self.bounds.size.height;
}

- (CGFloat)getBarWidthWithItemCount:(NSUInteger)count {
    return (self.bounds.size.width / count) / 3 * 2;
}

- (NSMutableArray *)getxArray {
    // x coordinates
    NSMutableArray<NSNumber *> *xArray = [[NSMutableArray alloc] init];
    [self.dataItemArray enumerateObjectsUsingBlock:^(SFIMGroupBarItem *_Nonnull obj, NSUInteger idx,
                                                     BOOL *_Nonnull stop) {
        CGFloat x = self.bounds.size.width *
                    [[XAuxiliaryCalculationHelper shareCalculationHelper]
                        calculateTheProportionOfWidthByIdx:idx
                                                     count:self.dataItemArray.count];
        [xArray addObject:@(x)];
    }];
    return xArray;
}

- (NSMutableArray *)getBackgroundRectArrayWithXArray:
    (NSMutableArray<NSNumber *> *)xArray {
    NSMutableArray<NSValue *> *rectArray = [[NSMutableArray alloc] init];
    [xArray enumerateObjectsUsingBlock:^(NSNumber *number, NSUInteger idx,
                                         BOOL *_Nonnull stop) {
        CGRect rect = CGRectMake(
            number.doubleValue - [self getBarWidthWithItemCount:xArray.count] / 2,
            0, [self getBarWidthWithItemCount:xArray.count],
            [self getTotalBarHeight]);
        [rectArray addObject:[NSValue valueWithCGRect:rect]];
    }];
    return rectArray;
}

- (NSMutableArray<CAShapeLayer *> *)getBackgroundLayerWithRectArray:
    (NSMutableArray<NSValue *> *)rectArray {
    NSMutableArray<CAShapeLayer *> *backgroundLayerArray =
        [[NSMutableArray alloc] init];
    // background layer
    [rectArray enumerateObjectsUsingBlock:^(NSValue *_Nonnull obj, NSUInteger idx,
                                            BOOL *_Nonnull stop) {
        CGRect rect = obj.CGRectValue;
        CAShapeLayer *rectShapeLayer =
            [self rectShapeLayerWithBounds:rect
                                 fillColor:BarBackgroundFillColor];
        [backgroundLayerArray addObject:rectShapeLayer];
    }];
    return backgroundLayerArray;
}

#pragma mark Get

#pragma mark HelpMethods

- (CAShapeLayer *)rectAnimationLayerWithBounds:(CGRect)rect
                                     fillColor:(UIColor *)fillColor {
    // real startPoint endPoint
    CGPoint startPoint = CGPointMake(rect.origin.x + (rect.size.width) / 2,
                                     (rect.origin.y + rect.size.height));
    CGPoint endPoint =
        CGPointMake(rect.origin.x + (rect.size.width) / 2, (rect.origin.y));

    CAShapeLayer *chartLine = [CAShapeLayer layer];
    chartLine.lineCap = kCALineCapSquare;
    chartLine.lineJoin = kCALineJoinRound;
    chartLine.lineWidth = rect.size.width;

    // animation path(beacause of line width...so animation path must defferent
    // with real path)
    CGPoint temStartPoint =
        CGPointMake(startPoint.x, startPoint.y + rect.size.width / 2);
    CGPoint temEndPoint =
        CGPointMake(endPoint.x, endPoint.y + rect.size.width / 2);
    UIBezierPath *temPath = [[UIBezierPath alloc] init];
    [temPath moveToPoint:temStartPoint];
    [temPath addLineToPoint:temEndPoint];

    chartLine.path = temPath.CGPath;
    chartLine.strokeStart = 0.0;
    chartLine.strokeEnd = 1.0;
    chartLine.strokeColor = fillColor.CGColor;
    [chartLine addAnimation:self.pathAnimation forKey:@"strokeEndAnimation"];
    // help to judge is touch in area
    chartLine.frameValue = [NSValue valueWithCGRect:rect];
    chartLine.selectStatusNumber = [NSNumber numberWithBool:NO];
    return chartLine;
}

- (CAShapeLayer *)rectShapeLayerWithBounds:(CGRect)rect
                                 fillColor:(UIColor *)fillColor {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    CAShapeLayer *rectLayer = [CAShapeLayer layer];
    rectLayer.path = path.CGPath;
    rectLayer.fillColor = fillColor.CGColor;
    rectLayer.path = path.CGPath;
    rectLayer.frameValue = [NSValue valueWithCGRect:rect];
    return rectLayer;
}

- (XAnimationLabel *)topLabelWithRect:(CGRect)rect
                            fillColor:(UIColor *)color
                                 text:(NSString *)text {
    XAnimationLabel *label = [XAnimationLabel topLabelWithFrame:rect text:text textColor:[UIColor black50PercentColor] fillColor:color];
    label.verticalAlignment = XVerticalAlignmentBottom;
    //  label.font = [UIFont systemFontOfSize:8];
    return label;
}

- (CAGradientLayer *)rectCoverGradientLayerWithBounds:(CGRect)rect {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = rect;
    gradientLayer.colors =
        @[ (__bridge id) GradientFillColor1, (__bridge id) GradientFillColor2 ];
    gradientLayer.startPoint = CGPointMake(0.5, 0);
    gradientLayer.endPoint = CGPointMake(0.5, 1);
    //    [gradientLayer addAnimation:[XAnimation
    //    getBarChartSpringAnimationWithLayer:gradientLayer] forKey:@""];
    [[XAnimation shareInstance] addLSSpringFrameAnimation:gradientLayer];
    return gradientLayer;
}

- (CABasicAnimation *)pathAnimation {
    _pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    _pathAnimation.duration = animationDuration;
    _pathAnimation.timingFunction = [CAMediaTimingFunction
        functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    _pathAnimation.fromValue = @0.0f;
    _pathAnimation.toValue = @1.0f;
    return _pathAnimation;
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint __block point = [[touches anyObject] locationInView:self];

    // touch whole bar
    [self.backgroundLayerArray enumerateObjectsUsingBlock:^(CALayer *_Nonnull obj,
                                                            NSUInteger idx,
                                                            BOOL *_Nonnull stop) {
        CAShapeLayer *shapeLayer = (CAShapeLayer *) obj;
        CGRect layerFrame = shapeLayer.frameValue.CGRectValue;

        if (CGRectContainsPoint(layerFrame, point)) {
            //上一次点击的layer,清空上一次的状态
            CAShapeLayer *preShapeLayer =
                (CAShapeLayer *)
                    self.layerArray[self.coverLayer.selectIdxNumber.intValue];
            preShapeLayer.selectStatusNumber = [NSNumber numberWithBool:NO];
            [self.coverLayer removeFromSuperlayer];

            // Notification + Delegate To CallBack
            [[NSNotificationCenter defaultCenter]
                postNotificationName:[XNotificationBridge shareXNotificationBridge]
                                         .TouchBarNotification
                              object:nil
                            userInfo:
                                @{
                                        [XNotificationBridge shareXNotificationBridge].
                                        BarIdxNumberKey : @(idx)
                                }];
            CAShapeLayer *subShapeLayer = (CAShapeLayer *) self.layerArray[idx];
            if (subShapeLayer.selectStatusNumber.boolValue == YES) {
                subShapeLayer.selectStatusNumber = [NSNumber numberWithBool:NO];
                [self.coverLayer removeFromSuperlayer];
                return;
            }
            BOOL boolValue = subShapeLayer.selectStatusNumber.boolValue;
            subShapeLayer.selectStatusNumber = [NSNumber numberWithBool:!boolValue];
            self.coverLayer =
                [self rectCoverGradientLayerWithBounds:subShapeLayer.frameValue
                                                           .CGRectValue];
            self.coverLayer.selectIdxNumber = @(idx);

            [subShapeLayer addSublayer:self.coverLayer];
            return;
        }
    }];
}

#pragma mark Notification Action

- (void)becomeAlive {
    [self startAnimation];
}

- (void)enterBackground {
    [self cleanPreDrawAndData];
}

#pragma mark - Setter & Getter

- (XAbscissaView *)abscissaView {
    if (!_abscissaView) {
        _abscissaView = [[XAbscissaView alloc] initWithFrame:CGRectMake(0,
                                                                        self.frame.size.height - AbscissaHeight,
                                                                        self.contentSize.width,
                                                                        AbscissaHeight)
                                               dataItemArray:self.dataItemArray
                                               configuration:nil];
        _abscissaView.backgroundColor = [UIColor whiteColor];
    }
    return _abscissaView;
}

@end
