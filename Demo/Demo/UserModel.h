//
//  UserModel.h
//  Demo
//
//  Created by xiaoping on 2016/12/6.
//  Copyright © 2016年 coffee. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OtherModel;
@interface UserModel : NSObject

@property (nonatomic,copy) NSString *username;
@property (nonatomic,assign)  NSUInteger age;
@property (nonatomic,assign)  CGFloat height;

@property (nonatomic,strong) OtherModel *otherInfo;

@property (nonatomic,copy) NSArray<OtherModel *> *otherInfos;

@end

@interface OtherModel : NSObject

@property (nonatomic,assign) NSUInteger tel;

@end

