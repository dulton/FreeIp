//
//  PlayCloudViewController.m
//  XCMonit_Ip
//
//  Created by 夏钟林 on 15/5/26.
//  Copyright (c) 2015年 夏钟林. All rights reserved.
//

#import "UIView+Extension.h"
#import "CloudDecode.h"
#import "DecodeJson.h"
#import "CaptureService.h"
#import "PlayCloudViewController.h"
#import "TimeView.h"
#import "TimeView.h"
#import "CloudButton.h"
#import "NSDate+convenience.h"
#import "Toast+UIView.h"
#import "ProgressHUD.h"
#import "DecoderPublic.h"
#import "DeviceInfoModel.h"
#import "XCNotification.h"
@interface PlayCloudViewController ()
{
    UIView *topView;
    UIView *downView;
    UILabel *_lblName;
//    CloudDecode *cloudDec;
    TimeView *timeView;
    CloudButton *btnPause;
    CloudButton *btnStop;
    CloudButton *btnCamera;
    CloudButton *btnRecord;
    CloudButton *btnDate;
    CloudButton *btnRight;
    
    CGFloat fWidth,fHeight;
    CGFloat lastX,lastY;
    CGFloat lastScale;
    
    UIScrollView *scrolView;
    int nAllCount;
    
    UITapGestureRecognizer *_tapGestureRecognizer;
    UIPinchGestureRecognizer *pinchGesture;
    UIPanGestureRecognizer *_panGesture;
    NSString *strDevName;
    UIView *rightView;
    UIButton *rightBtn;
    UIImageView *imgView;
    int nChannel;
    NSMutableArray *aryDecode;
}
@property (nonatomic,assign) BOOL bDecoding;
@property (nonatomic,assign) BOOL bPlaying;
@property (nonatomic,copy) NSString *strNO;
@property (nonatomic,strong) NSMutableArray *videoFrames;
@end

@implementation PlayCloudViewController

-(id)initWithDev:(DeviceInfoModel*)devInfo
{
    self = [super init];
    _strNO = devInfo.strDevNO;
    NSString *strChannel = [DecodeJson getDeviceTypeByType:[devInfo.strDevType intValue]];
    nAllCount = [[strChannel componentsSeparatedByString:@"-"][1] intValue];
    nChannel = 0;
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    aryDecode = [NSMutableArray array];
    [self.view setBackgroundColor:RGB(255, 255, 255)];
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapNew:)];
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchEvent:)];
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEvent:)];
    [self initBodyView];
    [self initWithScrol];
}

-(void)initWithScrol
{
    rightView = [[UIView alloc] initWithFrame:Rect(0, 0, 100,320)];
    [self.view addSubview:rightView];
    rightView.hidden = YES;
    scrolView = [[UIScrollView alloc] initWithFrame:Rect(40, 0, 60, 320)];
    [rightView addSubview:scrolView];
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = Rect(0, 160,40, 40);
    [rightBtn addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setImage:[UIImage imageNamed:@"NaviBtn_Back_play"] forState:UIControlStateNormal];
    [rightView addSubview:rightBtn];
    
    for (int i=0; i<nAllCount; i++)
    {
        UIButton *btnAction = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnAction setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        [btnAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnAction setTitleColor:RGB(15, 173, 225) forState:UIControlStateHighlighted];
        [btnAction setBackgroundColor:[UIColor blackColor]];
        [scrolView addSubview:btnAction];
        btnAction.frame = Rect(0,i*60,60,60);
        btnAction.layer.borderColor = RGB(255, 255, 255).CGColor;
        btnAction.layer.borderWidth = 0.5f;
        [btnAction.layer setMasksToBounds:YES];
        [btnAction.layer setCornerRadius:3];
        btnAction.tag = i;
        [btnAction addTarget:self action:@selector(switchChannel:) forControlEvents:UIControlEventTouchUpInside];
    }
    [scrolView setShowsHorizontalScrollIndicator:NO];
    [scrolView setShowsVerticalScrollIndicator:NO];
}

-(void)switchChannel:(UIButton *)sender
{
    __weak PlayCloudViewController *__self = self;
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        [__self stopVideo];
    });
    [ProgressHUD show:@"切换通道"];
    if (aryDecode.count==0) {
        
    }
    else
    {
        CloudDecode *cloudDec = [aryDecode objectAtIndex:0];
        [aryDecode removeObjectAtIndex:0];
        cloudDec = nil;
    }
    nChannel = (int)sender.tag;
    dispatch_async(dispatch_get_global_queue(0, 0),
    ^{
        [__self cloudInit];
    });
}

