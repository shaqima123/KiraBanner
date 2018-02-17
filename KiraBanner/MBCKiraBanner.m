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

/**
 *  计时器用到的页数
 */
@property (nonatomic, assign) NSInteger page;

@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, assign) BOOL needsReload;

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
    self.isAutoScroll = YES;
    
    //默认左右间距为20，上下间距为30
    self.leftRightSpace = 20;
    self.topBottomSpace = 30;
    _currentIndex = 0;
    _minimumPageAlpha = 1.0;
    
    //默认自动滚动时间间隔为5s
    _autoTime = 5.0;
    _visibleRange = NSMakeRange(0, 0);
    self.reuseCells = [[NSMutableSet alloc] init];
    
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor redColor];
    _currentIndex = 0;
    self.scrollView.pagingEnabled = YES;
    [self.scrollView setFrame:self.bounds];
    [self addSubview:self.scrollView];
}

- (void)dealloc {
    [self.reuseCells removeAllObjects];
    self.reuseCells = nil;
}

#pragma mark data methods

- (void)reloadData {
    _needsReload = YES;
    
    for (UIView *view in self.scrollView.subviews) {
        if ([NSStringFromClass(view.class) isEqualToString:NSStringFromClass(_cellClass.class)]) {
            [view removeFromSuperview];
        }
    }
    
    [self stopTimer];
    
    if (_needsReload) {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInKiraBanner:)]) {
            _numberOfItems = [self.dataSource numberOfItemsInKiraBanner:self];
            
            if (self.isCircle) {
                //如果是循环banner，则把scrollView的长度设为3组
                _pageCount = self.numberOfItems == 1 ? 1 : self.numberOfItems * 3;
            } else {
                _pageCount = self.numberOfItems == 1 ? 1 : self.numberOfItems;
            }
            
            if (_pageCount == 0) {
                return;
            }
            
            if (self.pageControl && [self.pageControl respondsToSelector:@selector(setNumberOfPages:)]) {
                [self.pageControl setNumberOfPages:self.numberOfItems];
            }
        }
        
        //重置page的宽度
        CGFloat width = _scrollView.bounds.size.width - 4 * self.leftRightSpace;
        
        _pageSize = CGSizeMake(width, width * 9 / 16);
        if (self.delegate && [self.delegate respondsToSelector:@selector(sizeForPageInKiraBanner:)]) {
            _pageSize = [self.delegate sizeForPageInKiraBanner:self];
        }
        
        [_reuseCells removeAllObjects];
        _visibleRange = NSMakeRange(0, 0);
        
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
            case MBCKiraBannerTypeVertical: {
                [self.scrollView setFrame:CGRectMake(0, 0, _pageSize.width, _pageSize.height)];
                [self.scrollView setContentSize:CGSizeMake(0, _pageSize.height * _pageCount)];
                _scrollView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                
                if (self.numberOfItems > 1) {
                    if (self.isCircle) {
                        [_scrollView setContentOffset:CGPointMake(_pageSize.height * self.numberOfItems, 0) animated:NO];
                        self.page = self.numberOfItems;
                        [self startTimer];
                    } else {
                        [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                        self.page = self.numberOfItems;
                    }
                }
            }
                
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
            
            _visibleRange = NSMakeRange(startIndex, endIndex - startIndex + 1);
        
            for (NSInteger i = startIndex; i < endIndex ; i++) {
                [self fillPageAtIndex:i];
            }
        }
            break;
        case MBCKiraBannerTypeVertical: {
            
            for (UIView *cellView in [self cellSubView]) {
                if (cellView.frame.origin.y + cellView.frame.size.height < startPoint.y) {
                    [self recycleCell:cellView];
                }
                if (cellView.frame.origin.y > endPoint.y) {
                    [self recycleCell:cellView];
                }
            }
            
            NSInteger startIndex = MAX(0, floor(startPoint.y / _pageSize.height));
            NSInteger endIndex = MIN(_pageCount, ceil(endPoint.y / _pageSize.height));
            
            _visibleRange = NSMakeRange(startIndex, endIndex - startIndex + 1);
            
            for (NSInteger i = startIndex; i < endIndex ; i++) {
                [self fillPageAtIndex:i];
            }
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
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        
        [cell addGestureRecognizer:tap];
        cell.userInteractionEnabled = YES;
        cell.clipsToBounds = YES;
        switch (self.bannerType) {
            case MBCKiraBannerTypeHorizontal: {
                float originX = index * self.pageSize.width;
                cell.frame = CGRectMake(originX,
                                        self.topBottomSpace,
                                        self.pageSize.width,
                                        self.pageSize.height);
            }
                break;
            case MBCKiraBannerTypeVertical: {
                float originY = index * self.pageSize.height;
                cell.frame = CGRectMake(self.leftRightSpace,
                                        originY,
                                        self.pageSize.width,
                                        self.pageSize.height);
            }
                break;
            default:
                break;
        }
        if (cell) {
            //将cellforindex方法的地址作为objc_setAssociatedObject的key，保证唯一性
            objc_setAssociatedObject(cell, @selector(cellForIndex:),[NSNumber numberWithInteger:index], OBJC_ASSOCIATION_COPY);
            [self.scrollView insertSubview:cell atIndex:0];
        }
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
                //TODO:透明度渐变
                
                if (delta < _pageSize.width) {
                    
                    CGFloat leftRightInset = self.leftRightSpace * delta / _pageSize.width;
                    CGFloat topBottomInset = self.topBottomSpace * delta / _pageSize.width;
                    
                    cell.layer.transform = CATransform3DMakeScale((_pageSize.width-leftRightInset*2)/_pageSize.width,(_pageSize.height-topBottomInset*2)/_pageSize.height, 1.0);
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset));
                } else {
                    
                    cell.layer.transform = CATransform3DMakeScale((_pageSize.width-self.leftRightSpace * 2)/_pageSize.width,(_pageSize.height-self.topBottomSpace * 2)/_pageSize.height, 1.0);
                    
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(self.topBottomSpace,
                                                                                         self.leftRightSpace,
                                                                                         self.topBottomSpace,
                                                                                         self.leftRightSpace));
                }
            }
        }
            break;
        case MBCKiraBannerTypeVertical: {
            CGFloat offset = _scrollView.contentOffset.y;
            for (NSInteger i = self.visibleRange.location; i < self.visibleRange.location + self.visibleRange.length ; i++) {
                UIView *cell = [self cellForIndex:i];
                CGFloat origin = cell.frame.origin.y;
                CGFloat delta = fabs(origin - offset);
                CGRect originCellFrame = CGRectMake(0, _pageSize.width * i, _pageSize.width, _pageSize.height);
                //TODO:透明度渐变
                
                if (delta < _pageSize.height) {
                    
                    CGFloat leftRightInset = self.leftRightSpace * delta / _pageSize.height;
                    CGFloat topBottomInset = self.topBottomSpace * delta / _pageSize.height;
                    
                    cell.layer.transform = CATransform3DMakeScale((_pageSize.width-leftRightInset*2)/_pageSize.width,(_pageSize.height-topBottomInset*2)/_pageSize.height, 1.0);
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset));
                } else {
                    
                    cell.layer.transform = CATransform3DMakeScale((_pageSize.width-self.leftRightSpace * 2)/_pageSize.width,(_pageSize.height-self.topBottomSpace * 2)/_pageSize.height, 1.0);
                    
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(self.topBottomSpace,
                                                                                         self.leftRightSpace,
                                                                                         self.topBottomSpace,
                                                                                         self.leftRightSpace));
                }
            }
        }
            break;
            
        default:
            break;
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    //设置子视图的frame
//    [self.scrollView setFrame:self.bounds];
    [self refreshView];
}


