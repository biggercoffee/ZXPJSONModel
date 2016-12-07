//
//  UserModel.m
//  Demo
//
//  Created by xiaoping on 2016/12/6.
//  Copyright © 2016年 coffee. All rights reserved.
//

#import "UserModel.h"
#import "NSObject+ZXPJSONModel.h"
@implementation UserModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self zxp_setObjectClassInArray:@{@"otherInfos":[OtherModel class]}];
    }
    return self;
}

@end

@implementation OtherModel



@end
