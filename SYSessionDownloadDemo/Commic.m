//
//  Commic.m
//  SYSessionDownloadDemo
//
//  Created by lz on 15/9/7.
//  Copyright (c) 2015年 SY. All rights reserved.
//

#import "Commic.h"

@implementation Commic

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        self.download = NO;
    }
    
    return self;
}
+ (instancetype)commicWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}


@end
