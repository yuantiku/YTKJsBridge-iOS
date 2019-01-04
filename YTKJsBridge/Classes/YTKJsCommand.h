//
//  YTKJSCommand.h
//  YTKJsBridge
//
//  Created by lihaichun on 2018/12/21.
//  Copyright © 2018年 fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YTKJsCommand : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSDictionary *arguments;

@property (nonatomic, copy) NSString *callback;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
