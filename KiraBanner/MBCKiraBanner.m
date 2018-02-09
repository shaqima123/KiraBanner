//
//  MBCKiraBanner.m
//  KiraBanner
//
//  Created by zj－db0737 on 2018/2/5.
//  Copyright © 2018年 zj－db0737. All rights reserved.
//

#import "MBCKiraBanner.h"
#import <objc/runtime.h>

@interface MBCKiraBanner () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableSet *reuseCells;
@property (nonatomic, strong) NSMutableArray * cells;
/**
 *  计时器用到的页数
 */
@property (nonatomic, assign) NSInteger page;

@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, assign) NSInteger pageCount;
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
    self.clipsToBounds = YES;
    self.pageCount = 0;
    self.isOpenAutoScroll = YES;
    self.contentEdge = UIEdgeInsetsMake(30, 20, 30, 20);
    _currentIndex = 0;
    _minimumPageAlpha = 1.0;
    _autoTime = 5.0;
    self.visibleRange = NSMakeRange(0, 0);
    self.reuseCells = [[NSMutableSet alloc] init];
    self.cells = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    _currentIndex = 0;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = [UIColor redColor];
    [self.scrollView setFrame:self.bounds];
    [self addSubview:self.scrollView];
}

- (void)dealloc {
    [self.reuseCells removeAllObjects];
    self.reuseCells = nil;
    [self.cells removeAllObjects];
    self.cells = nil;
}

#pragma mark UI methods

- (void)reloadData {
    _needsReload = YES;
    //TODO: 判断scrollview里面的子view是否符合Class注册类型？？
    [self stopTimer];
    if (_needsReload) {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInKiraBanner:)]) {
            _numberOfItems = [self.dataSource numberOfItemsInKiraBanner:self];
            if (self.isCircle) {
                _pageCount = self.numberOfItems == 1 ? 1 : self.numberOfItems * 3;
            } else {
                _pageCount = self.numberOfItems == 1 ? 1 : self.numberOfItems;
            }
            if (_pageCount == 0) {
                return;
            }
            //TODO:设置pagecontrol的number
        }
        //重置page的宽度
        CGFloat width = _scrollView.bounds.size.width - 2 * self.contentEdge.left - 2 * self.contentEdge.right;
        _pageSize = CGSizeMake(width, width * 9 / 16);
        if (self.delegate && [self.delegate respondsToSelector:@selector(sizeForPageInKiraBanner:)]) {
           _pageSize = [self.delegate sizeForPageInKiraBanner:self];
        }
        
        [_reuseCells removeAllObjects];
        _visibleRange = NSMakeRange(0, 0);
        //TODO:是否需要remove cells？
        switch (self.bannerType) {
            case MBCKiraBannerTypeHorizontal: {
                [self.scrollView setFrame:CGRectMake(0, 0, _pageSize.width, _pageSize.height)];
                [self.scrollView setContentSize:CGSizeMake(_pageSize.width * _pageCount, 0)];
                _scrollView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                
                if (self.numberOfItems > 1) {
                    if (self.isCircle) {
                        [_scrollView setContentOffset:CGPointMake(_pageSize.width * self.numberOfItems, 0) animated:NO];
                        self.page = self.numberOfItems;
                        [self startTimer];
                    } else {
                        [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                        self.page = self.numberOfItems;
                    }
                }
                
            }
                break;
            case MBCKiraBannerTypeVertical:
                
                break;
            default:
                break;
        }
        _needsReload = NO;
    }
    
    [self setVisibleCellsAtContentOffset:_scrollView.contentOffset];
    [self refreshView];
}


