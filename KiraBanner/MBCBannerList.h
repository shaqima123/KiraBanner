//
//  MBCBannerList.h
//  KiraBanner
//
//  Created by zj－db0737 on 2018/2/5.
//  Copyright © 2018年 zj－db0737. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBCBannerNode.h"

@interface MBCBannerList : NSObject

@property (nonatomic, strong, readonly) MBCBannerNode * headNode;
@property (nonatomic, strong) MBCBannerNode * current;

- (instancetype)initWithArray:(NSArray *)array;

//插入节点之后的节点，node为nil时默认为head节点
- (void)insertNode:(MBCBannerNode *)newNode after:(MBCBannerNode *) node;

//删除节点之前的节点，node为nil时默认为head节点
- (void)deleteNodeBefore:(MBCBannerNode *)node;

//删除节点之后的节点，node为nil时默认为head节点
- (void)deleteNodeAfter:(MBCBannerNode *)node;

//删除当前节点
- (void)deleteNode:(MBCBannerNode *)node;

//寻找节点
- (MBCBannerNode *)findNodeWithIndex:(NSInteger) index;

//销毁链表
- (void)destroyList;

//正向打印
- (void)printForward;

//反向打印
- (void)printBackward;
@end
