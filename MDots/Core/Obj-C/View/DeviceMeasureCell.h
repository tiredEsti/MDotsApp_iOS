//
//  DeviceMeasureCell.h
//  MDots
//
//  Created by Estela Alvarez on 28/4/24.
//

#import <UIKit/UIKit.h>
#import <MovellaDotSdk/DotDevice.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceMeasureCell : UITableViewCell

@property (strong, nonatomic) DotDevice *device;
@property (strong, nonatomic) UILabel *orientationLabel;

+ (NSString *)cellIdentifier;
+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END
