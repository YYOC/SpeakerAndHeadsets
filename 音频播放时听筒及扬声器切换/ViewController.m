//
//  ViewController.m
//  音频播放时听筒及扬声器切换
//
//  Created by 杨 on 16/3/11.
//  Copyright (c) 2016年 杨. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController () <AVAudioPlayerDelegate>
{
    AVAudioPlayer *myPlayer;
}

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//播放器
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupBackground];
    
    [self setupAudioPlayer];
    
    [self setupVolume];
    
    //添加通知，拔出耳机后暂停播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    //添加通知，音量变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //开启远程控制(例：耳机进行音频控制)
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //结束远程控制
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

#pragma mark - 后台控制 音乐播放 远程控制
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        NSLog(@"远程控制：%ld",(long)event.subtype);
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
            {
                // 播放
                NSLog(@"播放");
            }
                break;
            case UIEventSubtypeRemoteControlPause:
            {
                // 暂停
                NSLog(@"暂停");
            }
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                NSLog(@"线控暂停或播放");
            }
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                // 播放上一曲按钮
                NSLog(@"播放上一曲");
            }
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
            {
                // 播放下一曲按钮
                NSLog(@"播放下一曲");
            }
                break;
                
            default:
                break;
        }
    }
    
    /**
     typedef NS_ENUM(NSInteger, UIEventSubtype) {
     // 不包含任何子事件类型
     UIEventSubtypeNone                              = 0,
     
     // 摇晃事件（从iOS3.0开始支持此事件）
     UIEventSubtypeMotionShake                       = 1,
     
     //远程控制子事件类型（从iOS4.0开始支持远程控制事件）
     //播放事件【操作：停止状态下，按耳机线控中间按钮一下】
     UIEventSubtypeRemoteControlPlay                 = 100,
     //暂停事件
     UIEventSubtypeRemoteControlPause                = 101,
     //停止事件
     UIEventSubtypeRemoteControlStop                 = 102,
     //播放或暂停切换【操作：播放或暂停状态下，按耳机线控中间按钮一下】
     UIEventSubtypeRemoteControlTogglePlayPause      = 103,
     //下一曲【操作：按耳机线控中间按钮两下】
     UIEventSubtypeRemoteControlNextTrack            = 104,
     //上一曲【操作：按耳机线控中间按钮三下】
     UIEventSubtypeRemoteControlPreviousTrack        = 105,
     //快退开始【操作：按耳机线控中间按钮三下不要松开】
     UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
     //快退停止【操作：按耳机线控中间按钮三下到了快退的位置松开】
     UIEventSubtypeRemoteControlEndSeekingBackward   = 107,
     //快进开始【操作：按耳机线控中间按钮两下不要松开】
     UIEventSubtypeRemoteControlBeginSeekingForward  = 108,
     //快进停止【操作：按耳机线控中间按钮两下到了快进的位置松开】
     UIEventSubtypeRemoteControlEndSeekingForward    = 109,
     };

     */
}

#pragma mark - action
- (IBAction)play:(id)sender {
    //初始化播放器的时候如下设置
    
    [self handleNotification:YES];
    [myPlayer play];
}

- (IBAction)pause:(id)sender {
    [self handleNotification:NO];
    [myPlayer pause];
}

- (IBAction)stop:(id)sender {
    [self handleNotification:NO];
    [myPlayer stop];
}
- (IBAction)volume:(id)sender {
    UISlider *slider = sender;
    NSLog(@"volume=%f",slider.value);
    
    //控制音量（和设备音量同步）
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    mpc.volume = slider.value;  //0.0~1.0
    
//    MPVolumeView

}

//听筒
- (IBAction)tingtong:(id)sender {
    
    [self handleNotification:NO];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (![audioSession.category isEqualToString:AVAudioSessionCategoryPlayAndRecord])
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
}

//扬声器
- (IBAction)yangshengqi:(id)sender {
    
    [self handleNotification:NO];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (![audioSession.category isEqualToString:AVAudioSessionCategoryPlayback])
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
}

#pragma mark - 控制音量
- (void)setupVolume {
    
    //控制音量方法一
    //控制音量（和设备音量同步）
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    [self.volumeSlider setValue:mpc.volume animated:YES];  //0.0~1.0
    
    //控制音量方法二  官方推荐 （只要MPVolumeView添加到当前view，并不隐藏，改变音量不会显示系统弹出音量提示）
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    volumeView.frame = CGRectMake(50, 100, 300, 20);
    volumeView.showsVolumeSlider = YES;
    volumeView.showsRouteButton = YES;
    [self.view addSubview:volumeView];
    
//    //获取
//    UISlider* volumeViewSlider = nil;
//    for (UIView *view in [volumeView subviews]){
//        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
//            volumeViewSlider = (UISlider*)view;
//            break;
//        }
//    }
//    
//    // retrieve system volume
//    float systemVolume = volumeViewSlider.value;
//    
//    // change system volume, the value is between 0.0f and 1.0f
//    [volumeViewSlider setValue:1.0f animated:NO];
//    
//    // send UI control event to make the change effect right now.
//    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"播放结束");
    
    //根据实际情况播放完成可以将会话关闭，其他音频应用继续播放
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    [self handleNotification:NO];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    NSLog(@"error%@",error);
}

