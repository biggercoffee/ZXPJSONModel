
#import "NSObject+ZXPJSONModel.h"
#import <objc/runtime.h>

@implementation NSObject (ZXPJSONModel)

- (void)zxp_setValuesWithDictionary:(NSDictionary<NSString *,id> *)dictionary {
    
    if ([dictionary isEqual:[NSNull null]] || dictionary == nil) {
        return;
    }
    
    uint count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int i = 0;i < count ; i++) {
        @autoreleasepool {
            objc_property_t property = properties[i];
            NSString *propertyName = @(property_getName(property));
            NSString *propertyType = @(property_getAttributes(property));
            
            if ([self.zxp_ignoreMapProperties containsObject:propertyName]) {
                continue;
            }
            
            id value = dictionary[propertyName];
            
            if (![value isEqual:[NSNull null]] && [propertyType rangeOfString:@",R,"].location == NSNotFound) {
                NSString *type = [[propertyType substringWithRange:NSMakeRange(1, 1)] uppercaseString];
                id newValue = nil;
                switch ([type characterAtIndex:0]) {
                    case 'Q':
                        newValue = @([value integerValue]);
                        break;
                    case 'D':
                        newValue = @([value doubleValue]);
                        break;
                    case '@': {
                        
                        NSString *propertyClassName = [propertyType substringFromIndex:3];
                        propertyClassName = [propertyClassName substringToIndex:[propertyClassName rangeOfString:@"\","].location];
                        
                        newValue = value;
                        if ([propertyClassName isEqualToString:@"NSString"]) {
                            if ([value isKindOfClass:NSClassFromString(@"__NSCFNumber")]) {
                                newValue = [value stringValue];
                            }
                        }
                        else if ([propertyClassName hasPrefix:@"NS"]) {
                            break;
                        }
                        else {
                            [self zxp_setObjectClassForObject:@{propertyName:NSClassFromString(propertyClassName)}];
                        }
                        
                        break;
                    }
                    case 'B': {
                        newValue = value;
                        if (newValue == nil) {
                            newValue = @NO;
                        }
                        break;
                    }
                    default:
                        newValue = value;
                        break;
                }
                [self setValue:newValue forKey:propertyName];
            }
            
            NSDictionary<NSString *,Class> *objectClassDictionary = objc_getAssociatedObject(self, @selector(zxp_setObjectClassForObject:));
            NSDictionary<NSString *,Class> *objectClassInArrayDictionary = objc_getAssociatedObject(self, @selector(zxp_setObjectClassInArray:));
            if ([objectClassDictionary.allKeys containsObject:propertyName]) {
                
                NSObject *obj = [self valueForKey:propertyName];
                
                if (obj == nil) {
                    Class mapClass = objectClassDictionary[propertyName];
                    obj = [mapClass new];
                }
                
                [obj zxp_setValuesWithDictionary:value];
                [self setValue:obj forKey:propertyName];
            }
            else if ([objectClassInArrayDictionary.allKeys containsObject:propertyName]) {
                Class mapClass = objectClassInArrayDictionary[propertyName];
                
                NSMutableArray *newValues = [NSMutableArray array];
                
                NSArray<NSDictionary *> *dictionaryInArray = value;
                if (dictionaryInArray && ![dictionaryInArray isEqual:[NSNull null]]) {
                    [dictionaryInArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSObject *objInArray = [mapClass new];
                        [objInArray zxp_setValuesWithDictionary:obj];
                        [newValues addObject:objInArray];
                    }];
                }
                
                [self setValue:[newValues copy] forKey:propertyName];
            }
            else {
                if ([value isEqual:[NSNull null]]) {
                    [self setValue:@"" forKey:propertyName];
                }
            }
        }
    }
    
    free(properties);
}

- (void)zxp_setValuesWithJSONString:(NSString *)jsonString error:(NSError *)error{
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    [self zxp_setValuesWithDictionary:dictionary];
}

- (NSDictionary *)zxp_convertToDictionary {
    NSMutableDictionary *result = [@{} mutableCopy];
    uint count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int i = 0;i < count ; i++) {
        @autoreleasepool {
            objc_property_t property = properties[i];
            NSString *propertyName = @(property_getName(property));
            NSString *propertyType = @(property_getAttributes(property));
            
            NSString *type = [[propertyType substringWithRange:NSMakeRange(1, 1)] uppercaseString];
            switch ([type characterAtIndex:0]) {
                case '@': {
                    
                    NSString *propertyClassName = [propertyType substringFromIndex:3];
                    propertyClassName = [propertyClassName substringToIndex:[propertyClassName rangeOfString:@"\","].location];
                    
                    if (![propertyClassName hasPrefix:@"NS"]) {
                        [self zxp_setObjectClassForObject:@{propertyName:NSClassFromString(propertyClassName)}];
                    }
                    break;
                }
            }
            
            if (class_respondsToSelector([self class], NSSelectorFromString(propertyName))) {
                id propertyValue = [self valueForKey:propertyName];
                
                NSDictionary<NSString *,Class> *objectClassDictionary = objc_getAssociatedObject(self, @selector(zxp_setObjectClassForObject:));
                
                if (objectClassDictionary && [objectClassDictionary.allKeys containsObject:propertyName]) {
                    if (objectClassDictionary[propertyName] == [propertyValue class]) {
                        propertyValue = [propertyValue zxp_convertToDictionary];
                    }
                }
                else {
                    NSDictionary<NSString *,Class> *objectClassInArrayDictionary = objc_getAssociatedObject(self, @selector(zxp_setObjectClassInArray:));
                    if (objectClassInArrayDictionary && [objectClassInArrayDictionary.allKeys containsObject:propertyName]) {
                        
                        NSMutableArray<NSDictionary *> *newValue = [NSMutableArray array];
                        [(NSArray<id> *)propertyValue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if (objectClassInArrayDictionary[propertyName] == [obj class]) {
                                [newValue addObject:[obj zxp_convertToDictionary]];
                            }
                        }];
                        propertyValue = newValue;
                    }
                }
                
                [result setObject:propertyValue?:[NSNull null] forKey:propertyName];
            }
        }
    }
    free(properties);
    
    return [result copy];
}

- (NSString *)zxp_convertToJSONStringWithError:(NSError *)error {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self zxp_convertToDictionary] options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (void)zxp_setObjectClassInArray:(NSDictionary<NSString *,Class> *)dictionary {
    objc_setAssociatedObject(self, _cmd, dictionary, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

/**
 *  映射的对象
 *
 *  @param dictionary key为属性名,value为映射对象的class
 */
- (void)zxp_setObjectClassForObject:(NSDictionary<NSString *,Class> *)dictionary {
    objc_setAssociatedObject(self, _cmd, dictionary, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setZxp_ignoreMapProperties:(NSArray<NSString *> *)zxp_ignoreMapProperties {
    objc_setAssociatedObject(self, @selector(zxp_ignoreMapProperties), zxp_ignoreMapProperties.copy, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSArray<NSString *> *)zxp_ignoreMapProperties {
    return objc_getAssociatedObject(self, _cmd);
}

@end