-(void)clickRightBtn
{
    if (rightView.x == fWidth-100)//显示
    {
        rightView.frame = Rect(fWidth-40, 0, 40, fHeight);
    }
    else
    {
        rightView.frame = Rect(fWidth-100 , 0, 100, fHeight);
    }
}

-(void)panEvent:(UIPanGestureRecognizer*)sender
{
    if ([sender state]== UIGestureRecognizerStateBegan)
    {
        CGPoint curPoint = [sender locationInView:self.view];
        lastX = curPoint.x;
        lastY = curPoint.y;
        return ;
    }
    CGPoint curPoint = [sender locationInView:self.view];
    CGFloat frameX = (imgView.x + (curPoint.x-lastX)) > 0 ? 0 : (abs(imgView.x+(curPoint.x-lastX))+fWidth >= imgView.width ? -(imgView.width-fWidth) : (imgView.x+(curPoint.x-lastX)));
    CGFloat frameY =(imgView.y + (curPoint.y-lastY))>0 ? 0: (abs(imgView.y+(curPoint.y-lastY))+fHeight >= imgView.height ? -(imgView.height-fHeight) : (imgView.y+(curPoint.y-lastY)));
    imgView.frame = Rect(frameX,frameY , imgView.width, imgView.height);
    lastX = curPoint.x;
    lastY = curPoint.y;
}

-(void)pinchEvent:(UIPinchGestureRecognizer*)sender
{
    DLog(@"点击事件");
    if([sender state] == UIGestureRecognizerStateBegan) {
        //   lastScale = 1.0;
        return;
    }
    CGFloat glWidth = imgView.frame.size.width;
    CGFloat glHeight = imgView.frame.size.height;
    CGFloat fScale = 0;
    
    if ([sender scale]>1)
    {
        fScale = 1.011;
    }
    else
    {
        fScale = 0.99;
    }
    
    if (imgView.frame.size.width * [sender scale] <= fWidth)
    {
        lastScale = 1.0f;
        imgView.frame = Rect(0, 0, fWidth, fHeight);
        [imgView removeGestureRecognizer:_panGesture];
    }
    else
    {
        lastScale = 1.5f;
        [imgView addGestureRecognizer:_panGesture];
//        CGPoint point = [sender locationInView:self.view];
        CGFloat nowWidth = glWidth*fScale>fWidth*4?fWidth*4:glWidth*fScale;
        CGFloat nowHeight =glHeight*fScale >fHeight* 4?fHeight*4:glHeight*fScale;
        imgView.frame = Rect(fWidth/2 - nowWidth/2,fHeight/2- nowHeight/2,nowWidth,nowHeight);
    }
}

/**
 *  点击事件
 *
 *  @param tapGesture 手势事件
 */
