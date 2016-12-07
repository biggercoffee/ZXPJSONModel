//
//  main.m
//  Demo
//
//  Created by xiaoping on 2016/12/6.
//  Copyright © 2016年 coffee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+ZXPJSONModel.h"
#import "UserModel.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        //字典
        NSDictionary *dic = @{
                              @"username":@"coffee",
                              @"age":@"18",
                              @"height":@"1.75",
                              @"otherInfo":@{@"tel":@123456},
                              @"otherInfos":@[@{@"tel":@654321},@{@"tel":@654321000}]
                              };
        
        //基本的json映射model
        UserModel *userModel = [UserModel new];
        
        //如果映射的model里包含了数组（数组里装的是其他model），可以使用以下方法为包含的数组（数组里装的是其他model）提供映射，推荐在model的初始化方法里使用
//        [userModel zxp_setObjectClassInArray:@{@"otherInfos":[OtherModel class]}];
        
        //字典映射
        [userModel zxp_setValuesWithDictionary:dic];
        
        NSLog(@"username:%@,age=%zi,height=%f",userModel.username.className,userModel.age,userModel.height);
        NSLog(@"tel:%zi",userModel.otherInfo.tel);
        userModel.username = @"coff";
        [userModel.otherInfos enumerateObjectsUsingBlock:^(OtherModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"others tel:%zi",obj.tel);
        }];
        
        NSLog(@"%@",[userModel zxp_convertToDictionary]); //转成字典
    }
    return 0;
}
