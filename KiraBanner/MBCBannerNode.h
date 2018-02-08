//
//  MBCBannerNode.h
//  KiraBanner
//
//  Created by zj－db0737 on 2018/2/5.
//  Copyright © 2018年 zj－db0737. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBCBannerNode : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) MBCBannerNode *lastNode;
@property (nonatomic, strong) MBCBannerNode *nextNode;
@property (nonatomic, strong) id data;

- (instancetype)initWithData:(id)data;

@end
