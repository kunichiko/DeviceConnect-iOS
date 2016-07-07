//
//  DeviceIconViewCell.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/01.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "DeviceIconViewCell.h"

@implementation DeviceIconViewCell
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.viewModel = [[DeviceIconViewModel alloc]init];
    }
    return self;
}

- (void)layoutSubviews
{
    self.iconImage.layer.cornerRadius = 10;
    self.iconImage.clipsToBounds = YES;
}

- (void)setDevice:(DConnectMessage*)message
{
    self.iconImage.image = nil;
    self.viewModel.message = message;
    self.titleLabel.text = self.viewModel.name;

    NSString* target = @"dConnectDevicePebble"; //TODO: DConnectMessage.idからターゲットを判定する
    NSString* bundle = [[NSBundle mainBundle] pathForResource:target ofType:@"bundle"];
    if (bundle) {
        NSString* imagePath = [NSString stringWithFormat:@"%@/dconnect_icon.png", bundle];
        self.iconImage.image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    } else {
        self.iconImage.image = [UIImage imageNamed:@"default_device_icon"];
    }
    [self setEnabled:YES];
}

- (void)setEnabled:(BOOL)isEnabled
{
    self.iconImage.hidden = !isEnabled;
    self.titleLabel.hidden = !isEnabled;
    self.selectButton.enabled = isEnabled;
}


//--------------------------------------------------------------//
#pragma mark - ボタン制御
//--------------------------------------------------------------//
- (IBAction)didTapItem:(UIButton *)sender {
    self.didIconSelected(self.viewModel.message);
    self.alpha = 1.0;
}

- (IBAction)didTouchDown:(UIButton *)sender {
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = 0.3;
    }];
}

- (IBAction)backNormal:(UIButton *)sender {
    self.alpha = 1.0;
}

- (void)dealloc
{
    self.didIconSelected = nil;
}

@end
