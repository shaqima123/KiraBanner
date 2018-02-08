//
//  ViewController.m
//  KiraBanner
//
//  Created by zj－db0737 on 2018/2/5.
//  Copyright © 2018年 zj－db0737. All rights reserved.
//

#import "ViewController.h"
#import "MBCBannerList.h"
#import "MBCKiraBanner.h"

@interface ViewController () <MBCKiraBannerDataSource, MBCKiraBannerDelegate>

@property (nonatomic, strong) MBCKiraBanner *banner;
@property (nonatomic, strong) NSArray * dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = @[@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg"];
    self.banner = [[MBCKiraBanner alloc] initWithFrame:CGRectMake(50, 100, 250, 200)];
    [self.view addSubview:self.banner];
    self.banner.backgroundColor = [UIColor yellowColor];
    self.banner.scrollViewEdge = UIEdgeInsetsMake(10, 10, 10, 10);
    self.banner.pageControlEdge = UIEdgeInsetsMake(150, 50, 10, 50);
//    self.banner.dataArray = self.dataArray;
    
    self.banner.itemSpace = 10;
    self.banner.itemWidth = 200;
    self.banner.contentEdge = UIEdgeInsetsMake(20, 0, 20, 0);
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.banner regiseterClassForCells:[UIImageView class]];
    self.banner.dataSource = self;
    self.banner.delegate = self;
    self.banner.isCircle = YES;
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)dealloc {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIView *)kiraBanner:(MBCKiraBanner *)banner viewForItemAtIndex:(NSInteger)index {
    UIImageView *cell = (UIImageView *)[self.banner dequeueReusableCell];
//    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.dataArray [index]];
    cell.image = [UIImage imageNamed:self.dataArray[index]];
    return cell;
}

//- (UIView *)kiraBanner:(MBCKiraBanner *)banner viewForNode:(MBCBannerNode *)node {
//    UIImageView *cell = (UIImageView *)[self.banner dequeueReusableCell];
//    NSString * data = (NSString *)node.data;
//    cell.image = [UIImage imageNamed:data];
//    return cell;
//}

- (NSInteger)numberOfItemsInKiraBanner:(MBCKiraBanner *)banner {
    return self.dataArray.count;
}




@end
