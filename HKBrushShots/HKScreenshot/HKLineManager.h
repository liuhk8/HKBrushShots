//
//  HKLineManager.h
//  HKBrushShots
//
//  Created by 刘华坤 on 2019/3/15.
//  Copyright © 2019 刘华坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HKLineManager : NSObject

@property (nonatomic,assign) float lineWidth;//线宽
@property (nonatomic,strong) UIColor *lineColor;//线颜色
@property (nonatomic,strong) NSMutableArray *linePointsMArr;//线点数组

@end

NS_ASSUME_NONNULL_END
