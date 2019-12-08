//
//  SFIMGroupBarItem.m
//  HZFGroupBar
//
//  Created by Eric Huang on 2019/12/8.
//  Copyright © 2019 hzf. All rights reserved.
//

#import "SFIMGroupBarItem.h"

@implementation SFIMBarItem

@end

@implementation SFIMGroupBarItem

- (instancetype)initWithItemArray:(NSArray<SFIMBarItem *> *)item
                     dataDescribe:(NSString *)dataDescribe {
    self = [super init];
    if (self) {
        self.datas = [item copy];
        self.dataDescribe = dataDescribe;
    }
    return self;
}

@end
