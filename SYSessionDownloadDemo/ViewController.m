//
//  ViewController.m
//  SYSessionDownloadDemo
//
//  Created by lz on 15/9/6.
//  Copyright (c) 2015年 SY. All rights reserved.
//

#import "ViewController.h"
#import "Commic.h"

@interface ViewController ()<NSURLSessionDownloadDelegate>
@property (strong,nonatomic) NSArray *commicArray;
@property (strong,nonatomic) NSMutableArray *downloadArray;

@property (nonatomic, strong) NSURLSession *session;

- (IBAction)downClick:(UIButton *)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)commicArray
{
    if (!_commicArray) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"commic" ofType:@"plist"];
        _commicArray = [[NSArray alloc] initWithContentsOfFile:path];
    }
    return _commicArray;
}

- (NSURLSession *)session
{
    if (!_session) {
        // 获得session
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (IBAction)downClick:(UIButton *)sender
{
    if (self.downloadArray) {
        for (Commic *commic in self.downloadArray) { //遍历所有正在下载的commic
            if (sender.tag == [commic.commicNub intValue]) {//找出点击了哪个commic的按钮
                if (commic.task == nil) {//如果被点击的commic处于暂停状态，则重新开始下载
                    commic.task = [self.session downloadTaskWithResumeData:commic.resumedata];
                    [commic.task resume];
                    commic.taskID = commic.task.taskIdentifier;
                    commic.resumedata = nil;
                    break;//防止downloadArray中最后一个对象乱跳
                } else {
                    //如果被点击的commic处于下载状态，则暂停。
                    __weak Commic *temcommic = commic;
                    [commic.task cancelByProducingResumeData:^(NSData *resumeData) {
                        temcommic.resumedata = resumeData;
                        temcommic.task = nil;
                    }];
                    break;//防止downloadArray中最后一个对象乱跳
                }
            } else {
                //找不到commic，则下载当前按钮所对应的commic
                if (commic == [self.downloadArray lastObject]) {//保证downloadArray中所有对象全部对照后还找不到commic的情况下才重新创建。
                    NSDictionary *dict = self.commicArray[sender.tag];
                    Commic *commic = [Commic commicWithDictionary:dict];
                    commic.task = [self.session downloadTaskWithURL:[NSURL URLWithString:commic.urlStr]];
                    [self.downloadArray addObject:commic];
                    [commic.task resume];
                    commic.taskID = commic.task.taskIdentifier;
                    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30, sender.center.y, 244, 2)];
                    progressView.progress = 0;
                    [self.view addSubview:progressView];
                    commic.progressView = progressView;
                    commic.button = sender;
                    break;
                }
            }
        }
    } else {//如果downloadArray为空，则创建downloadArray，并添加第一个commic
        self.downloadArray = [NSMutableArray array];
        NSDictionary *dict = self.commicArray[sender.tag];
        Commic *commic = [Commic commicWithDictionary:dict];
        commic.task = [self.session downloadTaskWithURL:[NSURL URLWithString:commic.urlStr]];
        [self.downloadArray addObject:commic];
        [commic.task resume];
        commic.taskID = commic.task.taskIdentifier;
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30, sender.center.y, 244, 2)];
        progressView.progress = 0;
        [self.view addSubview:progressView];
        commic.progressView = progressView;
        commic.button = sender;
    }
    sender.selected = !sender.isSelected;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    for (Commic *commic in self.downloadArray) {
        if (downloadTask.taskIdentifier == commic.taskID) {
            NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *filePath = [caches stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",commic.commicID]];
            NSFileManager *mgr = [NSFileManager defaultManager];
            if (![mgr fileExistsAtPath:filePath]) {
                [mgr createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *file = [caches stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.zip",commic.commicID,commic.commicNub]];
            NSLog(@"%@",file);
            [mgr moveItemAtPath:location.path toPath:file error:nil];
            [commic.button setTitle:@"已下载" forState:UIControlStateNormal];
            commic.download = YES;
            commic.button.enabled = NO;
            commic.button.selected = NO;
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    for (Commic *commic in self.downloadArray) {
        if (downloadTask.taskIdentifier == commic.taskID) {
            dispatch_async(dispatch_get_main_queue(), ^{
                commic.progressView.progress = (double)totalBytesWritten / totalBytesExpectedToWrite;
            });
            NSLog(@"%@获得下载进度--%f",commic.commicNub,(double)totalBytesWritten / totalBytesExpectedToWrite);
        }
    }
}

//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
// didResumeAtOffset:(int64_t)fileOffset
//expectedTotalBytes:(int64_t)expectedTotalBytes
//{
//    NSLog(@"%lld",fileOffset);
//}
@end
