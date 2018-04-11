//
//  NSURLSession+extention.h
//  BackgroundDownload
//
//  Created by deer on 2018/4/11.
//  Copyright © 2018年 deer. All rights reserved.
// 地址： https://github.com/HustHank/BackgroundDownloadDemo/blob/master/BackgroundDownloadDemo/BackgroundDownloadDemo/NSURLSession%2BCorrectedResumeData.h

#import <Foundation/Foundation.h>

@interface NSURLSession (CorrectedResumeData)

- (NSURLSessionDownloadTask *)downloadTaskWithCorrectResumeData:(NSData *)resumeData;
+ (NSData *)cleanResumeData:(NSData *)resumeData;

@end
