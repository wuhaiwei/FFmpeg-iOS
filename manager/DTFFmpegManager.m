//
//  DTFFmpegManager.m
//  VideoEdotor
//
//  Created by Tema on 2019/3/9.
//  Copyright © 2019 tema.tian. All rights reserved.
//

#import "DTFFmpegManager.h"
#import "ffmpeg.h"

@interface DTFFmpegManager ()

@property (nonatomic, readwrite, assign) BOOL isRuning;
@property (nonatomic, assign) BOOL isBegin;
@property (nonatomic, assign) long long fileDuration;
@property (nonatomic, copy) void (^processBlock)(float process);
@property (nonatomic, copy) void (^completionBlock)(NSError *error);

@end

@implementation DTFFmpegManager

+ (DTFFmpegManager *)sharedManager {
  static dispatch_once_t once;
  static id instance;
  dispatch_once(&once, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

// 转换视频
- (void)converWithInputPath:(NSString *)inputPath
                 outputPath:(NSString *)outpath
               processBlock:(void (^)(float process))processBlock
            completionBlock:(void (^)(NSError *error))completionBlock {
  self.processBlock = processBlock;
  self.completionBlock = completionBlock;
  self.isBegin = NO;
  
  // ffmpeg语法，ffmpeg -i %@ -crf 30 -preset superfast %@
  NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -i %@ -preset superfast -y -vcodec libx264 -crf 30 %@", inputPath, outpath];
  
  // 放在子线程运行
  [[[NSThread alloc] initWithTarget:self selector:@selector(runCmd:) object:commandStr] start];
}

// 执行指令
- (void)runCmd:(NSString *)commandStr{
  // 判断转换状态
  if (self.isRuning) {
    NSLog(@"正在转换,稍后重试");
  }
  self.isRuning = YES;
  
  // 根据   将指令分割为指令数组
  NSArray *argv_array = [commandStr componentsSeparatedByString:(@" ")];
  // 将OC对象转换为对应的C对象
  int argc = (int)argv_array.count;
  char** argv = (char**)malloc(sizeof(char*)*argc);
  for(int i=0; i < argc; i++) {
    argv[i] = (char*)malloc(sizeof(char)*1024);
    strcpy(argv[i],[[argv_array objectAtIndex:i] UTF8String]);
  }
  
  // 打印日志
  NSString *finalCommand = @"ffmpeg 运行参数:";
  for (NSString *temp in argv_array) {
    finalCommand = [finalCommand stringByAppendingFormat:@" %@",temp];
  }
  NSLog(@"%@",finalCommand);
  
  // 传入指令数及指令数组
  ffmpeg_main(argc,argv);
}

// 设置总时长
+ (void)setDuration:(long long)time {
  [DTFFmpegManager sharedManager].fileDuration = time;
}

// 设置当前时间
+ (void)setCurrentTime:(long long)time {
  DTFFmpegManager *mgr = [DTFFmpegManager sharedManager];
  mgr.isBegin = YES;
  
  if (mgr.processBlock && mgr.fileDuration) {
    float process = time/(mgr.fileDuration * 1.00);
    
    dispatch_async(dispatch_get_main_queue(), ^{
      mgr.processBlock(process);
    });
  }
}

// 转换停止
+ (void)stopRuning {
  DTFFmpegManager *mgr = [DTFFmpegManager sharedManager];
  NSError *error = nil;
  // 判断是否开始过
  if (!mgr.isBegin) {
    // 没开始过就设置失败
    error = [NSError errorWithDomain:@"转换失败,请检查源文件的编码格式!"
                                code:0
                            userInfo:nil];
  }
  if (mgr.completionBlock) {
    dispatch_async(dispatch_get_main_queue(), ^{
      mgr.completionBlock(error);
    });
  }
  
  mgr.isRuning = NO;
}

- (void)cancelConvertTask{
    if (self.isRuning) {
        
    }
}

@end
