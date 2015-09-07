//
//  Commic.h
//  SYSessionDownloadDemo
//
//  Created by lz on 15/9/7.
//  Copyright (c) 2015年 SY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Commic : NSObject
@property (strong,nonatomic) NSString *urlStr;
@property (strong,nonatomic) NSString *commicID;
@property (strong,nonatomic) NSString *commicNub;
@property (strong,nonatomic) NSURLSessionDownloadTask *task;
@property (strong,nonatomic) NSData *resumedata;
@property (assign,nonatomic,getter=isDownload) BOOL download;
@property (assign,nonatomic) NSInteger taskID;
@property (weak,nonatomic) UIProgressView *progressView;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
+ (instancetype)commicWithDictionary:(NSDictionary *)dict;
@end
