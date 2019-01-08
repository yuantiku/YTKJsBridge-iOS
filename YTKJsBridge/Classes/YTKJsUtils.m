//
//  YTKJsUtils.m
//  Pods-YTKJsBridge_Example
//
//  Created by lihaichun on 2019/1/7.
//

#import "YTKJsUtils.h"
#import <objc/runtime.h>

@implementation YTKJsUtils

+ (nullable NSString *)objToJsonString:(nonnull id)dict {
    NSString *jsonString = nil;
    NSError *error;

    if (![NSJSONSerialization isValidJSONObject:dict]) {
        return @"{}";
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (!jsonData) {
        return @"{}";
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+ (nullable id)jsonStringToObject:(nonnull NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (nullable NSString *)methodByNameArg:(NSInteger)argNum
                               selName:(nullable NSString *)selName
                                 class:(nonnull Class)class {
    __block NSString *result = nil;
    if(class){
        NSArray<NSString *> *arr = [self allMethodFromClass:class];
        [arr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *tmpArr = [obj componentsSeparatedByString:@":"];
            NSRange range = [obj rangeOfString:@":"];
            if (range.length > 0) {
                NSString *methodName = [obj substringWithRange:NSMakeRange(0, range.location)];
                if ([methodName isEqualToString:selName] && tmpArr.count == (argNum + 1)) {
                    result = obj;
                    *stop = YES;
                }
            }
        }];
    }
    return result;
}

+ (nonnull NSArray<NSString *> *)parseNamespace:(nonnull NSString *)method {
    if (NO == [method isKindOfClass:[NSString class]] || method.length == 0) {
        return @[@"", @""];
    }
    NSRange range = [method rangeOfString:@"." options:NSBackwardsSearch];
    NSString *namespace = @"";
    if(range.location != NSNotFound) {
        namespace = [method substringToIndex:range.location];
        method = [method substringFromIndex:range.location + 1];
    }
    return @[namespace, method];
}

// get this class all method
+ (NSArray<NSString *> *)allMethodFromClass:(Class)class {
    NSMutableArray *methods = @[].mutableCopy;
    while (class) {
        unsigned int count = 0;
        Method *method = class_copyMethodList(class, &count);
        for (unsigned int i = 0; i < count; i++) {
            SEL name1 = method_getName(method[i]);
            const char *selName = sel_getName(name1);
            NSString *strName = [NSString stringWithCString:selName encoding:NSUTF8StringEncoding];
            [methods addObject:strName];
        }
        free(method);

        Class cls = class_getSuperclass(class);
        class = [NSStringFromClass(cls) isEqualToString:NSStringFromClass([NSObject class])] ? nil : cls;
    }

    return [NSArray arrayWithArray:methods];
}

@end