-(void)handleTapNew:(UITapGestureRecognizer*)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [tapGesture locationInView:self.view];
        if (point.y < 40 || point.y > downView.frame.origin.y)
        {
            return ;
        }
        if (tapGesture == _tapGestureRecognizer)
        {
            topView.hidden = !topView.hidden;
            downView.hidden = !downView.hidden;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

-(void)initBodyView
{
    topView = [[UIView alloc] initWithFrame:Rect(0, 0, self.view.height,49)];
    [self.view addSubview:topView];
    UILabel *sLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0, topView.frame.size.height-0.2, kScreenWidth, 0.1)];
    sLine1.backgroundColor = [UIColor colorWithRed:198/255.0
                                             green:198/255.0
                                              blue:198/255.0
                                             alpha:1.0];
    UILabel *sLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0, topView.frame.size.height-0.1, kScreenWidth, 0.1)] ;
    sLine2.backgroundColor = [UIColor whiteColor];
    sLine1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    sLine2.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [topView addSubview:sLine1];
    [topView addSubview:sLine2];
    
    _lblName = [[UILabel alloc] initWithFrame:Rect(30,15,kScreenWidth-60,20)];
    [_lblName setTextAlignment:NSTextAlignmentCenter];
    [_lblName setText:@"回放"];
    [_lblName setFont:[UIFont fontWithName:@"Helvetica" size:15.0f]];
    
    [_lblName setTextColor:[UIColor whiteColor]];
    [topView addSubview:_lblName];
    
    UIButton *_doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneButton setImage:[UIImage imageNamed:@"NaviBtn_Back"] forState:UIControlStateNormal];
    [_doneButton setImage:[UIImage imageNamed:@"NaviBtn_Back_H"] forState:UIControlStateHighlighted];
    _doneButton.frame = CGRectMake(5,2.5,44,44);
    _doneButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    _doneButton.showsTouchWhenHighlighted = YES;
    [_doneButton addTarget:self action:@selector(doneDidTouch) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:_doneButton];
    
    UIImageView *topViewBg = [[UIImageView alloc] initWithFrame:topView.bounds];
    [topViewBg setImage:[UIImage imageNamed:@"ptz_bg"]];
    topViewBg.tag = 10088;
    [topView insertSubview:topViewBg atIndex:0];
    
    downView = [[UIView alloc] initWithFrame:Rect(0, self.view.width-120, self.view.height,120)];
    [self.view addSubview:downView];
    
    UIImageView *downViewBg = [[UIImageView alloc] initWithFrame:downView.bounds];
    [downViewBg setImage:[UIImage imageNamed:@"ptz_bg"]];
    downViewBg.tag = 10089;
    [downView insertSubview:downViewBg atIndex:0];
   
    //CloudButton
    btnPause = [[CloudButton alloc] initWithFrame:Rect(60, 200,60, 49) normal:@"play_cl" high:@"pause_cl_h" select:@"pause_cl"];
    [downView addSubview:btnPause];
    [btnPause addTarget:self action:@selector(startPlayCloudEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    btnCamera = [[CloudButton alloc] initWithFrame:Rect(btnPause.x+btnPause.width+14, 200,60, 49) normal:@"photo_cl" high:@"photo_cl_h"];
    [downView addSubview:btnCamera];
    
    btnRecord = [[CloudButton alloc] initWithFrame:Rect(btnCamera.x+btnCamera.width+14, 200,60, 49) normal:@"record_cl" high:@"record_cl_h"];
    [downView addSubview:btnRecord];
    
    btnStop = [[CloudButton alloc] initWithFrame:Rect(btnRecord.x+btnRecord.width+14, 200,60, 49) normal:@"stop_cl" high:@"stop_cl_h"];
    [downView addSubview:btnStop];
    
    btnDate = [[CloudButton alloc] initWithFrame:Rect(btnStop.x+btnStop.width+14, 200,60, 49) normal:@"date_cl" high:@"date_cl_h"];
    [downView addSubview:btnDate];
}

-(void)startPlayCloud
{
    unsigned int nTime = (unsigned int)[timeView currentTime];
    CloudDecode *cloudDec = nil;
    if(aryDecode.count==0)
    {
        DLog(@"个数为0");
        return ;
    }
    cloudDec = [aryDecode objectAtIndex:0];
    BOOL bFlag = [cloudDec startVideo:nTime];
    if (!bFlag)
    {
        return ;
    }
    __weak PlayCloudViewController *__self = self;
    dispatch_async(dispatch_get_global_queue(0, 0),
    ^{
       [__self startPlayCloud_gcd];
    });
    btnPause.selected = YES;
    [ProgressHUD dismiss];
}

-(void)startPlayCloudEvent:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        //播放视频
        [self startPlayCloud];
    }
    else
    {
        //暂停视频
        [self pauseVideo];
    }
}

-(void)cloudInit
{
    CloudDecode *cloudDec = [[CloudDecode alloc] initWithCloud:_strNO channel:nChannel codeType:0];
    [aryDecode addObject:cloudDec];
    __weak TimeView *__timeView = timeView;
    __weak PlayCloudViewController *__self = self;
    cloudDec.cloudBlock = ^(int nStatus,NSArray *ary)
    {
        if(nStatus==0)
        {
            __strong PlayCloudViewController *__strongSelf = __self;
            dispatch_async(dispatch_get_main_queue(),
            ^{
                [__strongSelf.view makeToast:XCLocalized(@"connectFail")];
            });
        }
        else
        {
            [__timeView.aryDate removeAllObjects];
            [__timeView.aryDate addObjectsFromArray:ary];
            DLog(@"请求播放视频");
            [__timeView startTimeCome];
            dispatch_async(dispatch_get_main_queue(),
            ^{
                [ProgressHUD dismiss];
            });
            __strong PlayCloudViewController *__strongSelf = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [__strongSelf startPlayCloud];
            });
        }
    };
    [cloudDec checkView:timeView.strDate];
}

