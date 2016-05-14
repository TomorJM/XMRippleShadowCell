//
//  XMRippleShadowCell.m
//  XMRippleShadowCellDemo
//
//  Created by joker on 16/5/4.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "XMRippleShadowCell.h"

@interface XMRippleShadowCell ()<UIGestureRecognizerDelegate>
/** 动画 */
@property (nonatomic,strong) CABasicAnimation *rippleAnimation;
/** 阴影layer */
@property (nonatomic,strong) CAShapeLayer *rippleLayer;
@property (nonatomic,strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic,strong) UITapGestureRecognizer *tapGestureRecognizer;
/** 手指在屏幕上的触摸点 */
@property (nonatomic,assign) CGPoint startPoint;
/** 动画是否完成 */
@property (nonatomic,assign) BOOL animationFinished;
/** 动画是否在进行 */
@property (nonatomic,assign) BOOL animationProcessing;
/** 是否有手指按在屏幕上 */
@property (nonatomic,assign) BOOL fingerOnScreen;

@property (nonatomic,assign) BOOL touchCancelledOrEnded;


@property (nonatomic,assign) CGFloat tapDelay;

@end

#define XMSlowAnimationDuration 2.0
#define XMScale 6

@implementation XMRippleShadowCell

static void excute_block_after(NSTimeInterval delay, void (^block)(void))
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupInit];
}

- (void)setupInit
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _animationFinished = NO;
    _animationProcessing = NO;
    _fingerOnScreen = NO;
    
    _tapDelay = 0.1f;
    
    self.layer.masksToBounds = YES;

}




-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"touchesBegan");
    [super touchesBegan:touches withEvent:event];
    _touchCancelledOrEnded = NO;
    _fingerOnScreen = YES;
    excute_block_after(_tapDelay, ^{
            [self creatAnimationWithGestureRecognizer:[touches anyObject]];
        
    });
    
    
    
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
//    NSLog(@"touchesMoved");
    _touchCancelledOrEnded = YES;
    [self accelerateAnimation];
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"touchesEnded");
    [super touchesEnded:touches withEvent:event];
    if (_animationFinished == YES && _animationProcessing == NO) {
        [_rippleLayer removeFromSuperlayer];
        _fingerOnScreen = NO;
        _touchCancelledOrEnded = YES;
        return;
    }
    _fingerOnScreen = NO;
    _touchCancelledOrEnded = YES;
    [self accelerateAnimation];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"touchesCancelled");
    [super touchesCancelled:touches withEvent:event];
    if (_animationFinished == YES && _animationProcessing == NO) {
        [_rippleLayer removeFromSuperlayer];
        _fingerOnScreen = NO;
        _touchCancelledOrEnded = YES;
        return;
    }
    _fingerOnScreen = NO;
    _touchCancelledOrEnded = YES;
    [self accelerateAnimation];
}


/**
 *  根据直径计算圆形path
 *
 *  @param diameter 直径
 *
 *  @return path
 */
- (UIBezierPath *)pathWithDiameter:(CGFloat)diameter {
    return [UIBezierPath bezierPathWithOvalInRect:CGRectMake((CGRectGetWidth(self.bounds) - diameter) / 2, (CGRectGetHeight(self.bounds) - diameter) / 2, diameter, diameter)];
}



#pragma mark - AnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
//    NSLog(@"animationDidStart");
    _animationProcessing = YES;
    _animationFinished = NO;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
//    NSLog(@"animationDidStop");
    _animationFinished = YES;
    _animationProcessing = NO;
    if (_touchCancelledOrEnded == YES && _fingerOnScreen == NO) {
        [_rippleLayer removeFromSuperlayer];
    }
}



/**
 *  创建动画
 *
 *  @param touch 触摸点
 */

