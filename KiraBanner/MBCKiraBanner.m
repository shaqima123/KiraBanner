//
//  MBCKiraBanner.m
//  KiraBanner
//
//  Created by zj－db0737 on 2018/2/5.
//  Copyright © 2018年 zj－db0737. All rights reserved.
//

#import "MBCKiraBanner.h"

@interface MBCKiraBanner () <UIScrollViewDelegate> {
    CGFloat newx;
    CGFloat oldx;
    BOOL scrollLeft;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UIView *rightView;

////2
//@property (nonatomic, strong) MBCBannerList * bannerList;

@property (nonatomic, strong) NSMutableSet *reuseCells;

@end

@implementation MBCKiraBanner

#pragma mark init methods

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];
    self.reuseCells = [[NSMutableSet alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    _currentIndex = 0;
    //TODO:
//    if ([self shouldOffsetScrollViewInsets]) {
//
//    }
    
    //    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = [UIColor redColor];
    self.pageControl.backgroundColor = [UIColor blueColor];

}

- (void)dealloc {
    [self.reuseCells removeAllObjects];
    self.reuseCells = nil;
}

#pragma mark UI methods

- (void)updateScrollView {
    [self.scrollView setFrame:CGRectMake(_scrollViewEdge.left, _scrollViewEdge.top, self.frame.size.width - _scrollViewEdge.left - _scrollViewEdge.right, self.frame.size.height - _scrollViewEdge.top - _scrollViewEdge.bottom)];
}

- (void)updatePageControl {
    [self.pageControl setFrame:CGRectMake(_pageControlEdge.left, _pageControlEdge.top, self.frame.size.width - _pageControlEdge.left - _pageControlEdge.right, self.frame.size.height - _pageControlEdge.top - _pageControlEdge.bottom)];
}

- (void)initCellsInCircleMode {
    //循环模式不支持设置contentEdge
    NSInteger itemCount = 3;
    CGFloat scrollViewWidth = self.itemSpace + (self.itemWidth + self.itemSpace) * itemCount;
    CGFloat itemHeight = self.scrollView.frame.size.height - self.contentEdge.top - self.contentEdge.bottom;
    self.scrollView.contentSize = CGSizeMake(scrollViewWidth, self.scrollView.frame.size.height);
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentSize.width/2, 0) animated:NO];
    
    float leftEdgeForIndex = self.itemSpace;
    self.leftView = [self.dataSource kiraBanner:self viewForItemAtIndex:self.numberOfItems -1];
    self.leftView.frame = CGRectMake(leftEdgeForIndex,
                            self.contentEdge.top,
                            self.itemWidth,
                            itemHeight);
    [self.scrollView insertSubview:self.leftView atIndex:0];
    leftEdgeForIndex += self.itemWidth + self.itemSpace;
    
    self.centerView = [self.dataSource kiraBanner:self viewForItemAtIndex:0];
    self.centerView.frame = CGRectMake(leftEdgeForIndex,
                            self.contentEdge.top,
                            self.itemWidth,
                            itemHeight);
    [self.scrollView insertSubview:self.centerView atIndex:0];
    leftEdgeForIndex += self.itemWidth + self.itemSpace;
    
    self.rightView = [self.dataSource kiraBanner:self viewForItemAtIndex:1];
    self.rightView.frame = CGRectMake(leftEdgeForIndex,
                                self.contentEdge.top,
                                self.itemWidth,
                                itemHeight);
    [self.scrollView insertSubview:self.rightView atIndex:0];
}

