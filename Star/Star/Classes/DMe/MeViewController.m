//
//  MeViewController.m
//  weibo
//
//  Created by DUCHENGWEN on 2016/12/3.
//  Copyright (c) 2015年 beijing. All rights reserved.
//

#import "MeViewController.h"
#import "RKCardView.h"
#import "SDWebImageManager.h"
#import "WDMiddleCell.h"
#import "UIView+YSBlock.h"
#import "WebAgreementController.h"
#import "AboutOurViewController.h"
#define BUFFERX 0 
#define BUFFERY 0


@interface MeViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>{
    NSArray*titearray;
    NSArray*imgarray;
}
@property (nonatomic,weak) IBOutlet RKCardView *headerView;
@property (nonatomic,strong) UIImageView *coverImageView;
@property (nonatomic,strong) UIImageView *profileImageView;
@property (nonatomic,weak) UITableView *customTableView;
@end

@implementation MeViewController

-(void)loadView{
    UIView *view=[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view=view;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden=YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    imgarray=[[NSArray alloc]init];
    titearray=[[NSArray alloc]init];
    titearray=[NSMutableArray arrayWithObjects:@"用户协议",@"推荐",@"缓存清理",@"关于",nil];
    imgarray=[NSMutableArray arrayWithObjects:@"协议",@"推荐" ,@"清理缓存",@"关于",nil];
    [self setupHeaderView];
    
   
    
}

-(void)setupHeaderView{
    
    RKCardView* cardView= [[RKCardView alloc]initWithFrame:CGRectMake(BUFFERX, 0, self.view.frame.size.width-2*BUFFERX, self.view.frame.size.height-2*BUFFERY)];
    
    self.coverImageView=cardView.coverImageView;
    self.profileImageView=cardView.profileImageView;
    cardView.coverImageView.image = [UIImage imageNamed:@"mebg"];
    cardView.profileImageView.image = [UIImage imageNamed:@"小熊明星资讯"];
 
    
    cardView.titleLabel.text = @"kevindcw";
    [cardView addBlur];//添加模糊
    [cardView addShadow];//添加阴影
    [self.view addSubview:cardView];

    CGFloat tabY=CGRectGetMaxY(cardView.coverImageView.frame)+40;
    CGSize screenSize=[[UIScreen mainScreen] bounds].size;
    UITableView *tableView=[[UITableView alloc] initWithFrame:CGRectMake(0,tabY, screenSize.width, screenSize.height-tabY)];
    [cardView addSubview:tableView];
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [tableView registerNib:[UINib nibWithNibName:@"WDMiddleCell" bundle:nil] forCellReuseIdentifier:@"WDMiddle"];
    tableView.sectionHeaderHeight=5;
    tableView.sectionFooterHeight=0;
    tableView.rowHeight=50;
    self.customTableView=tableView;
    self.profileImageView.userInteractionEnabled=YES;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return titearray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WDMiddleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WDMiddle" forIndexPath:indexPath];
    cell.titeLabel.text=titearray[indexPath.row];
    cell.ImgView.image=[UIImage imageNamed:imgarray[indexPath.row]];
    return cell;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

#pragma mark tableViewDelegate method
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row==0) {
        WebAgreementController *webVC = [[WebAgreementController alloc] init];
       [self.navigationController pushViewController:webVC animated:YES];
    }else if (indexPath.row==1){
        [self initAlert:@"编程管家" mesage:@"编程管家适用于想要学习编程和初级开发者的人群。主要功能给大家汇报一下\n1.IT资讯 掌握最新的行业动态\n2.各种编程语言基础教程，通俗易懂。\n3.面试题库，找工作必备(适用于客户端开发，前端开发，服务端开发)\n4.试题练习(吾日三省吾身)" otherA:@"取消" otherB:@"确定"];
    }else if (indexPath.row==2){
        CGFloat fileSize =  [ self filePath ];
        [self initAlert:@"缓存清理" mesage:[NSString stringWithFormat:@"有%.2fMB缓存，确定清除吗？",fileSize] otherA:@"取消" otherB:@"确定"];
    }else if (indexPath.row==3){
        AboutOurViewController *aboutVC = [[AboutOurViewController alloc] init];
        [self.navigationController pushViewController:aboutVC animated:YES];
        
    }
}
-(void)initAlert:(NSString*)title mesage:(NSString*)mesage otherA:(NSString*)otherA otherB:(NSString*)otherB{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:mesage  delegate:nil cancelButtonTitle:nil otherButtonTitles:otherA,otherB, nil];
    [alertView showWithCompletionHandler:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if ([title isEqualToString:@"缓存清理"]) {
                [self  myClearCacheAction];
            }
     
        }else{
            
        }
    }];
    
}
- ( float )filePath

{
    NSString * cachPath = [ NSSearchPathForDirectoriesInDomains ( NSCachesDirectory , NSUserDomainMask , YES ) firstObject ];
    return [ self folderSizeAtPath :cachPath];
    
}
- (CGFloat)folderSizeAtPath:(NSString *)folderPath{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) {
        return 0;
    }
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString *fileName = nil;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil) {
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

- (long long)fileSizeAtPath:(NSString *)filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//清除缓存
-(void)myClearCacheAction{
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                       NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
                       for (NSString *p in files) {
                           NSError *error;
                           NSString *path = [cachPath stringByAppendingPathComponent:p];
                           if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                               [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                           }}
                       
                       [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];
                   
                   });
    
}
-(void)clearCacheSuccess

{
   
}
@end
