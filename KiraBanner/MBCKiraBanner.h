//
//  MBCKiraBanner.h
//  KiraBanner
//
//  Created by zj－db0737 on 2018/2/5.
//  Copyright © 2018年 zj－db0737. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBCBannerList.h"

typedef NS_ENUM(NSInteger, MBCKiraBannerType)
{
    MBCKiraBannerTypeLinear = 0,
};

@protocol MBCKiraBannerDataSource,MBCKiraBannerDelegate;
@interface MBCKiraBanner : UIView

//数据源相关
@property (nonatomic, assign) MBCKiraBannerType bannerType;
@property (nonatomic, assign, readonly) NSInteger currentIndex;

//2
@property (nonatomic, strong) NSArray * _Nonnull dataArray;

@property (nonatomic, assign, readonly) NSInteger numberOfItems;
@property (nonatomic, strong) Class cellClass;

//设置边距
@property (nonatomic, assign) UIEdgeInsets scrollViewEdge;
@property (nonatomic, assign) UIEdgeInsets pageControlEdge;

//设置scrollView内部属性
@property (nonatomic, assign) BOOL isCircle;

@property (nonatomic, assign) CGFloat itemWidth;
//itemHeight通过scrollview的height减去contentTop和bottom得到

@property (nonatomic, assign) CGFloat itemSpace;
@property (nonatomic, assign) UIEdgeInsets contentEdge;


//代理
@property (nonatomic,weak) id<MBCKiraBannerDataSource> dataSource;
@property (nonatomic,weak) id<MBCKiraBannerDelegate> delegate;

//Cell
- (void)regiseterClassForCells: (Class) cellClass;
- (UIView *)dequeueReusableCell;

@end

@protocol MBCKiraBannerDataSource <NSObject>
@required
- (NSInteger)numberOfItemsInKiraBanner:(MBCKiraBanner *)banner;
- (UIView *)kiraBanner: (MBCKiraBanner *)banner viewForItemAtIndex:(NSInteger)index;

@optional
//2
//- (UIView *)kiraBanner: (MBCKiraBanner *)banner viewForNode: (MBCBannerNode *)node;

@end

@protocol MBCKiraBannerDelegate <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end
