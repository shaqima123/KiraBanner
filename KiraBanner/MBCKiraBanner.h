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
    MBCKiraBannerTypeHorizontal = 0,//水平方向
    MBCKiraBannerTypeVertical//竖直方向
};

@protocol MBCKiraBannerDataSource,MBCKiraBannerDelegate;
@interface MBCKiraBanner : UIView

//数据源相关
@property (nonatomic, assign) MBCKiraBannerType bannerType;

/**
 *  当前是第几页
 */
@property (nonatomic, assign, readonly) NSInteger currentIndex;

/**
 *  总页数
 */
@property (nonatomic, assign, readonly) NSInteger numberOfItems;

/**
 *  可见的页数范围
 */
@property (nonatomic, assign, readonly) NSRange visibleRange;

/**
 *  非当前页的透明比例
 */
@property (nonatomic, assign) CGFloat minimumPageAlpha;

/**
 *  是否开启无限轮播,默认为关闭
 */
@property (nonatomic, assign) BOOL isCircle;

/**
 *  左右上下间距
 */
@property (nonatomic, assign) CGFloat leftRightSpace;
@property (nonatomic, assign) CGFloat topBottomSpace;

//数据源和方法代理
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

/**
 *  Cell有关方法，注册、重用
 */
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
/**
 *  设置banner的数量
 */
- (NSInteger)numberOfItemsInKiraBanner:(MBCKiraBanner *)banner;

/**
 *  设置某一页banner的内容
 */
- (UIView *)kiraBanner: (MBCKiraBanner *)banner viewForItemAtIndex:(NSInteger)index;

@optional

@end

@protocol MBCKiraBannerDelegate <UIScrollViewDelegate>

/**
 *  设置一个page的size
 */
- (CGSize)sizeForPageInKiraBanner:(MBCKiraBanner *)banner;

/**
 *  当前banner滚动到了哪一页
 */
- (void)didScrollToIndex:(NSInteger)index inKiraBanner:(MBCKiraBanner *)banner;

/**
 *  点击某个cell
 */
- (void)didSelectCell:(UIView *)cell inKiraBannerAtIndex:(NSInteger)index;

/**
 *  当前page滚动过了整页的百分比
 */
- (void)didScrollPercent:(float)percent OfPageInScrollView:(UIScrollView *)scrollView;

@end

