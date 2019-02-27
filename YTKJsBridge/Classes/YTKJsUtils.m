//
//  YTKJsUtils.m
//  Pods-YTKJsBridge_Example
//
//  Created by lihaichun on 2019/1/7.
//

#import "YTKJsUtils.h"
#import <objc/runtime.h>

@implementation YTKMethodInfo

- (id)copyWithZone:(nullable NSZone *)zone {
    YTKMethodInfo *methodInfo = [[[self class] allocWithZone:zone] init];

    methodInfo.methodName = self.methodName;
    methodInfo.firstMethodName = self.firstMethodName;
    methodInfo.returnType = self.returnType;
    methodInfo.argumentNum = self.argumentNum;
    methodInfo.lastArgType = self.lastArgType;
    methodInfo.argTypes = [self.argTypes copyWithZone:zone];
    return methodInfo;
}

@end

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
        NSArray<YTKMethodInfo *> *arr = [self allMethodFromClass:class];
        [arr enumerateObjectsUsingBlock:^(YTKMethodInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [obj.methodName rangeOfString:@":"];
            if (range.length > 0) {
                NSString *methodName = [obj.methodName substringWithRange:NSMakeRange(0, range.location)];
                /** method的前面两个参数是self、SEL，因此要减2 */
                if ([methodName isEqualToString:selName] && obj.argumentNum - 2 == argNum) {
                    result = obj.methodName;
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

// get this class all method, @[methods, retTypes, argTypes]
+ (NSArray<YTKMethodInfo *> *)allMethodFromClass:(Class)class {
    NSMutableArray *methods = @[].mutableCopy;
    while (class) {
        unsigned int count = 0;
        Method *method = class_copyMethodList(class, &count);
        for (unsigned int i = 0; i < count; i++) {
            const char *returnType = method_copyReturnType(method[i]);
            unsigned int num = method_getNumberOfArguments(method[i]);
            SEL name1 = method_getName(method[i]);
            const char *selName = sel_getName(name1);
            YTKMethodInfo *methodInfo = [YTKMethodInfo new];
            if (selName && *selName != '\0') {
                methodInfo.methodName = [NSString stringWithUTF8String:selName];
            }
            if (returnType && *returnType != '\0') {
                methodInfo.returnType = [NSString stringWithUTF8String:returnType];
            }
            methodInfo.argumentNum = num;
            if (num >= 3) {
                NSMutableArray *argTypes = @[].mutableCopy;
                for (unsigned int i = 2; i < num ; i ++) {
                    const char *argumentType = method_copyArgumentType(method[i], i);
                    if (argumentType && *argumentType != '\0') {
                        NSString *strArgType = [NSString stringWithUTF8String:argumentType];
                        [argTypes addObject:strArgType];
                    } else {
                        /** 默认为对象类型参数 */
                        [argTypes addObject:@"@"];
                    }
                }
                methodInfo.argTypes = argTypes.copy;
                methodInfo.lastArgType = argTypes.lastObject;
                NSRange range = [methodInfo.methodName rangeOfString:@":"];
                methodInfo.firstMethodName = [methodInfo.methodName substringWithRange:NSMakeRange(0, range.location)];
            } else {
                methodInfo.firstMethodName = methodInfo.methodName;
            }
            [methods addObject:methodInfo];
        }
        free(method);

        Class cls = class_getSuperclass(class);
        class = [NSStringFromClass(cls) isEqualToString:NSStringFromClass([NSObject class])] ? nil : cls;
    }

    return methods;
}

@end
