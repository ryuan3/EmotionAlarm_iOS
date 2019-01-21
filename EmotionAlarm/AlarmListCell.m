//
//  AlarmListCell.m
//  EmotionAlarm
//
//  Created by Aurora on 29/07/2018.
//  Copyright © 2018 ruiling. All rights reserved.
//

#import "AlarmListCell.h"

@implementation AlarmListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self makeInterface];
        [self makeConstraints];
    }
    return self;
}

- (void)makeInterface{
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.cellSwitch];
}

- (void)makeConstraints{

    [[self.timeLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20]setActive:YES];
    [[self.timeLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor]setActive:YES];
    [[self.timeLabel.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor multiplier:0.6] setActive:YES];
    [[self.timeLabel.heightAnchor constraintEqualToConstant:25]setActive:YES];
    
    [[self.cellSwitch.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20]setActive:YES];
    [[self.cellSwitch.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor]setActive:YES];
//    [[self.cellSwitch.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor multiplier:0.3] setActive:YES];
//    [[self.cellSwitch.heightAnchor constraintEqualToConstant:25]setActive:YES];
    
}

- (void)switchValueChanged:(UISwitch *)cellSwitch{
    [self.delegate indexOfCell:self.index switchValue:self.cellSwitch.isOn];
}

#pragma mark Lazy Load

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        [_timeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        _timeLabel.textColor = [UIColor darkGrayColor];
        _timeLabel.font = [UIFont systemFontOfSize:15];
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

- (UISwitch *)cellSwitch{
    if (!_cellSwitch) {
        _cellSwitch = [[UISwitch alloc]init];
        [_cellSwitch setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_cellSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _cellSwitch;
}
@end
