//
//  DotFilterProfile.h
//  DotSdk
//
//  Created by admin on 2020/11/26.
//  Copyright © 2023 Movella. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  The Movella DOT filter profile class.
 */
@interface DotFilterProfile : NSObject

/**
 *  The filter profile index
 *  @details We currently have two types of index: 0 and 1
 */
- (UInt8)filterIndex;
/**
 *  The filter profile name
 *  @details We currently have two types of name: "General" and "Dynamic"
 */
- (NSString *)filterName;

/**
 *  Constructor method
 *  @param name The filter profile name
 *  @param index The filter profile index
 */
- (instancetype)initWithName:(NSString *)name index:(UInt8)index;

@end

NS_ASSUME_NONNULL_END