- (void)setVisibleCellsAtContentOffset:(CGPoint)offset {
    CGPoint startPoint = CGPointMake(offset.x - _scrollView.frame.origin.x, offset.y - _scrollView.frame.origin.y);
    CGPoint endPoint = CGPointMake(startPoint.x + self.bounds.size.width, startPoint.y + self.bounds.size.height);
    switch (self.bannerType) {
        case MBCKiraBannerTypeHorizontal: {
            //There is a problem
            for (UIView *cellView in [self cellSubView]) {
                if (cellView.frame.origin.x + cellView.frame.size.width < startPoint.x) {
                    [self recycleCell:cellView];
                }
                if (cellView.frame.origin.x > endPoint.x) {
                    [self recycleCell:cellView];
                }
            }
            NSInteger startIndex = MAX(0, floor(startPoint.x / _pageSize.width));
            NSInteger endIndex = MIN(_pageCount, ceil(endPoint.x / _pageSize.width));
            
            //TODO:是否需要向前向后扩展一个?
            self.visibleRange = NSMakeRange(startIndex, endIndex - startIndex + 1);
            for (NSInteger i = startIndex; i < endIndex ; i++) {
                [self fillPageAtIndex:i];
            }
        }
            break;
        case MBCKiraBannerTypeVertical: {
            
        }
            break;
        default:
            break;
    }
    
}

- (void)fillPageAtIndex:(NSInteger)index {
    UIView *cell = [self cellForIndex:index];
    if (!cell) {
        UIView *cell = [self.dataSource kiraBanner:self viewForItemAtIndex:index % self.numberOfItems];
        switch (self.bannerType) {
            case MBCKiraBannerTypeHorizontal: {
                float originX = index * self.pageSize.width;
                cell.frame = CGRectMake(originX,
                                        self.contentEdge.top,
                                        self.pageSize.width,
                                        self.pageSize.height);
            }
                break;
            case MBCKiraBannerTypeVertical:{
        
            }
                break;
            default:
                break;
        }
        //将cellforindex方法的地址作为objc_setAssociatedObject的key，保证唯一性
        objc_setAssociatedObject(cell, @selector(cellForIndex:),[NSNumber numberWithInteger:index], OBJC_ASSOCIATION_COPY);
        [self.scrollView insertSubview:cell atIndex:0];
    }
}

- (void)refreshView {
    if (CGRectIsNull(self.scrollView.frame)) {
        return;
    }
    switch (self.bannerType) {
        case MBCKiraBannerTypeHorizontal: {
            CGFloat offset = _scrollView.contentOffset.x;
            for (NSInteger i = self.visibleRange.location; i < self.visibleRange.location + self.visibleRange.length ; i++) {
                UIView *cell = [self cellForIndex:i];
                CGFloat origin = cell.frame.origin.x;
                CGFloat delta = fabs(origin - offset);
                
                CGRect originCellFrame = CGRectMake(_pageSize.width * i, 0, _pageSize.width, _pageSize.height);
                if (delta < _pageSize.width) {
//                    cell.alpha = (delta / _pageSize.width) * _minimumPageAlpha;
                    //TODO:把contentEdge改掉
                    CGFloat leftRightInset = self.contentEdge.left * delta / _pageSize.width;
                    CGFloat topBottomInset = self.contentEdge.top * delta / _pageSize.width;

                    cell.layer.transform = CATransform3DMakeScale((_pageSize.width-leftRightInset*2)/_pageSize.width,(_pageSize.height-topBottomInset*2)/_pageSize.height, 1.0);
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset));
                } else {
                    cell.layer.transform = CATransform3DMakeScale((_pageSize.width-self.contentEdge.left*2)/_pageSize.width,(_pageSize.height-self.contentEdge.top*2)/_pageSize.height, 1.0);

                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(self.contentEdge.top, self.contentEdge.left, self.contentEdge.bottom, self.contentEdge.right));
                }
            }
        }
            break;
        case MBCKiraBannerTypeVertical: {
            
        }
            break;
            
        default:
            break;
    }
}

//- (UIView *)
- (void)layoutSubviews {
    [super layoutSubviews];
    //设置子视图的frame
    [self refreshView];
}


#pragma mark cell

- (void)regiseterClassForCells: (Class) cellClass {
    self.cellClass = cellClass;
}

- (UIView *)dequeueReusableCell {
    UIView *cell = [self.reuseCells anyObject];
    NSLog(@"\nreuseCells:%@\n",self.reuseCells.description);
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
    for (UIView *cellView in [self cellSubView]) {
        NSNumber *value = objc_getAssociatedObject(cellView, @selector(cellForIndex:));
        if (value.integerValue == index) {
            return cellView;
        }
    }
    return nil;
}

//- (UIView *) cellForIndex: (NSInteger)index {
//    float oringinX = index * _pageSize.width;
//    for (UIView *cellView in [self cellSubView]) {
//        if (cellView.frame.origin.x == oringinX) {
//            return cellView;
//        }
//    }
//    return nil;
//}