- (void)creatAnimationWithGestureRecognizer:(UITouch *)touch
{
    if (_animationProcessing) {
        return;
    }
    //获取触摸点位置
    CGPoint touchPoint = [touch locationInView:self];
        _startPoint = touchPoint;
    //创建初始曲线
    CGRect circleRect = CGRectMake(touchPoint.x - 1, touchPoint.y -1 , 2, 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    //创建layer
    _rippleLayer = [CAShapeLayer layer];
    _rippleLayer.fillColor = [UIColor lightGrayColor].CGColor;
    _rippleLayer.opacity = 0.3;
    _rippleLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    _rippleLayer.lineWidth = 0.1f;
    _rippleLayer.path = path.CGPath;
    [self.contentView.layer addSublayer:_rippleLayer];
    //计算最终直径
    CGFloat diameter = sqrt(self.bounds.size.width * self.bounds.size.width + self.bounds.size.height * self.bounds.size.height) + 10;
    UIBezierPath *finalBezierPath = [self pathWithDiameter:diameter];
    //基础动画
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.delegate = self;
    animation.keyPath = @"path";
    animation.toValue = (id)finalBezierPath.CGPath;
    if (!_touchCancelledOrEnded) {
        animation.duration = XMSlowAnimationDuration;
        _fingerOnScreen = YES;
    }else
    {
        animation.duration = XMSlowAnimationDuration / XMScale;
        _fingerOnScreen = NO;
    }
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    _rippleAnimation = animation;
    [_rippleLayer addAnimation:animation forKey:@"changePath"];
    
}
/**
 *  加速动画
 */
- (void)accelerateAnimation
{
    CFTimeInterval pausedTime = [_rippleLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    _rippleLayer.timeOffset = pausedTime;
    _rippleLayer.beginTime = CACurrentMediaTime();
    _rippleLayer.speed = XMScale;
}

//########################################
///**
// *  处理长按手势
// *
// *  @param longPressGestureRecognizer 长按手势
// */
//- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)longPressGestureRecognizer
//{
//    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
//        // 创建动画
//        [self creatAnimationWithGestureRecognizer:longPressGestureRecognizer];
//
//    }
//    if((longPressGestureRecognizer.state == UIGestureRecognizerStateEnded || longPressGestureRecognizer.state == UIGestureRecognizerStateCancelled))
//    {
//        // 标记
//        _fingerOnScreen = NO;
//        if (_animationProcessing == NO && _animationFinished == YES) {
//            // 离开屏幕,动画结束,移除
//            [_rippleLayer removeFromSuperlayer];
//        }else
//        {
//            // 离开屏幕,动画没有结束,加速动画
//            [self accelerateAnimation];
//
//        }
//    }
//    if (longPressGestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        [self accelerateAnimation];
////        CGPoint testPoint = [longPressGestureRecognizer locationInView:self];
////        if (![self pointInside:testPoint withEvent:nil]) {
////            NSLog(@"触摸点不在视图内");
////        }
//    }
//}
///**
// *  处理单击手势
// *
// *  @param tapGesture 单击手势
// */
//- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture
//{
//    //创建动画
//    [self creatAnimationWithGestureRecognizer:tapGesture];
//}


#define mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
//    //    CGPoint currentPoint = [gestureRecognizer locationInView:self.view];
//    //    if (CGRectContainsPoint(CGRectMake(0, 0, 100, 100), currentPoint) ) {
//    //        return YES;
//    //    }
//    //
//    //    return NO;
//    NSLog(@"gestureRecognizerShouldBegin---%@",gestureRecognizer);
//    
//    return YES;
//}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//
//{
//    
//    return YES;
//    
//}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    // 获取点击的view的类名
////    NSLog(@"shouldReceiveTouch---%@\n",gestureRecognizer);
//
////     NSLog(@"%@", NSStringFromClass([touch.view class]));
//    
//    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
//    
////    if ([NSStringFromClass([gestureRecognizer.view class]) isEqualToString:@"UITableViewCellContentView"] || [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
////        
////        return NO;
////        
////    }
////    return  YES;
//    
////        if ([gestureRecognizer isEqual:_longPressGestureRecognizer] || [gestureRecognizer isEqual:_tapGestureRecognizer]) {
////        return YES;
////    }else
////        return NO;
//    
//    
//    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
//
//        return NO;
//        
//    }
//    
//    else {
//        
//        return YES;
//        
//    }
//
//}



@end
