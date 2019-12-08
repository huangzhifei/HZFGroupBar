//
//  SFIMGroupBarItem.h
//  HZFGroupBar
//
//  Created by Eric Huang on 2019/12/8.
//  Copyright © 2019 hzf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SFIMBarItem : NSObject

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSNumber *numberValue;

@end

@interface SFIMGroupBarItem : NSObject

@property (nonatomic, strong) NSArray<SFIMBarItem *> *datas;
@property (nonatomic, strong) NSString *dataDescribe;

- (instancetype)initWithItemArray:(NSArray<SFIMBarItem *>*)item
                       dataDescribe:(NSString *)dataDescribe;

@end

NS_ASSUME_NONNULL_END
