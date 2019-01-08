//
//  YTKJsUtils.h
//  Pods-YTKJsBridge_Example
//
//  Created by lihaichun on 2019/1/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YTKJsUtils : NSObject

+ (nullable NSString *)objToJsonString:(nonnull id)dict;

+ (nullable id)jsonStringToObject:(nonnull NSString *)jsonString;

+ (nullable NSString *)methodByNameArg:(NSInteger)argNum
                               selName:(nullable NSString *)selName
                                 class:(nonnull Class)class;

+ (nonnull NSArray<NSString *> *)parseNamespace:(nonnull NSString *)method;

@end

NS_ASSUME_NONNULL_END
