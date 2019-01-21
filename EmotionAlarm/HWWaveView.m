//
//  HWWaveView.m
//  HWProgress
//
//  Created by sxmaps_w on 2017/3/3.
//  Copyright © 2017年 hero_wqb. All rights reserved.
//

#import "HWWaveView.h"

#define KHWWaveFillColor [UIColor groupTableViewBackgroundColor] //fill color
#define KHWWaveTopColor [UIColor colorWithRed:0/255.0 green:191/255.0 blue:255/255.0 alpha:1.0f] //top wave color
#define KHWWaveBottomColor [UIColor colorWithRed:0/255.0 green:191/255.0 blue:255/255.0 alpha:0.4f] //bottom wave color

@interface HWWaveView ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat wave_amplitude;
@property (nonatomic, assign) CGFloat wave_cycle;
@property (nonatomic, assign) CGFloat wave_h_distance;
@property (nonatomic, assign) CGFloat wave_v_distance;
@property (nonatomic, assign) CGFloat wave_scale;
@property (nonatomic, assign) CGFloat wave_offsety;
@property (nonatomic, assign) CGFloat wave_move_width;
@property (nonatomic, assign) CGFloat wave_offsetx;
@property (nonatomic, assign) CGFloat offsety_scale;

@end

@implementation HWWaveView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}

- (void)layoutSubviews{
    [self initInfo];
}

- (void)initInfo
{
    self.titleLabel.frame = CGRectMake(5, 5, self.frame.size.width-10, self.frame.size.height-10);
    [self addSubview:self.titleLabel];
    _progress = 0;
    _wave_amplitude = self.frame.size.height / 25;
    _wave_cycle = 2 * M_PI / (self.frame.size.width * 0.9);
    _wave_h_distance = 2 * M_PI / _wave_cycle * 0.6;
    _wave_v_distance = _wave_amplitude * 0.4;
    _wave_move_width = 0.5;
    _wave_scale = 0.4;
    _offsety_scale = 0.1;
    _wave_offsety = (1 - _progress) * (self.frame.size.height + 2 * _wave_amplitude);
    
    [self addDisplayLinkAction];
}

- (void)addDisplayLinkAction
{
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)displayLinkAction
{
    _wave_offsetx += _wave_move_width * _wave_scale;
    
    if (_wave_offsety <= 0.01)  [self removeDisplayLinkAction];
    
    [self setNeedsDisplay];
}

- (void)removeDisplayLinkAction
{
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    path.lineWidth = 2.0f;
    [KHWWaveTopColor set];
    [KHWWaveFillColor setFill];
    [path fill];
    [path addClip];

    [self drawWaveColor:KHWWaveTopColor offsetx:0 offsety:0];
    [self drawWaveColor:KHWWaveBottomColor offsetx:_wave_h_distance offsety:_wave_v_distance];
}

- (void)drawWaveColor:(UIColor *)color offsetx:(CGFloat)offsetx offsety:(CGFloat)offsety
{
    CGFloat end_offY = (1 - _progress) * (self.frame.size.height + 2 * _wave_amplitude);
    if (_wave_offsety != end_offY) {
        if (end_offY < _wave_offsety) {
            _wave_offsety = MAX(_wave_offsety -= (_wave_offsety - end_offY) * _offsety_scale, end_offY);
        }else {
            _wave_offsety = MIN(_wave_offsety += (end_offY - _wave_offsety) * _offsety_scale, end_offY);
        }
    }
    
    UIBezierPath *wavePath = [UIBezierPath bezierPath];
    for (float next_x = 0.f; next_x <= self.frame.size.width; next_x ++) {
        CGFloat next_y = _wave_amplitude * sin(_wave_cycle * next_x + _wave_offsetx + offsetx / self.bounds.size.width * 2 * M_PI) + _wave_offsety + offsety;
        if (next_x == 0) {
            [wavePath moveToPoint:CGPointMake(next_x, next_y - _wave_amplitude)];
        }else {
            [wavePath addLineToPoint:CGPointMake(next_x, next_y - _wave_amplitude)];
        }
    }
    
    [wavePath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [wavePath addLineToPoint:CGPointMake(0, self.bounds.size.height)];
    [color set];
    [wavePath fill];
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"Open Your Eyes";
        _titleLabel.textColor = KHWWaveTopColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end