- (void)reloadViewsInCircleMode {
    long leftIndex,rightIndex;
    //更换判断左右滑的方式，暂时假设只有3个cell
    if (_scrollView.contentOffset.x > self.itemWidth + self.itemSpace * 2 + self.itemWidth / 2) {
        _currentIndex = (_currentIndex + 1) % self.numberOfItems;
    } else if (_scrollView.contentOffset.x < self.itemWidth + self.itemSpace * 2 + self.itemWidth / 2) {
        _currentIndex = (_currentIndex + self.numberOfItems - 1) % self.numberOfItems;
    }
    leftIndex = (_currentIndex + self.numberOfItems - 1) % self.numberOfItems;
    rightIndex = (_currentIndex + 1) % self.numberOfItems;
    
    self.centerView = [self.dataSource kiraBanner:self viewForItemAtIndex:_currentIndex];
    self.leftView = [self.dataSource kiraBanner:self viewForItemAtIndex:leftIndex];
    self.rightView = [self.dataSource kiraBanner:self viewForItemAtIndex:rightIndex];
}

- (void)refreshView {
    if (CGRectIsNull(self.scrollView.frame)) {
        return;
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInKiraBanner:)]) {
        _numberOfItems = [self.dataSource numberOfItemsInKiraBanner:self];
    }
    NSInteger itemCount = 0;
    if (_isCircle) {
     
        
        
//        for (UIView *cellView in [self cellSubView]) {
//            //左右保留一个cell不回收
//            if (cellView.frame.origin.x + cellView.frame.size.width < self.scrollView.contentOffset.x - cellView.frame.size.width - self.itemSpace) {
//                [self recycleCell:cellView];
//            }
//
//            if (cellView.frame.origin.x > self.scrollView.contentOffset.x + self.scrollView.frame.size.width + self.itemSpace + cellView.frame.size.width) {
//                [self recycleCell:cellView];
//            }
//        }
//
//
//        float sIndex = self.scrollView.contentOffset.x / (self.itemSpace + self.itemWidth);
//        int startIndex = MAX(0 , floor(sIndex));
//        float eIndex = sIndex + self.scrollView.frame.size.width / (self.itemSpace + self.itemWidth);
//        int endIndex = MIN(self.numberOfItems, ceil(eIndex));
//        CGFloat itemHeight = self.scrollView.frame.size.height - self.contentEdge.top - self.contentEdge.bottom;
//
    } else {
        itemCount = _numberOfItems;
        CGFloat scrollViewWidth = self.contentEdge.left + self.contentEdge.right + self.itemWidth * itemCount + self.itemSpace * (itemCount - 1);
        self.scrollView.contentSize = CGSizeMake(scrollViewWidth, self.scrollView.frame.size.height);
        
        for (UIView *cellView in [self cellSubView]) {
            if (cellView.frame.origin.x + cellView.frame.size.width < self.scrollView.contentOffset.x) {
                [self recycleCell:cellView];
            }
            if (cellView.frame.origin.x > self.scrollView.contentOffset.x + self.scrollView.frame.size.width) {
                [self recycleCell:cellView];
            }
        }
        
        float sIndex = (self.scrollView.contentOffset.x - self.contentEdge.left + self.itemSpace)/(self.itemSpace + self.itemWidth);
        //需要显示的item最小index
        int startIndex = MAX(0, floor(sIndex));
        float eIndex = sIndex + self.scrollView.frame.size.width / (self.itemSpace + self.itemWidth);
        //需要显示的item最大index
        int endIndex = MIN(itemCount, ceil(eIndex));
        
        CGFloat itemHeight = self.scrollView.frame.size.height - self.contentEdge.top - self.contentEdge.bottom;
        for (int index = startIndex; index < endIndex; index ++) {
            UIView *cell = [self cellForIndex:index];
            if (!cell) {
                UIView *cell = [self.dataSource kiraBanner:self viewForItemAtIndex:index];
                float leftEdgeForIndex = self.contentEdge.left + index * (self.itemWidth + self.itemSpace);
                cell.frame = CGRectMake(leftEdgeForIndex,
                                        self.contentEdge.top,
                                        self.itemWidth,
                                        itemHeight);
                [self.scrollView insertSubview:cell atIndex:0];
            }
        }
    }
    
  
