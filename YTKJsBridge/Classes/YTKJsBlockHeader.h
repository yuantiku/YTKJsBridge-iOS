//
//  YTKJsBlockHeader.h
//  Pods
//
//  Created by lihaichun on 2019/2/22.
//

#ifndef YTKJsBlockHeader_h
#define YTKJsBlockHeader_h

typedef void (^YTKJsCallback) (NSError * __nullable error, id __nullable data);
typedef void (^YTKAsyncCallback) (NSArray * __nullable argument, __nullable YTKJsCallback block);
typedef id _Nullable (^YTKSyncCallback) (NSArray * __nullable argument);
typedef void (^YTKVoidSyncCallback) (NSArray * __nullable argument);
typedef void (^YTKEventCallback) (NSArray * __nullable argument);

typedef void (^YTKVoidCallback) (void);


#endif /* YTKJsBlockHeader_h */
