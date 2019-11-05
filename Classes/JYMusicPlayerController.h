//
//  JYMusicPlayerController.h
//  MusicPlayer
//
//  Created by miao yu on 2019/10/25.
//  Copyright © 2019 jerryyum. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 播放器控制器，单一实例，提供音频播放器界面和相关控制
@interface JYMusicPlayerController : UIViewController

+ (instancetype)sharedPlayerController;

@end

NS_ASSUME_NONNULL_END