-(void)enterBackgroud
{
    if(aryDecode.count > 1)
    {
        CloudDecode *cloudDec = [aryDecode objectAtIndex:0];
        [cloudDec stopDecode];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGFloat heightInfo = kScreenSourchHeight;
    if (IOS_SYSTEM_8)
    {
        heightInfo = kScreenSourchWidth;
    }
    
    if(IOS_SYSTEM_8)
    {
        fWidth = self.view.width;
        fHeight = self.view.height;
    }
    else
    {
        fWidth = self.view.height;
        fHeight = self.view.width;
    }
    
    topView.frame = Rect(0, 0, fWidth, 49);
    _lblName.frame = Rect(30, 15, fWidth-60, 20);
    [topView viewWithTag:10088].frame = topView.bounds;
    downView.frame = Rect(0, fHeight-120, fWidth, 120);
    [downView viewWithTag:10089].frame = downView.bounds;
    
    NSDate *date = [NSDate date];
    NSDateFormatter *nsFormat = [[NSDateFormatter alloc] init];
    nsFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    nsFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    timeView = [[TimeView alloc] initWithFrame:Rect(0, 300,heightInfo,60) time:[nsFormat stringFromDate:date]];
    
    [downView addSubview:timeView];
    timeView.frame = Rect(0,3,heightInfo,60);
    //5*60
    CGFloat fStart = heightInfo/2 - 150;
    btnPause.frame = Rect(fStart+0,65, 60, 48);
    btnCamera.frame = Rect(fStart+60,65, 60, 48);
    btnRecord.frame = Rect(fStart+120,65, 60, 48);
    btnStop.frame = Rect(fStart+180,65, 60, 48);
    btnDate.frame = Rect(fStart+240,65, 60, 48);
    
    rightView.hidden = NO;
    rightView.frame = Rect(fWidth - 40, 0, 40, fHeight);
    scrolView.frame = Rect(40, 0, 60,fHeight);
    scrolView.contentSize = CGSizeMake(60,60*nAllCount);
    __weak PlayCloudViewController *__self = self;
    dispatch_async(dispatch_get_global_queue(0,0),
    ^{
        [__self cloudInit];
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rePlayInfo) name:NS_TIME_CURRENT_PAN_EVENT_VC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnect) name:NSCONNECT_P2P_DISCONNECT object:nil];
}

-(void)disconnect
{
    __weak PlayCloudViewController *__self = self;
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [__self.view makeToast:XCLocalized(@"Disconnect") duration:1.5f position:@"center"];
    });
    if (aryDecode.count==0)
    {}
    else
    {
        CloudDecode *cloudDec = [aryDecode objectAtIndex:0];
        [cloudDec stopDecode];
        [aryDecode removeObjectAtIndex:0];
        cloudDec = nil;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)rePlayInfo
{
    if (_bPlaying)
    {
        if ([NSThread isMainThread])
        {
            [self stopVideo];
            DLog(@"主线程");
            if (IOS_SYSTEM_8)
            {
                [ProgressHUD show:XCLocalized(@"loading") viewInfo:self.view];
            }
            else
            {
                [ProgressHUD showPlayRight:XCLocalized(@"loading") viewInfo:self.view];
            }
            [self performSelector:@selector(startPlayCloud) withObject:nil afterDelay:1.5f];
            
        }
        else
        {
            __weak PlayCloudViewController *__self = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                DLog(@"子线程!");
                [__self stopVideo];
                [__self startPlayCloud];
            });
        }
    }
}

-(void)doneDidTouch
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

-(BOOL)prefersStatusBarHidden
{
    return  YES;
}

-(BOOL)shouldAutorotate
{
    return  NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return  UIInterfaceOrientationMaskLandscapeRight;
}

-(void)startPlayCloud_gcd
{
    __weak PlayCloudViewController *__self = self;
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [__self initGlView];
    });
    _bPlaying = YES;
    _bDecoding = NO;
    if(aryDecode.count==0)
    {
        return ;
    }
    CloudDecode *cloudDec = [aryDecode objectAtIndex:0];
    while (cloudDec.fps!=30)
    {
        [NSThread sleepForTimeInterval:0.1];
    }
    _videoFrames = [NSMutableArray array];
    DLog(@"开始播放");
    dispatch_async(dispatch_get_global_queue(0, 0),
    ^{
        [__self startPlay];
    });
    //开始解码模块
}

