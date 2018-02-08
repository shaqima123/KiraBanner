//
//  MBCBannerList.m
//  KiraBanner
//
//  Created by zj－db0737 on 2018/2/5.
//  Copyright © 2018年 zj－db0737. All rights reserved.
//

#import "MBCBannerList.h"

@interface MBCBannerList ()

@property (nonatomic, strong) NSArray * dataArray;

@end


@implementation MBCBannerList

- (instancetype)init {
    return [self initWithArray:nil];
}

- (instancetype)initWithArray:(NSArray *)array {
    NSAssert(array, @"dataArray cant be nil!");
    self = [super init];
    if (self) {
        _dataArray = array;
        _headNode = [[MBCBannerNode alloc] initWithData:_dataArray.firstObject];
        _headNode.index = 0;
        _current = _headNode;
        MBCBannerNode *ptr = _headNode;
        //初始化headnode
        for (int i = 1; i < _dataArray.count; i ++) {
            MBCBannerNode *newNode = [[MBCBannerNode alloc] initWithData:[_dataArray objectAtIndex:i]];
            newNode.index = i;
            [self insertNode:newNode after:ptr];
            ptr = newNode;
        }
        ptr = nil;
    }
    return self;
}

//插入节点之后的节点，node为nil时默认为head节点
- (void)insertNode:(MBCBannerNode *)newNode after:(MBCBannerNode *) node {
    if (node == nil) {
        newNode.lastNode = self.headNode;
        newNode.nextNode = self.headNode.nextNode;
        
        newNode.nextNode.lastNode = newNode;
        newNode.lastNode.nextNode = newNode;
    } else {
        newNode.lastNode = node;
        newNode.nextNode = node.nextNode;
        
        newNode.nextNode.lastNode = newNode;
        newNode.lastNode.nextNode = newNode;
    }
}

//删除节点之前的节点，node为nil时默认为head节点
- (void)deleteNodeBefore:(MBCBannerNode *)node {
    if (_headNode.lastNode == _headNode) {
        return;
    }
    if (node == nil) {
        _headNode.lastNode = _headNode.lastNode.lastNode;
        _headNode.lastNode.nextNode = nil;
        _headNode.lastNode.nextNode = _headNode;
    } else {
        node.lastNode = node.lastNode.lastNode;
        //如果删除的是头节点，重新赋值头节点为第二个节点
        if (node.lastNode.nextNode == _headNode) {
            _headNode = node;
        }
        node.lastNode.nextNode = nil;
        node.lastNode.nextNode = node;
    }
}

//删除节点之后的节点，node为nil时默认为head节点
- (void)deleteNodeAfter:(MBCBannerNode *)node {
    if (_headNode.nextNode == _headNode) {
        return;
    }
    if (node == nil) {
        _headNode.nextNode = _headNode.nextNode.nextNode;
        _headNode.nextNode.lastNode = nil;
        _headNode.nextNode.lastNode = _headNode;
    } else {
        node.nextNode = node.nextNode.nextNode;
        //如果删除的是头节点，重新赋值头节点为第二个节点
        if (node.nextNode.lastNode == _headNode) {
            _headNode = node.nextNode;
        }
        node.nextNode.lastNode = nil;
        node.nextNode.lastNode = node;
    }
}

//删除当前节点
- (void)deleteNode:(MBCBannerNode *)node {
    //TODO: check 是否真的删除了
    node.lastNode.nextNode = node.nextNode;
    node.nextNode.lastNode = node.lastNode;
    if (node == _headNode) {
        _headNode = node.nextNode;
    }
}

//寻找节点
- (MBCBannerNode *)findNodeWithIndex:(NSInteger) index {
    MBCBannerNode * cur = _headNode.lastNode;
    while (cur) {
        if (index == cur.index) {
            return cur;
        }
        if (cur == _headNode) {
            return nil;
        }
        cur = cur.lastNode;
    }
    return nil;
}


//销毁链表
- (void)destroyList {
    MBCBannerNode *cur = _headNode;
    while (cur.nextNode != _headNode) {
        [self deleteNodeBefore:nil];
    }
    _headNode = nil;
}

- (void)dealloc {
    [self destroyList];
}

//正向打印
- (void)printForward {
    NSLog(@"start print forward.\n");
    MBCBannerNode * cur = _headNode;
    while (cur) {
        NSLog(@"%ld -> ",(long)cur.index);
        NSLog(@"%@ -> ",(NSString *)cur.data);
        cur = cur.nextNode;
        if (cur == _headNode) {
            break;
        }
    }
    NSLog(@"finished print.\n");
}

//反向打印
- (void)printBackward {
    NSLog(@"start print backward.\n");
    MBCBannerNode * cur = _headNode.lastNode;
    while (cur) {
        NSLog(@"%ld -> ",(long)cur.index);
        NSLog(@"%@ -> ",(NSString *)cur.data);
        cur = cur.lastNode;
        if (cur == _headNode) {
            NSLog(@"%ld -> ",(long)cur.index);
            NSLog(@"%@ -> ",(NSString *)cur.data);
            break;
        }
    }
    NSLog(@"finished print.\n");
}


@end
