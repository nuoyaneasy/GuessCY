//
//  Question.h
//  超级猜图
//
//  Created by Yang Chao on 6/27/15.
//  Copyright (c) 2015 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Question : NSObject

@property (copy, nonatomic) NSString *answer;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *options;

-(instancetype)initWithDictionary:(NSDictionary *)dict;
+(instancetype)questionWithDictionary:(NSDictionary *)dict;
/**
 *  返回所有题目数组
 *
 *  @return <#return value description#>
 */
+ (NSArray *)quesitons;
/**
 *  打断备选文字的数组
 *
 *  @return <#return value description#>
 */
- (void)randomOptions;
@end
