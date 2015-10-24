//
//  ViewController.m
//  TUCustomDynamicBlurNavigation
//
//  Created by howeguo on 10/24/15.
//  Copyright (c) 2015 howeguo. All rights reserved.
//

#import "ViewController.h"
#import "FXBlurView.h"
#import "TUHeaderView.h"
#import "UINavigationBar+Awesome.h"
#define NavigationHeight 64.0
const void* _SCROLLVIEWOFFSET = &_SCROLLVIEWOFFSET;



@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic ,strong) UIImage *blurImage;
@property(nonatomic ,strong) UIImage *headerImage;
@property(nonatomic ,strong) UIImageView *headerImageView;
@property(nonatomic, strong) NSLayoutConstraint *headerHeightConstraint;
@property(nonatomic, assign) CGFloat topInset;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, strong) TUHeaderView *headerView;
@property (nonatomic, strong) FXBlurView *blurView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    
    //初始化
    self.headerHeight =  260.0f;
    self.topInset = self.headerHeight;
    [self baseConfigs];
    [self baseLayout];
    [self addCoverSubViews];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void) baseConfigs
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([self.view respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.view.preservesSuperviewLayoutMargins = YES;
    }
    self.headerView = [[TUHeaderView alloc] init];
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.headerView.clipsToBounds = YES;
    self.headerView.userInteractionEnabled = YES;
    [self.view addSubview:self.headerView];
    
        self.blurView = [[FXBlurView alloc] init];
    _blurView.dynamic = YES;
    _blurView.blurRadius = 5.0;
    //    _blurView.iterations = 1.0;
    _blurView.hidden = YES;
    self.blurView.tintColor = [UIColor clearColor];
    self.blurView.clipsToBounds = YES;
    [self.view addSubview:self.blurView];
}


//一堆我自己都不是很懂的约束
-(void) baseLayout
{
    //header addConstraint
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.headerHeightConstraint = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:self.headerHeight];
    [self.headerView addConstraint:self.headerHeightConstraint];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    
    
    //header addConstraint
    self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *blurConstraint = [NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:NavigationHeight];
    [self.blurView addConstraint:blurConstraint];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    UIView *pageView = self.view;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    //trigger to fixed header constraint
    UIScrollView *scrollView = self.tableView;
    if (scrollView) {
        scrollView.alwaysBounceVertical = YES;
        CGFloat topInset = self.headerHeight;
        //fixed bootom tabbar inset
        CGFloat bottomInset = 0;
        if (self.tabBarController.tabBar.hidden == NO) {
            bottomInset = CGRectGetHeight(self.tabBarController.tabBar.bounds);
        }
        [scrollView setContentInset:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
        //fixed first time don't show header view
        [scrollView setContentOffset:CGPointMake(0, -self.headerHeight)];
    }
}

//对已有数据处理
- (void) addCoverSubViews
{
    UIImage *image = [UIImage imageNamed:@"嗒嗒聚焦"];
    self.headerImage = image;
    self.headerView.imageView.image = image;
    
    //网络图片
    //对cover的处理
//    NSURL *coverUrl = [_channel.coverURL fullUrlForImageString];
//    [_headerView.imageView sd_setImageWithURL:coverUrl placeholderImage:[UIImage imageNamed:@"DefaultPic_640_320"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        if (image && !error) {
//            self.headerImage = image;
//            self.headerView.imageView.image = image;
//        }
//    }];
    
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView addObserver:self
                        forKeyPath:@"contentOffset"
                           options:NSKeyValueObservingOptionNew
                           context:&_SCROLLVIEWOFFSET];
    [self addObserver:self
           forKeyPath:@"topInset"
              options:NSKeyValueObservingOptionNew
              context:nil];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}



- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
    [self removeObserver:self forKeyPath:@"topInset"];
    [self.navigationController.navigationBar lt_reset];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    
}


- (void) initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  20;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"row-%ld",indexPath.row];
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.headerImage = [UIImage imageNamed:@"读粒"];
    self.headerImageView.image = _headerImage;
}
//observeValueForKeyPath
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == _SCROLLVIEWOFFSET) {
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        CGFloat offsetY = offset.y;
        
        if (offsetY < -NavigationHeight) {
            self.headerHeightConstraint.constant = -  offsetY;
            self.topInset = -offsetY;
        }else{
            self.headerHeightConstraint.constant = NavigationHeight;
            self.topInset = NavigationHeight;
        }
    }else{
        CGFloat topInset = [change[NSKeyValueChangeNewKey] floatValue];
        if (topInset <= NavigationHeight) {
            self.headerView.imageView.image = self.headerImage;
            //            if (!self.blurView.hidden) {
            //                self.blurView.hidden = YES;
            //            }
            if (self.blurView.dynamic) {
                self.blurView.dynamic = NO;
            }
            
        }else{
            //修正一下
            topInset += 1.0;
            [UIView animateWithDuration:0.2 animations:^{
                if (self.blurView.hidden) {
                    self.blurView.hidden = NO;
                }
            }];
            
            if (!self.blurView.dynamic) {
                self.blurView.dynamic = YES;
            }
            if (topInset >= self.headerHeight) {
                self.blurView.hidden = YES;
            }
            self.headerView.imageView.image = self.headerImage;
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
