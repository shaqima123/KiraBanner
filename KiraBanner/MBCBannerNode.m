//
//  MBCBannerNode.m
//  KiraBanner
//
//  Created by zj－db0737 on 2018/2/5.
//  Copyright © 2018年 zj－db0737. All rights reserved.
//

#import "MBCBannerNode.h"

@implementation MBCBannerNode

- (instancetype)init {
    return [self initWithData:nil];
}

- (instancetype)initWithData:(id) data {
    NSAssert(data, @"data cant be nil!");
    self = [super init];
    if (self) {
        _data = data;
        _index = -1;
        _lastNode = self;
        _nextNode = self;
    }
    return self;
}

@end
