//
//  MBCKiraBanner.h
//  KiraBanner
//
//  Created by zj－db0737 on 2018/2/5.
//  Copyright © 2018年 zj－db0737. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MBCKiraBannerType)
{
    MBCKiraBannerTypeHorizontal = 0,
    MBCKiraBannerTypeVertical
};

@protocol MBCKiraBannerDataSource,MBCKiraBannerDelegate;
@interface MBCKiraBanner : UIView

//数据源相关
@property (nonatomic, assign) MBCKiraBannerType bannerType;

/**
 *  当前是第几页
 */
@property (nonatomic, assign, readonly) NSInteger currentIndex;
@property (nonatomic, strong) Class cellClass;

@property (nonatomic, assign) BOOL needsReload;

/**
 *  总页数
 */
@property (nonatomic, assign, readonly) NSInteger numberOfItems;

@property (nonatomic, assign) NSRange visibleRange;

/**
 *  非当前页的透明比例
 */
@property (nonatomic, assign) CGFloat minimumPageAlpha;

/**
 *  是否开启无限轮播,默认为关闭
 */
@property (nonatomic, assign) BOOL isCircle;

@property (nonatomic, assign) CGFloat leftRightSpace;
@property (nonatomic, assign) CGFloat topBottomSpace;

//代理
@property (nonatomic,weak) id<MBCKiraBannerDataSource> dataSource;
@property (nonatomic,weak) id<MBCKiraBannerDelegate> delegate;

/**
 *  指示器
 */
@property (nonatomic,retain)  UIPageControl *pageControl;


/**
 *  是否开启自动滚动,默认为开启
 */
@property (nonatomic, assign) BOOL isAutoScroll;

/**
 *  定时器
 */
@property (nonatomic, weak) NSTimer *timer;

/**
 *  自动切换视图的时间,默认是5.0
 */
@property (nonatomic, assign) CGFloat autoTime;

//Cell
- (void)regiseterClassForCells: (Class) cellClass;
- (UIView *)dequeueReusableCell;
- (void)reloadData;
- (void)scrollToPage:(NSUInteger)pageNumber;

/**
 *  关闭定时器,关闭自动滚动
 */
- (void)stopTimer;
- (void)adjustCenterSubview;

@end

@protocol MBCKiraBannerDataSource <NSObject>
@required
- (NSInteger)numberOfItemsInKiraBanner:(MBCKiraBanner *)banner;
- (UIView *)kiraBanner: (MBCKiraBanner *)banner viewForItemAtIndex:(NSInteger)index;

@optional

@end

@protocol MBCKiraBannerDelegate <UIScrollViewDelegate>

- (CGSize)sizeForPageInKiraBanner:(MBCKiraBanner *)banner;
- (void)didScrollToIndex:(NSInteger)index inKiraBanner:(MBCKiraBanner *)banner;
- (void)didSelectCell:(UIView *)cell inKiraBannerAtIndex:(NSInteger)index;

- (void)didScrollPercent:(float)percent OfPageInScrollView:(UIScrollView *)scrollView;

@end

