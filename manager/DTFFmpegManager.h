//
//  DTFFmpegManager.h
//  VideoEdotor
//
//  Created by Tema on 2019/3/9.
//  Copyright © 2019 tema.tian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DTFFmpegManager : NSObject

@property (nonatomic, readonly, assign) BOOL isRuning;

+ (DTFFmpegManager *)sharedManager;

/**
 转换视频
 
 @param inputPath 输入视频路径
 @param outpath 输出视频路径
 @param processBlock 进度回调
 @param completionBlock 结束回调
 */
- (void)converWithInputPath:(NSString *)inputPath
                 outputPath:(NSString *)outpath
               processBlock:(void (^)(float process))processBlock
            completionBlock:(void (^)(NSError *error))completionBlock;

// 设置总时长
+ (void)setDuration:(long long)time;

// 设置当前时间
+ (void)setCurrentTime:(long long)time;

// 转换停止
+ (void)stopRuning;

/// 退出线程，取消任务
- (void)cancelConvertTask;

@end

NS_ASSUME_NONNULL_END
