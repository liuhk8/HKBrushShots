//
//  HKLineView.h
//  HKBrushShots
//
//  Created by 刘华坤 on 2019/3/15.
//  Copyright © 2019 刘华坤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKLineManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HKScreenShotImageViewRectDelegate <NSObject>

- (void)getScreenShotImageViewRect:(CGRect)rect;

@end

@interface HKLineView : UIView

@property (nonatomic,assign) float currentLineWidth;
@property (nonatomic,strong) UIColor *currentLineColor;
@property (nonatomic,strong) NSMutableArray *allLineInfosMArr;
@property (nonatomic,weak) id<HKScreenShotImageViewRectDelegate> delegate;

/**
 清空所有的线
 */
-(void)cleanAllLine;

/**
 撤销上一条线
 */
-(void)cleanBeforeLine;

@end

NS_ASSUME_NONNULL_END