-(void)initGlView
{
    if (imgView == nil)
    {
        imgView = [[UIImageView alloc] initWithFrame:Rect(0, 0, fWidth, fHeight)];
    }
    [self.view insertSubview:imgView atIndex:0];
    [imgView setUserInteractionEnabled:YES];
    [imgView addGestureRecognizer:_tapGestureRecognizer];
    [imgView addGestureRecognizer:pinchGesture];
    [imgView addGestureRecognizer:_panGesture];
}

-(void)startPlay
{
    if(_bPlaying)
    {
        if(_videoFrames.count>0)
        {
            [self updatePlayUI];
        }
        if (_videoFrames.count==0)
        {
            //解码开启
            [self decodeAsync];
        }
        __weak PlayCloudViewController *__weakSelf = self;
        dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 0.025 * NSEC_PER_SEC );
        dispatch_after(after, dispatch_get_global_queue(0, 0),
        ^{
             [__weakSelf startPlay];
        });
    }
}

-(void)decodeAsync
{
    if (!_bPlaying || _bDecoding)
    {
        return ;
    }
    _bDecoding = YES;
    __weak PlayCloudViewController *__weakSelf = self;
    
    if(aryDecode.count==0)
    {
        return ;
    }
    CloudDecode *cloudDec = [aryDecode objectAtIndex:0];
    
    __weak CloudDecode *__decoder = cloudDec;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL bGood = YES;
        while (bGood)
        {
            NSArray *array = [__decoder decodeFrame];
            bGood = NO;
            if (array && array.count>0)
            {
                @synchronized(__weakSelf.videoFrames)
                {
                    for (KxVideoFrame *frame in array)
                    {
                        [__weakSelf.videoFrames addObject:frame];
                    }
                }
                array = nil;
            }
        }
        __weakSelf.bDecoding = NO;
    });
}

-(CGFloat)updatePlayUI
{
    CGFloat interval = 0;
    KxVideoFrame *frame;
    @synchronized(_videoFrames)
    {
        if (_videoFrames.count > 0)
        {
            frame = _videoFrames[0];
            [_videoFrames removeObjectAtIndex:0];
        }
    }
    if (frame)
    {
        KxVideoFrameRGB *rgbFrame = (KxVideoFrameRGB*)frame;
        __weak UIImageView *__imgView = imgView;
        __weak KxVideoFrameRGB *__rgbFrame = rgbFrame;
        dispatch_sync(dispatch_get_main_queue(),
        ^{
              [__imgView setImage:nil];
              [__imgView setImage:[__rgbFrame asImage]];
        });
        rgbFrame = nil;
        interval = frame.duration;
        frame = nil;
    }
    return interval;
}

-(void)pauseVideo
{
    if(aryDecode.count==0)
    {
        return ;
    }
    CloudDecode *cloudDec = [aryDecode objectAtIndex:0];
    [cloudDec pauseVideo];
    _bPlaying = NO;
    _bDecoding = YES;
}

-(void)stopVideo
{
    if(aryDecode.count==0)
    {
        return ;
    }
    CloudDecode *cloudDec = [aryDecode objectAtIndex:0];
    [cloudDec stopDecode];
    _bPlaying = NO;
    _bDecoding = YES;
    @synchronized(_videoFrames)
    {
        [_videoFrames removeAllObjects];
    }
    _videoFrames = nil;
    if([NSThread isMainThread])
    {
        [imgView removeFromSuperview];
    }
    else
    {
        UIImageView *__imgView = imgView;
        dispatch_async(dispatch_get_main_queue(), ^{
            [__imgView removeFromSuperview];
        });
        imgView = nil;
    }
}

-(void)dealloc
{
    [self stopVideo];
    _bDecoding = YES;
    _bPlaying = NO;
    [imgView removeFromSuperview];
    @synchronized(_videoFrames)
    {
        [_videoFrames removeAllObjects];
    }
    [timeView removeFromSuperview];
    timeView = nil;
}

-(void)captureView
{
    BOOL bFLag = [CaptureService captureToPhotoRGB:imgView devName:strDevName];
    if (bFLag)
    {
        [self.view makeToast:XCLocalized(@"captureS") duration:1.0f position:@"center"];
    }
    else
    {
        [self.view makeToast:XCLocalized(@"captureF") duration:1.0f position:@"center"];
    }
}

@end
