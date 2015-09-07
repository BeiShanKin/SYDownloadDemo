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

@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) NSData *resumeData;
@property (nonatomic, strong) NSURLSession *session;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView2;
@property (weak, nonatomic) IBOutlet UIButton *downBtn;

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

//-(NSMutableArray *)downloadArray
//{
//    if (!_downloadArray) {
//        _downloadArray = [NSMutableArray array];
//    }
//    return _downloadArray;
//}

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
                } else {
                    //如果被点击的commic处于下载状态，则暂停。
                    __weak Commic *temcommic = commic;
                    [commic.task cancelByProducingResumeData:^(NSData *resumeData) {
                        temcommic.resumedata = resumeData;
                        temcommic.task = nil;
                    }];
                }
            } else {
                //找不到commic，则下载当前按钮所对应的commic
                NSDictionary *dict = self.commicArray[sender.tag];
                Commic *commic = [Commic commicWithDictionary:dict];
                commic.task = [self.session downloadTaskWithURL:[NSURL URLWithString:commic.urlStr]];
                [self.downloadArray addObject:commic];
                [commic.task resume];
                commic.taskID = commic.task.taskIdentifier;
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
    }
    
    sender.selected = !sender.isSelected;
}

- (void)startWithCommic:(Commic *)commic
{
    
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
            
        }
    }
    
    // 获得下载进度
    self.progressView.progress = (double)totalBytesWritten / totalBytesExpectedToWrite;
    NSLog(@"获得下载进度--%f",(double)totalBytesWritten / totalBytesExpectedToWrite);
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"%lld",fileOffset);
}
@end
