//
//  ViewController.m
//  YWCLocalizeTool
//
//  Created by YangWeicheng on 8/29/16.
//  Copyright © 2016 YangWeicheng. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import <CommonCrypto/CommonDigest.h>

@implementation ViewController

- (IBAction)translate:(id)sender {
    
    NSMutableString *mutableContent = [NSMutableString stringWithString:self.inputTextView.textStorage.string];
    
    NSUInteger startLocation = 0;
    NSMutableArray <NSString *>*needTranslateStringArray = [NSMutableArray array];
    while (1) {
        NSRange backRange = [mutableContent rangeOfString:@"\";" options:0 range:NSMakeRange(startLocation, mutableContent.length - startLocation)];
        if (backRange.location == NSNotFound) {
            break;
        }
        startLocation += (backRange.location - startLocation);
        startLocation += 2;
        
        NSRange frontRange = [mutableContent rangeOfString:@"\"" options:NSBackwardsSearch range:NSMakeRange(0, backRange.location-1)];
        NSRange needTranslationRange = NSMakeRange(frontRange.location+1, backRange.location - (frontRange.location + 1));
        NSString *needTranlationString = [mutableContent substringWithRange:needTranslationRange];
        [needTranslateStringArray addObject:needTranlationString];
    }
    
    NSMutableArray <NSDictionary *>*responses = [NSMutableArray array];
    for (int i = 0; i < needTranslateStringArray.count; i++) {
        [responses addObject:@{}];
    }
    __block int factualResponsesCount = 0;
    int tag = 0;
    for (NSString *needTranslate in needTranslateStringArray) {
        NSNumber *appID = @20160825000027431;
        NSString *secret = @"Mi_MQ_2JaIDO4MpX37YU";
        NSNumber *salt = [NSNumber numberWithInteger:arc4random()%10000];
        NSString *q = needTranslate;
        NSString *signBeforeMD5 = [NSString stringWithFormat:@"%@%@%@%@",appID,q,salt,secret];
        ;
        NSString *sign = [self getmd5WithString:signBeforeMD5];
        NSDictionary *parameters = @{
                                     @"q":q,
                                     @"from":self.sourceLanguage.stringValue,
                                     @"to":self.destinationLanguage.stringValue,
                                     @"appid":appID,
                                     @"salt":salt,
                                     @"sign":sign
                                     };
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:@"http://api.fanyi.baidu.com/api/trans/vip/translate" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
            if (responseObject[@"error_code"]) {
                NSLog(@"error -> %@", responseObject);
                return;
            }
            [responses replaceObjectAtIndex:tag withObject:responseObject];
            factualResponsesCount++;
            if (factualResponsesCount == needTranslateStringArray.count) {
                [self replaceOriginalString:mutableContent withResponses:responses];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error-> %@",error);
        }];
        tag++;
    }
}

- (void)replaceOriginalString:(NSMutableString *)string withResponses:(NSMutableArray <NSDictionary *>*)responses
{
    NSUInteger startLocation = 0;
    NSMutableString *mutableContent = string;
    int i = 0;
    while (1) {
        NSRange backRange = [mutableContent rangeOfString:@"\";" options:0 range:NSMakeRange(startLocation, mutableContent.length - startLocation)];
        if (backRange.location == NSNotFound) {
            break;
        }
        startLocation += (backRange.location - startLocation);
        startLocation += 2;
        NSRange frontRange = [mutableContent rangeOfString:@"\"" options:NSBackwardsSearch range:NSMakeRange(0, backRange.location-1)];
        NSRange needTranslationRange = NSMakeRange(frontRange.location+1, backRange.location - (frontRange.location + 1));
        NSString *afterTranslationString = responses[i][@"trans_result"][0][@"dst"];
        [mutableContent replaceCharactersInRange:needTranslationRange withString:afterTranslationString];
        startLocation = (startLocation - needTranslationRange.length + afterTranslationString.length);
        i++;
    }
    [self.outputTextView setString:mutableContent];
}

- (NSString*)getmd5WithString:(NSString *)string
{
    const char* original_str=[string UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    CC_MD5(original_str, (uint)strlen(original_str), digist);
    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [outPutStr appendFormat:@"%02x", digist[i]];//小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
    }
    return [outPutStr lowercaseString];
}

@end
