//
//  DeviceMeasureCell.m
//  MDots
//
//  Created by Estela Alvarez on 28/4/24.
//

#import "DeviceMeasureCell.h"
#import "UIDeviceCategory.h"
#import "UIViewCategory.h"

@interface DeviceMeasureCell ()

@property (strong, nonatomic) UILabel *nameLabel;

@end

@implementation DeviceMeasureCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *nameTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 20)];
    nameTitle.text = @"Name:";
    nameTitle.font = [UIFont systemFontOfSize:14.f];
        
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameTitle.right, 10, 200, 20)];
    nameLabel.textColor = [UIColor grayColor];
    nameLabel.font = [UIFont systemFontOfSize:14.f];
    nameLabel.text = @"Movella DOT";
    
    UILabel *orientationTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, nameLabel.bottom + 5, 200, 20)];
    orientationTitle.font = [UIFont systemFontOfSize:14.f];
    orientationTitle.text = @"Orientation(deg):";
    
    UILabel *orientationLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, orientationTitle.bottom, 300, 20)];
    orientationLabel.font = [UIFont systemFontOfSize:14.f];
    orientationLabel.textColor = [UIColor grayColor];
    orientationLabel.text = @"-, -, -";
    
    
    [self.contentView addSubview:nameTitle];
    [self.contentView addSubview:nameLabel];
    [self.contentView addSubview:orientationTitle];
    [self.contentView addSubview:orientationLabel];
    
    self.nameLabel = nameLabel;
    self.orientationLabel = orientationLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setDevice:(DotDevice *)device
{
    __weak __typeof(self) wself  = self;
    _device = device;
    self.nameLabel.text = device.displayName;
    [device setDidParsePlotDataBlock:^(DotPlotData * _Nonnull plotData) {
        [wself refreshData:plotData];
    }];
    
}

- (void)refreshData:(DotPlotData *)plotData
{
    self.orientationLabel.text = [NSString stringWithFormat:@"%f, %f, %f", plotData.euler0, plotData.euler1, plotData.euler2];
}


+ (NSString *)cellIdentifier
{
    return @"DeviceMeasureCell";
}

+ (CGFloat)cellHeight
{
    return 130;
}

@end
