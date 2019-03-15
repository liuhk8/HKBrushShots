//
//  HKLineView.m
//  HKBrushShots
//
//  Created by 刘华坤 on 2019/3/15.
//  Copyright © 2019 刘华坤. All rights reserved.
//

#import "HKLineView.h"

@interface HKLineView ()
{
    CGFloat _min_x;
    CGFloat _min_y;
    CGFloat _max_x;
    CGFloat _max_y;
    NSOperationQueue *myQueue; //创建线程队列
}
@end

@implementation HKLineView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.allLineInfosMArr = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

#pragma mark draw event开始绘画
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    if (self.allLineInfosMArr.count > 0) {
        for (int i=0; i<self.allLineInfosMArr.count; i++) {
            HKLineManager *lineManager = self.allLineInfosMArr[i];
            CGContextBeginPath(context);
            CGPoint startPoint = [[lineManager.linePointsMArr objectAtIndex:0] CGPointValue];
            CGContextMoveToPoint(context, startPoint.x, startPoint.y);
            if (lineManager.linePointsMArr.count>1) {
                for (int j=0; j<(lineManager.linePointsMArr.count-1); j++) {
                    CGPoint endPoint = [[lineManager.linePointsMArr objectAtIndex:j+1] CGPointValue];
                    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
                }
            }else {
                CGContextAddLineToPoint(context, startPoint.x, startPoint.y);
            }
            
            CGContextSetStrokeColorWithColor(context, lineManager.lineColor.CGColor);
            CGContextSetLineWidth(context, lineManager.lineWidth+1);
            CGContextStrokePath(context);
        }
    }
}

#pragma mark touch event
//触摸开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    HKLineManager *lineManager = [[HKLineManager alloc] init];
    //画线前判断，屏幕是否已存在有线了，有的画删除所有
    if (lineManager.linePointsMArr > 0) {
        [self cleanAllLine];
    }
    
    [self drawPaletteTouchesBeganWithWidth:self.currentLineWidth
                                  andColor:self.currentLineColor
                             andBeginPoint:[touch locationInView:self]];
    [self setNeedsDisplay];
}

//触摸移动
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray* MovePointArray=[touches allObjects];
    [self drawPaletteTouchesMovedWithPonit:[[MovePointArray objectAtIndex:0] locationInView:self]];
    [self setNeedsDisplay];
}

//触摸结束
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGFloat new_width = _max_x - _min_x;
    CGFloat new_height = _max_y - _min_y;
    CGRect rect = {_min_x, _min_y, new_width, new_height};
    [self.delegate getScreenShotImageViewRect:rect];
}

#pragma mark draw info edite event
//在触摸开始的时候 添加一条新的线条 并初始化
- (void)drawPaletteTouchesBeganWithWidth:(float)width andColor:(UIColor *)color andBeginPoint:(CGPoint)bPoint {
    //初始化线程队列
    myQueue = [[NSOperationQueue alloc] init];
    myQueue.maxConcurrentOperationCount = 1;
    
    _min_x = bPoint.x;
    _max_x = bPoint.x;
    _min_y = bPoint.y;
    _max_y = bPoint.y;
    
    HKLineManager *info = [[HKLineManager alloc] init];
    info.lineColor = color;
    info.lineWidth = width;
    [info.linePointsMArr addObject:[NSValue valueWithCGPoint:bPoint]];
    // NSLog(@"开始point==%.1f,%.1f",bPoint.x,bPoint.y);
    [self.allLineInfosMArr addObject:info];
}

//在触摸移动的时候 将现有的线条的最后一条的 point增加相应的触摸过的坐标
- (void)drawPaletteTouchesMovedWithPonit:(CGPoint)mPoint {
    HKLineManager *lastInfo = [self.allLineInfosMArr lastObject];
    
//    NSLog(@"x=%f",mPoint.x);
//    NSLog(@"y=%f",mPoint.y);
    
    //开启子线程
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        //取出最大最小的x,y
        if (mPoint.x < self->_min_x) {
            self->_min_x = mPoint.x;
        }
        
        if (mPoint.x > self->_max_x) {
            self->_max_x = mPoint.x;
        }
        
        if (mPoint.y < self->_min_y) {
            self->_min_y = mPoint.y;
        }
        
        if (mPoint.y > self->_max_y) {
            self->_max_y = mPoint.y;
        }
        
    }];
    //将子线程添加到队列中去
    [myQueue addOperation:operation];
    
    [lastInfo.linePointsMArr addObject:[NSValue valueWithCGPoint:mPoint]];
}

- (void)cleanAllLine {
    if ([self.allLineInfosMArr count]>0) {
        [self.allLineInfosMArr removeAllObjects];
        [self setNeedsDisplay];
    }
}

- (void)cleanBeforeLine {
    if ([self.allLineInfosMArr count]>0) {
        [self.allLineInfosMArr removeLastObject];
    }
    [self setNeedsDisplay];
}

@end
