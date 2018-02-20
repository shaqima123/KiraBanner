//
//  ViewController.m
//  KiraBanner
//
//  Created by zj－db0737 on 2018/2/5.
//  Copyright © 2018年 zj－db0737. All rights reserved.
//

#import "ViewController.h"
#import "KiraBanner.h"
#define Width [UIScreen mainScreen].bounds.size.width

@interface ViewController () <KiraBannerDataSource, KiraBannerDelegate>

@property (nonatomic, strong) KiraBanner *banner;
@property (nonatomic, strong) NSArray * dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = @[@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg"];
    self.banner = [[KiraBanner alloc] initWithFrame:CGRectMake(0, 72, Width, Width * 9 / 16)];
    [self.view addSubview:self.banner];
    self.banner.backgroundColor = [UIColor blackColor];
    self.banner.isCircle = YES;
    self.banner.leftRightSpace = 50;
    self.banner.topBottomSpace = 30;
    self.banner.clipsToBounds = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.banner regiseterClassForCells:[UIImageView class]];
    self.banner.bannerType = KiraBannerTypeHorizontal;
    self.banner.minimumPageAlpha = 1;
    self.banner.dataSource = self;
    self.banner.delegate = self;
    
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.banner.frame.size.height - 15, Width, 8)];
    self.banner.pageControl = pageControl;
    [self.banner addSubview:pageControl];
    [self.banner reloadData];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIView *)kiraBanner:(KiraBanner *)banner viewForItemAtIndex:(NSInteger)index {
    UIImageView *cell = (UIImageView *)[self.banner dequeueReusableCell];
    cell.image = [UIImage imageNamed:self.dataArray[index]];
    [cell setContentMode:UIViewContentModeScaleAspectFill];
    return cell;
}

- (CGSize)sizeForPageInKiraBanner:(KiraBanner *)banner {
    return CGSizeMake(Width - 60, (Width - 60) * 9 / 16);
}

- (NSInteger)numberOfItemsInKiraBanner:(KiraBanner *)banner {
    return self.dataArray.count;
}

- (void)didSelectCell:(UIView *)cell inKiraBannerAtIndex:(NSInteger)index {
    NSLog(@"banner of index : %ld is clicked.",(long)index);
}

@end