#pragma mark cell

- (void)regiseterClassForCells: (Class) cellClass {
    self.cellClass = cellClass;
}

- (UIView *)dequeueReusableCell {
    UIView *cell = [self.reuseCells anyObject];
    if (cell) {
        [self.reuseCells removeObject:cell];
    }
    if (!cell) {
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

- (void)cellTapped:(UITapGestureRecognizer *)sender {
    UIView * cell = sender.view;
    NSInteger index = -1;
    NSNumber *value = objc_getAssociatedObject(cell, @selector(cellForIndex:));
    if (value) {
        index = value.integerValue % self.numberOfItems;
    }
    if ([self.delegate respondsToSelector:@selector(didSelectCell:inKiraBannerAtIndex:)]) {
        [self.delegate didSelectCell:cell inKiraBannerAtIndex:index];
    }
}

- (void)recycleCell: (UIView *)cell {
    objc_removeAssociatedObjects(cell);
    [self.reuseCells addObject:cell];
    [cell removeFromSuperview];
}

#pragma mark private methods

- (void)startTimer {
    if (self.numberOfItems > 1 && self.isAutoScroll && self.isCircle) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoTime target:self selector:@selector(autoPlay) userInfo:nil repeats:YES];
        self.timer = timer;
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)adjustCenterSubview {
    if (self.isAutoScroll && self.numberOfItems > 0) {
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
    self.page ++;
    switch (self.bannerType) {
        case MBCKiraBannerTypeHorizontal: {
            [_scrollView setContentOffset:CGPointMake(self.page * _pageSize.width, 0) animated:YES];
        }
            break;
        case MBCKiraBannerTypeVertical: {
             [_scrollView setContentOffset:CGPointMake(0, self.page * _pageSize.height) animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark get-set

- (void)setLeftRightSpace:(CGFloat)leftRightSpace {
    _leftRightSpace = leftRightSpace * 0.5;
}

- (void)setTopBottomSpace:(CGFloat)topBottomSpace {
    _topBottomSpace = topBottomSpace * 0.5;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
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
            pageIndex = (int)round(_scrollView.contentOffset.y / _pageSize.height) % self.numberOfItems;
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
                        
                        self.page = 2 * self.numberOfItems - 1;
                    }
                }
                    break;
                case MBCKiraBannerTypeVertical:
                {
                    if (scrollView.contentOffset.y / _pageSize.height >= 2 * self.numberOfItems) {
                        
                        [scrollView setContentOffset:CGPointMake(0, _pageSize.height * self.numberOfItems) animated:NO];
                        
                        self.page = self.numberOfItems;
                    }
                    
                    if (scrollView.contentOffset.y / _pageSize.height <= self.numberOfItems - 1) {
                        [scrollView setContentOffset:CGPointMake(0, (2 * self.numberOfItems - 1) * _pageSize.height) animated:NO];
                        
                        self.page = 2 * self.numberOfItems - 1;
                    }
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
    
    if (self.pageControl && [self.pageControl respondsToSelector:@selector(setCurrentPage:)]) {
        [self.pageControl setCurrentPage:pageIndex];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didScrollToIndex:inKiraBanner:)] && _currentIndex != pageIndex && pageIndex >= 0) {
        [_delegate didScrollToIndex:pageIndex inKiraBanner:self];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didScrollPercent:OfPageInScrollView:)]) {
        CGFloat offset = _scrollView.contentOffset.x - (int)(_scrollView.contentOffset.x / _pageSize.width) * _pageSize.width;
        float percent = offset / _pageSize.width;
        [_delegate didScrollPercent:percent OfPageInScrollView:scrollView];
    }
    _currentIndex = pageIndex;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.numberOfItems > 1 && self.isAutoScroll && self.isCircle) {
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
                if (self.page == floor(_scrollView.contentOffset.y / _pageSize.height)) {
                    
                    self.page = floor(_scrollView.contentOffset.y / _pageSize.height) + 1;
                    
                }else {
                    
                    self.page = floor(_scrollView.contentOffset.y / _pageSize.height);
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
}

@end

