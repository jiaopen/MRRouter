//
//  MRRouter.h
//  MRRouter
//
//  Created by 苏合 on 15/12/31.
//  Copyright © 2015年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MRPrepareBlock)(id object);
typedef void (^MRCompleteBlock)();
typedef id (^MRExecutingBlock)(NSString *sourceURL, NSDictionary *parameters);
typedef void (^MRDefaultExecutingBlock)(id object, NSDictionary *parameters);

@interface MRRouter : NSObject

+ (MRRouter *)sharedInstance;

+ (void)openURL:(NSString *)URLPattern;

+ (void)openURL:(NSString *)URLPattern parameters:(NSDictionary *)parameters;

/**
 *  Asks the router to execute some operations by a URL.
 *
 *  @param URLPattern    Some operations representing a URL.
 *  @param parameters    Information about the the URL. May be nil.
 *  @param prepareBlock  A block object containing the operation before open URL. May be nil.
 *  @param completeBlock A block object containing the operation after open URL. May be nil.
 */
+ (void)openURL:(NSString *)URLPattern parameters:(NSDictionary *)parameters prepareBlock:(MRPrepareBlock)prepareBlock completeBlock:(MRCompleteBlock)completeBlock;

/**
 *  Return the object which match the URL.
 *
 *  @param URLPattern Asks the router to get an object.
 *
 *  @return The object which match the URL. May be nil;
 */
+ (Class)matchClassWithURL:(NSString *)URLPattern;

/**
 *  Return the object which is alloc elsewhere by the URL.
 *
 *  @param URLPattern Asks the router to get an object.
 *
 *  @return The object which is alloced elsewhere, if it is not exist, return nil;
 */
+ (id)existedInstanceWithURL:(NSString *)URLPattern;


/**
 *  Register some operations with URL.
 *
 *  @param URLPattern     Some operations representing a URL. If URLPattern already exists in the router, executingBlock takes its place.
 *  @param executingBlock A block object containing the operation representing the URL.
 */
+ (void)registerURL:(NSString *)URLPattern executingBlock:(MRExecutingBlock)executingBlock;

/**
 *  Map the URL to class name.
 *
 *  @param URLPattern URL mapped with class name. If URLPattern already exists in the router, name takes its place.
 *  @param name       Class name mapped with URL.
 */
+ (void)map:(NSString *)URLPattern toClassName:(NSString *)name;

/**
 *  Remove the URL from router.
 *
 *  @param URLPattern Some operations representing a URL.
 */
+ (void)removeURL:(NSString *)URLPattern;

/**
 *  Returns a Boolean value indicating whether the URL can be routed.
 *
 *  @param URLPattern URL will be routed.
 */
+ (BOOL)canOpenURL:(NSString *)URLPattern;

/**
 *  Load the Class-URL map when setting this property.
 */
@property (nonatomic, strong) NSString *mapFileName;

/**
 *  You could set the default execute block of router by yourself. If you register the URL with a executingBlock(see registerURL:URLPattern:executingBlock), defaultExecutingBlock will never be executed.
 */
@property (nonatomic, copy) MRDefaultExecutingBlock defaultExecutingBlock;

/**
 *  Prefix of class name which initialize in runtime.
 */
@property (nonatomic, copy) NSString * prefix;

/**
 *  Postfix of class name which initialize in runtime.
 */
@property (nonatomic, copy) NSString * postfix;

/**
 *  The super class type of router load with runtime.
 */
@property (nonatomic, assign) Class defaultClassType;

@end

@interface NSObject (MRParameters)

@property (nonatomic, copy) NSDictionary *mr_parameters;

@end