//    if ([self isListStructure]) {
//        NSLog(@"isList\n\n");
//        for (int index = startIndex; index < endIndex; index ++) {
//            UIView *cell = [self cellForIndex:index];
//            if (!cell) {
//                UIView *cell = [self.dataSource kiraBanner:self viewForNode:[self.bannerList findNodeWithIndex:index]];
//                float leftEdgeForIndex = self.contentEdge.left + index * (self.itemWidth + self.itemSpace);
//                cell.frame = CGRectMake(leftEdgeForIndex,
//                                        self.contentEdge.top,
//                                        self.itemWidth,
//                                        itemHeight);
//                [self.scrollView insertSubview:cell atIndex:0];
//            }
//        }
//    } else {
//    }
}

//- (UIView *)
- (void)layoutSubviews {
    [super layoutSubviews];
    //设置子视图的frame
    [self updateScrollView];
    [self updatePageControl];
    if (self.isCircle) {
        [self initCellsInCircleMode];
    }
    [self refreshView];
}


#pragma mark cell

- (void)regiseterClassForCells: (Class) cellClass {
    self.cellClass = cellClass;
}

- (UIView *)dequeueReusableCell {
    UIView *cell = [self.reuseCells anyObject];
    if (cell) {
        NSLog(@"add cell");
        [self.reuseCells removeObject:cell];
    }
    if (!cell) {
        NSLog(@"new cell");
        cell = [[self.cellClass alloc] init];
    }
    return  cell;
}

- (NSArray *) cellSubView {
    NSMutableArray * cells = [[NSMutableArray alloc] init];
    for (UIView *subView in self.scrollView.subviews) {
        if ([subView isKindOfClass:[_cellClass class]]) {
            [cells addObject:subView];
        }
    }
    return [cells copy];
}

- (UIView *) cellForIndex: (NSInteger)index {
    float leftEdgeForIndex = self.contentEdge.left + index * (self.itemWidth + self.itemSpace);
    for (UIView *cellView in [self cellSubView]) {
        if (cellView.frame.origin.x == leftEdgeForIndex) {
            return cellView;
        }
    }
    return nil;
}

- (void)recycleCell: (UIView *)cell {
    [self.reuseCells addObject:cell];
    [cell removeFromSuperview];
}

#pragma mark private methods
//- (BOOL)isListStructure {
//    //如果有设置dataArray，则用List方法
//    if (self.dataArray) {
//        return YES;
//    }
//    return NO;
//}
- (BOOL)shouldOffsetScrollViewInsets {
    UIResponder *nextResponder = self;
    do {
        nextResponder = [nextResponder nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]){
            return ((UIViewController *)nextResponder).automaticallyAdjustsScrollViewInsets;
        }
    } while (nextResponder != nil);
    return NO;
}

#pragma mark get-set
- (void)setPageControlEdge:(UIEdgeInsets)pageControlEdge {
    _pageControlEdge = pageControlEdge;
    [self updatePageControl];
}

- (void)setScrollViewEdge:(UIEdgeInsets)scrollViewEdge {
    _scrollViewEdge = scrollViewEdge;
    [self updateScrollView];
}

////2
//- (void)setDataArray:(NSArray *)dataArray {
//    _dataArray = dataArray;
//    _bannerList = [[MBCBannerList alloc] initWithArray:dataArray];
//}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
    }
    return _pageControl;
}


#pragma scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
//    newx = self.scrollView.contentOffset.x;
//    if (newx != oldx) {
//        if (newx > oldx) {
//            scrollLeft = NO;
//        } else {
//            scrollLeft = YES;
//        }
//        oldx = newx;
//    }
//    if (scrollView.contentOffset.x <= 0 || self.scrollView.contentOffset.x >= scrollView.contentSize.width - self.scrollView.frame.size.width) {
//        [scrollView setContentOffset:CGPointMake(0, 0)];
//    }
    [self refreshView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self reloadViewsInCircleMode];
    [_scrollView setContentOffset:CGPointMake(self.itemWidth + self.itemSpace * 2 + self.itemWidth / 2, 0) animated:NO];
}
@end