#pragma mark - 监听听筒or扬声器
- (void) handleNotification:(BOOL)state
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:state]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    if(state)//添加监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification"
                                                   object:nil];
    else//移除监听
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

#pragma mark - 监听耳机  notification
-(void)routeChange:(NSNotification *)notification{
    NSDictionary *dic=notification.userInfo;
    
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    if (changeReason==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        
        AVAudioSessionRouteDescription *routeDescription = dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription = [routeDescription.outputs firstObject];
        
        //原设备为耳机则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            [self pause:nil];
        }
    }
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSLog(@"%@:%@",key,obj);
    }];
}

#pragma mark - 监听音量变化（不管是音量键，还是其他方式）  notification
- (void)volumeChanged:(NSNotification *)notification
{
    // service logic here.
    NSLog(@"音量键：%@",notification.userInfo);
    
    NSDictionary *systemVolumeDict = notification.userInfo;
    NSString *noticeParameter = systemVolumeDict[@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
    
    if (noticeParameter && [noticeParameter isEqualToString:@"ExplicitVolumeChange"]) {
        CGFloat volumeValue = [systemVolumeDict[@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
        self.volumeSlider.value = volumeValue;
    }
}

#pragma mark - 设置播放器
- (void)setupAudioPlayer {
    
    NSString *audioFile=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"草笛曲 幽鬼丸 白映.m4a"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioFile]) {
        NSLog(@"存在");
    } else {
        NSLog(@"不存在");
    }
    
    NSURL *fileUrl=[NSURL fileURLWithPath:audioFile];
    
    NSError *playerError;
    //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
    myPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:&playerError];
    myPlayer.meteringEnabled = YES;
    myPlayer.delegate = self;
    myPlayer.numberOfLoops = -1;//循环播放次数，如果为0则不循环，如果小于0则无限循环，大于0则表示循环次数
    [myPlayer prepareToPlay];//加载音频文件到缓冲区，注意即使在播放之前音频文件没有加载到缓冲区程序也会隐式调用此方法
    
    if (myPlayer == nil)
    {
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
    
}

#pragma mark - 后台播放设置  这样只支持本地音乐播放
- (void)setupBackground {
    
    //初始化播放器的时候如下设置
    AudioSessionInitialize(NULL,NULL, NULL, (__bridge void *)(self));
    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    //1.设置后台运行模式：在plist文件中添加Required background modes，并且设置item 0=App plays audio or streams audio/video using AirPlay（其实可以直接通过Xcode在Project Targets-Capabilities-Background Modes中设置）
    
    //2.设置AVAudioSession的类型为AVAudioSessionCategoryPlayback并且调用setActive::方法启动会话。
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    /**
     设置完音频会话类型之后需要调用setActive: error:方法将会话激活才能起作用。
     如果一个应用已经在播放音频，打开我们的应用之后设置了在后台播放的会话类型，此时其他应用的音频会停止而播放我们的音频;
     如果希望我们的程序音频播放完之后（关闭或退出到后台之后）能够继续播放其他应用的音频的话则可以调用setActive: error:方法关闭会话。
     */
    [audioSession setActive:YES error:nil];
    
    
    /**
     AVAudioSession 会话类型                            说明                      是否要求输入  是否要求输出	是否遵从静音键
     
     AVAudioSessionCategoryAmbient          混音播放，可以与其他音频应用同时播放          否           是           是
     
     AVAudioSessionCategorySoloAmbient      独占播放                                 否           是           是
     
     AVAudioSessionCategoryPlayback         后台播放，也是独占的                       否           是           否
     
     AVAudioSessionCategoryRecord           录音模式，用于录音时使用	是                  否           否           否
     
     AVAudioSessionCategoryPlayAndRecord	播放和录音，此时可以录音也可以播放            是           是           否
     
     AVAudioSessionCategoryAudioProcessing	硬件解码音频，此时不能播放和录制             否           否            否
     
     AVAudioSessionCategoryMultiRoute       多种输入输出，例如可以耳机、USB设备同时播放    是           是           否
     
     注意：是否遵循静音键表示在播放过程中如果用户通过硬件设置为静音是否能关闭声音。
     */
    
    
}


@end
