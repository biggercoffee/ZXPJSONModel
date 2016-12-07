
// version: 1.0.0

#import <Foundation/Foundation.h>

#define ZXPJSONModelPropertyName(__name) NSStringFromSelector(@selector(__name))

@interface NSObject (ZXPJSONModel)

/**
 *  把当前类的属性转成字典
 *
 */
- (NSDictionary *)zxp_convertToDictionary;

/**
 *  把当前class的属性转换成JSON字符串
 *
 *  @param error error description
 *
 *  @return return value description
 */
- (NSString *)zxp_convertToJSONStringWithError:(NSError *)error;

/**
 *  根据字典映射对象
 *
 *  @param dictionary 字典中的key是对象属性
 */
- (void)zxp_setValuesWithDictionary:(NSDictionary<NSString *,id> *)dictionary;

/**
 *  根据JSON映射对象
 *
 *  param dictionary JSON中的key是对象属性
 */
- (void)zxp_setValuesWithJSONString:(NSString *)jsonString error:(NSError *)error;

/**
 *  设置数组里装载的对象class
 *
 *  @param dictionary key为属性名,value为映射对象的class
 */
- (void)zxp_setObjectClassInArray:(NSDictionary<NSString *,Class> *)dictionary;

///忽略映射的属性，如果属性被加入到此数组里，则在为model赋值的时候，被列入的属性不会进行映射
@property (nonatomic,copy) NSArray<NSString *> *zxp_ignoreMapProperties;

@end
