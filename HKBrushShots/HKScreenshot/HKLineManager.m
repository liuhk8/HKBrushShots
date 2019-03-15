//
//  HKLineManager.m
//  HKBrushShots
//
//  Created by 刘华坤 on 2019/3/15.
//  Copyright © 2019 刘华坤. All rights reserved.
//

#import "HKLineManager.h"

@implementation HKLineManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.linePointsMArr = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return self;
}

@end
