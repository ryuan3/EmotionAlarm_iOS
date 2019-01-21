//
//  TimePickerCell.m
//  EmotionAlarm
//
//  Created by Aurora on 29/07/2018.
//  Copyright © 2018 ruiling. All rights reserved.
//

#import "TimePickerCell.h"

@implementation TimePickerCell

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
    [self.contentView addSubview:self.timePicker];
}

- (void)makeConstraints{
    
    [[self.timePicker.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor constant:0]setActive: YES];
    [[self.timePicker.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0]setActive:YES];
    [[self.timePicker.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:0]setActive:YES];
    
}

- (void)timeChanged:(id)sender{
    NSDate *newDate = self.timePicker.date;
    [self.delegate setTime:newDate];
}

#pragma mark Lazy Load

- (UIDatePicker *)timePicker{
    if (!_timePicker) {
        _timePicker = [[UIDatePicker alloc]init];
        [_timePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
        _timePicker.datePickerMode = UIDatePickerModeTime;
        _timePicker.date = [NSDate date];
        [_timePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _timePicker;
}
@end
