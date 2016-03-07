//
//  MRRouter.m
//  MRRouter
//
//  Created by 苏合 on 15/12/31.
//  Copyright © 2015年 juangua. All rights reserved.
//

#import "MRRouter.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation NSObject(Runtime)

+ (NSArray *)loadedClassNames {
    static dispatch_once_t		once;
    static NSMutableArray *		classNames;
    
    dispatch_once( &once, ^{
        
        classNames = [[NSMutableArray alloc] init];
        
        unsigned int 	classesCount = 0;
        Class *		classes = objc_copyClassList( &classesCount );
        
        for ( unsigned int i = 0; i < classesCount; ++i )
        {
            Class classType = classes[i];
            
            if ( class_isMetaClass( classType ) )
                continue;
            
            Class superClass = class_getSuperclass( classType );
            
            if ( nil == superClass )
                continue;
            
            [classNames addObject:[NSString stringWithUTF8String:class_getName(classType)]];
        }
        
        [classNames sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        free( classes );
    });
    
    return classNames;
}

+ (NSArray<NSString *> *)subClasses {
    NSMutableArray * results = [[NSMutableArray alloc] init];
    
    for (NSString *className in [self loadedClassNames]) {
        Class classType = NSClassFromString( className );
        if (classType == self)
            continue;
        
        if (NO == [classType isSubclassOfClass:self])
            continue;
        
        [results addObject:[classType description]];
    }
    
    return results;
}

- (void)parseParameters {
    [self.mr_parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        @try {
            [self setValue:obj forKey:key];
        } @catch (NSException *exception) {}
    }];
}

@end

@interface NSURL (MRBody)

@property (nonatomic, readonly, copy) NSString *mr_body;

@end

@implementation NSURL (MRBody)

- (NSString *)mr_body {
    return [NSString stringWithFormat:@"%@://%@%@", self.scheme, self.host?:@"", self.path?:@""];
}

- (NSString *)mr_fullScheme {
    return self.scheme.length ? [NSString stringWithFormat:@"%@://", self.scheme] : self.scheme;
}

@end

@interface _MRRoute : NSObject

@property (nonatomic, copy) NSString *pattern;
@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, strong) NSArray *paths;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) MRExecutingBlock executingBlock;

- (void)parseUrl:(NSString *)URLPattern;

@end

@implementation _MRRoute

+ (_MRRoute *) routeWithURL:(NSString *)URLPattern {
    _MRRoute* route = [[_MRRoute alloc] initWithURL:URLPattern];
    return route;
}

- (instancetype)initWithURL:(NSString *)URLPattern {
    if (!URLPattern.length) {
        return nil;
    } else {
        self = [super init];
        if (self) {
            [self parseUrl:URLPattern];
        }
        return self;
    }
}

- (void)parseUrl:(NSString *)URLPattern {
    _pattern = URLPattern;
    NSURL *URL = [NSURL URLWithString:URLPattern];
    _scheme = URL.scheme;
    _host = URL.host;
    if (URL.pathComponents.count > 1) {
        _paths = [URL.pathComponents subarrayWithRange:NSMakeRange(1, URL.pathComponents.count-1)];
    }
    _body = URL.mr_body;
}

@end


@interface MRRouter ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *plistMapDictionary;
@property (nonatomic, strong) NSMutableDictionary<NSString *, _MRRoute *> *routes;
@property (nonatomic, strong) NSArray<NSString *> *defaultSubClasses;

@end

@implementation MRRouter

+ (MRRouter *)sharedInstance {
    static MRRouter *router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[MRRouter alloc] init];
    });
    return router;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _routes = [NSMutableDictionary dictionary];
        self.defaultClassType = [UIViewController class];
    }
    return self;
}

+ (void)openURL:(NSString *)URLPattern {
    return [self openURL:URLPattern parameters:nil];
}

+ (void)openURL:(NSString *)URLPattern parameters:(NSDictionary *)parameters {
    return [self openURL:URLPattern parameters:parameters prepareBlock:nil completeBlock:nil];
}

+ (void)openURL:(NSString *)URLPattern parameters:(NSDictionary *)parameters prepareBlock:(MRPrepareBlock)prepareBlock completeBlock:(MRCompleteBlock)completeBlock{
    if (!URLPattern.length && ![self canOpenURL:URLPattern]) {
        return;
    }
    NSURL* URL = [NSURL URLWithString:URLPattern];
    
    NSMutableDictionary *URLParameters = [NSMutableDictionary dictionary];
    
    if (URL.query.length) {
        NSArray* paremeterDataArray = [URL.query componentsSeparatedByString:@"&"];
        for (NSString* paramString in paremeterDataArray) {
            NSArray* paramArr = [paramString componentsSeparatedByString:@"="];
            if (paramArr.count > 1) {
                NSString* key = [[paramArr objectAtIndex:0] stringByRemovingPercentEncoding];
                NSString* value = [[paramArr objectAtIndex:1] stringByRemovingPercentEncoding];
                [URLParameters setObject:value forKey:key];
            }
        }
    }
    [URLParameters addEntriesFromDictionary:parameters];
    
    _MRRoute* route = [[MRRouter sharedInstance] routeWithURL:URLPattern];
    route.parameters = [URLParameters copy];
    if (route.executingBlock) {
        route.executingBlock(URLPattern, URLParameters);
    } else {
        [[MRRouter sharedInstance] executeDefaultBlock:route prepareBlock:prepareBlock completeBlock:completeBlock];
    }
}

+ (Class)matchClassWithURL:(NSString *)URLPattern {
    _MRRoute* route = [[MRRouter sharedInstance] routeWithURL:URLPattern];
    if (route.className) {
        return [[MRRouter sharedInstance] matchObjectByName:route.className];
    } else {
        return [[MRRouter sharedInstance] matchObjectByName:[[MRRouter sharedInstance] assembledClassNameWithString:route.host]];
    }
}

