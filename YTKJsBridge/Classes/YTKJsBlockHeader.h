//
//  YTKJsBlockHeader.h
//  Pods
//
//  Created by lihaichun on 2019/2/22.
//

#ifndef YTKJsBlockHeader_h
#define YTKJsBlockHeader_h

typedef void (^YTKDataCallback) (NSError * __nullable error, id __nullable data);
typedef void (^YTKAsyncCallback) (NSArray * __nullable argument, YTKDataCallback block);
typedef id _Nullable (^YTKSyncCallback) (NSArray * __nullable argument);
typedef void (^YTKVoidSyncCallback) (NSArray * __nullable argument);
typedef void (^YTKEventCallback) (NSArray * __nullable argument);

#endif /* YTKJsBlockHeader_h */