- (void)recycleCell: (UIView *)cell {
    objc_removeAssociatedObjects(cell);
    [self.reuseCells addObject:cell];
    [cell removeFromSuperview];
}

#pragma mark private methods

- (void)startTimer {
    
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)adjustCenterSubview {
    if (self.isOpenAutoScroll && self.numberOfItems > 0) {
        [_scrollView setContentOffset:CGPointMake(_pageSize.width * self.page, 0) animated:NO];
    }
}

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

#pragma mark auto play
- (void)autoPlay {
    
}

#pragma mark get-set

- (void)setContentEdge:(UIEdgeInsets)contentEdge {
    _contentEdge = UIEdgeInsetsMake(contentEdge.top * 0.5, contentEdge.left * 0.5, contentEdge.bottom * 0.5, contentEdge.right * 0.5);
}

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

- (void)scrollToPage:(NSUInteger)pageNumber {
    if (pageNumber < _pageCount) {
        
        //首先停止定时器
        [self stopTimer];
        
        if (self.isCircle) {
            
            self.page = pageNumber + self.numberOfItems;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startTimer) object:nil];
            [self performSelector:@selector(startTimer) withObject:nil afterDelay:0.5];
            
        }else {
            self.page = pageNumber;
        }
        
        switch (self.bannerType) {
            case MBCKiraBannerTypeHorizontal:
                [_scrollView setContentOffset:CGPointMake(_pageSize.width * self.page, 0) animated:YES];
                break;
            case MBCKiraBannerTypeVertical:
                [_scrollView setContentOffset:CGPointMake(0, _pageSize.height * self.page) animated:YES];
                break;
        }
        [self setVisibleCellsAtContentOffset:_scrollView.contentOffset];
        [self refreshView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.numberOfItems == 0) {
        return;
    }
    NSInteger pageIndex = 0;
    switch (self.bannerType) {
        case MBCKiraBannerTypeHorizontal:{
            pageIndex = (int)round(_scrollView.contentOffset.x / _pageSize.width) % self.numberOfItems;
        }
            break;
        case MBCKiraBannerTypeVertical:{
            
        }
            break;
        default:
            break;
    }
    
    if (self.isCircle) {
        if (self.numberOfItems > 1) {
            switch (self.bannerType) {
                case MBCKiraBannerTypeHorizontal:
                {
                    if (scrollView.contentOffset.x / _pageSize.width >= 2 * self.numberOfItems) {
                        
                        [scrollView setContentOffset:CGPointMake(_pageSize.width * self.numberOfItems, 0) animated:NO];
                        
                        self.page = self.numberOfItems;
                    }
                    
                    if (scrollView.contentOffset.x / _pageSize.width <= self.numberOfItems - 1) {
                        [scrollView setContentOffset:CGPointMake((2 * self.numberOfItems - 1) * _pageSize.width, 0) animated:NO];
                        
                        self.page = 2 * self.numberOfItems;
                    }
                }
                    break;
                case MBCKiraBannerTypeVertical:
                {
                    
                }
                    break;
                default:
                    break;
            }
        } else {
            pageIndex = 0;
        }
    }
    [self setVisibleCellsAtContentOffset:scrollView.contentOffset];
    [self refreshView];
    //TODO:pagecontrol设置当前页
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didScrollToIndex:inKiraBanner:)] && _currentIndex != pageIndex && pageIndex >= 0) {
        [_delegate didScrollToIndex:pageIndex inKiraBanner:self];
    }
    _currentIndex = pageIndex;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.numberOfItems > 1 && self.isOpenAutoScroll && self.isCircle) {
        switch (self.bannerType) {
            case MBCKiraBannerTypeHorizontal:
            {
                if (self.page == floor(_scrollView.contentOffset.x / _pageSize.width)) {
                    
                    self.page = floor(_scrollView.contentOffset.x / _pageSize.width) + 1;
                    
                }else {
                    
                    self.page = floor(_scrollView.contentOffset.x / _pageSize.width);
                }
            }
                break;
            case MBCKiraBannerTypeVertical:
            {
                
            }
                break;
            default:
                break;
        }
    }
}
@end