- (_MRRoute *) routeWithURL:(NSString *)URLPattern {
    if (!URLPattern.length) {
        return nil;
    }
    NSMutableDictionary<NSString *, _MRRoute *> *routes = [MRRouter sharedInstance].routes;
    NSURL* URL = [NSURL URLWithString:URLPattern];
    _MRRoute* route = routes[URL.mr_body] ? : routes[URL.mr_fullScheme];
    if (!route) {
        route = [_MRRoute routeWithURL:URLPattern];
        route.className = [[MRRouter sharedInstance] assembledClassNameWithString:route.host];
        //Add the route to memory for next time.
        [[MRRouter sharedInstance].routes setObject:route forKey:URL.mr_body];
    }
    return route;
}

- (Class)matchObjectByName:(NSString*) name {
    const char *className = [name cStringUsingEncoding:NSASCIIStringEncoding];
    __block Class objetClass = objc_getClass(className);
    if (!objetClass) {
        [_defaultSubClasses enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.lowercaseString isEqualToString:name.lowercaseString]) {
                objetClass = objc_getClass([obj cStringUsingEncoding:NSASCIIStringEncoding]);
            }
        }];
    }
    return objetClass;
}

+ (void)registerURL:(NSString *)URLPattern executingBlock:(MRExecutingBlock)executingBlock {
    if (!URLPattern.length) {
        return;
    }
    _MRRoute* route = [_MRRoute routeWithURL:URLPattern];
    route.executingBlock = executingBlock;
    if (route.host) {
        route.className = [[MRRouter sharedInstance] assembledClassNameWithString:route.host];
    }
    [[MRRouter sharedInstance].routes setObject:route forKey:[NSURL URLWithString:URLPattern].mr_body];
}

+ (void)removeURL:(NSString *)URLPattern {
    [[MRRouter sharedInstance].routes removeObjectForKey:URLPattern];
}

+ (BOOL)canOpenURL:(NSString *)URLPattern {
    if (!URLPattern.length) {
        return NO;
    }
    NSMutableDictionary<NSString *, _MRRoute *> *routes = [MRRouter sharedInstance].routes;
    NSURL* URL = [NSURL URLWithString:URLPattern];
    _MRRoute* route = routes[URL.mr_body] ? : routes[URL.mr_fullScheme];
    if (!route) {
        NSString *className = [[MRRouter sharedInstance] assembledClassNameWithString:URL.host];
        Class classType = [[MRRouter sharedInstance] matchObjectByName:className];
        return classType != Nil;
    } else {
        return YES;
    }
}

+ (void)map:(NSString *)URLPattern toClassName:(NSString *)name {
    _MRRoute* route = [_MRRoute routeWithURL:URLPattern];
    route.className = name;
    [[MRRouter sharedInstance].routes setObject:route forKey:[NSURL URLWithString:URLPattern].mr_body];
}

- (void)setMapFileName:(NSString *)mapFileName {
    NSString *plistPath;
    if (mapFileName.pathExtension.length == 0) {
        plistPath = [[NSBundle mainBundle] pathForResource:mapFileName ofType:@"plist"];
    } else {
        plistPath = [[NSBundle mainBundle] pathForResource:[mapFileName substringToIndex:[mapFileName rangeOfString:@"."].location] ofType:mapFileName.pathExtension];
    }
    if (plistPath.length) {
        self.plistMapDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    }
}

- (void)setPlistMapDictionary:(NSMutableDictionary<NSString *, NSString *> *)plistMapDictionary {
    //remove the routes in memeory
    [_plistMapDictionary enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSString*  _Nonnull obj, BOOL * _Nonnull stop) {
        [_routes removeObjectForKey:key];
    }];
    
    _plistMapDictionary = plistMapDictionary;
    [_plistMapDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        _MRRoute* route = [_MRRoute routeWithURL:key];
        route.className = obj;
        [[MRRouter sharedInstance].routes setObject:route forKey:key];
    }];
}

- (void)setRegisterMapDictionary:(NSMutableDictionary *)registerMapDictionary {
    
}

- (void)executeDefaultBlock:(_MRRoute *)route prepareBlock:(MRPrepareBlock)prepareBlock completeBlock:(MRCompleteBlock)completeBlock {
    NSObject *object = [self objectWithName:route.className parameters:route.parameters];
    object.mr_parameters = route.parameters;
    [object parseParameters];
    if (prepareBlock) {
        prepareBlock(object);
    }
    if (self.defaultExecutingBlock) {
        self.defaultExecutingBlock(object, route.parameters);
    }
    if (completeBlock) {
        completeBlock(object);
    }
}

- (NSObject *)objectWithName:(NSString *)name parameters:(NSDictionary *)parameters {
    Class objetClass = [self matchObjectByName:name];
    if (objetClass) {
        id object = [[objetClass alloc] init];
        [object setValue:parameters forKey:@"mr_parameters"];
        return object;
    }
    return nil;
}

- (NSString *) assembledClassNameWithString:(NSString *)string {
    NSAssert(string, @"Illegal url pattern!");
    return [NSString stringWithFormat:@"%@%@%@", _prefix?:@"", string.capitalizedString, _postfix?:@""];
}

- (void)setDefaultClassType:(Class)defaultClassType
{
    _defaultClassType = defaultClassType;
    _defaultSubClasses = [defaultClassType subClasses];
}

@end

@implementation NSObject (MRParameters)

- (void)setMr_parameters:(NSDictionary *)mr_parameters {
    objc_setAssociatedObject(self, @selector(mr_parameters), mr_parameters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)mr_parameters {
    return objc_getAssociatedObject(self, _cmd);
}

@end
