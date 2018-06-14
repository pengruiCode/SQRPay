//
//  SQRPayApi.m
//  CommunityPeople
//
//  Created by macMini on 2018/6/4.
//  Copyright © 2018年 PR. All rights reserved.
//

#import "SQRPayApi.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>

@interface SQRPayApi () <WXApiDelegate>

@property (nonatomic, copy) void(^PaySuccess)(PayReturnEnum code);
@property (nonatomic, copy) void(^PayError)(PayReturnEnum code);

@end

@implementation SQRPayApi

static id _instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SQRPayApi alloc] init];
    });
    return _instance;
}

- (void)SQRPayWithPayType:(PayTypeEnum)payType
                    param:(id)param
                appScheme:(NSString *)appScheme
                  success:(void (^)(PayReturnEnum code))successBlock
                  failure:(void (^)(PayReturnEnum code))failBlock {
#pragma mark --- 微信支付
    if (payType == PayTypeEnumDefault ||
        payType == PayTypeEnumWeChat) {
        
        self.PaySuccess = successBlock;
        self.PayError = failBlock;

        if(![WXApi isWXAppInstalled]) {
            failBlock(PayReturnEnumWechatNotInstall);
            return ;
        }
        if (![WXApi isWXAppSupportApi]) {
            failBlock(PayReturnEnumWechatNonsupport);
            return ;
        }

        PayReq* req = [[PayReq alloc] init];
        req.partnerId = param[@"partnerid"];            //微信分配的商户号
        req.prepayId  = param[@"prepayid"];             //微信返回的支付交易会话ID
        req.nonceStr  = param[@"nonceStr"];             //随机字符串，不长于32位
        req.timeStamp = [param[@"timeStamp"] intValue]; //时间戳
        req.package   = param[@"package"];              //固定值
        req.sign      = param[@"sign"];                 //签名
        [WXApi sendReq:req];
        
    }else{
        
#pragma mark --- 支付宝支付
        self.PaySuccess = successBlock;
        self.PayError = failBlock;
        
        NSArray *array = [[UIApplication sharedApplication] windows];
        UIWindow* win=[array objectAtIndex:0];
        [win setHidden:NO];
        
        [[AlipaySDK defaultService] payOrder:param fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"----- %@",resultDic);
            NSInteger resultCode = [resultDic[@"resultStatus"] integerValue];
            switch (resultCode) {
                case 9000:     //支付成功
                    successBlock(PayReturnEnumAliPaySucceed);
                    break;
                    
                case 6001:     //支付取消
                    failBlock(PayReturnEnumAliPayCancel);
                    break;
                    
                default:        //支付失败
                    failBlock(PayReturnEnumAliPayError);
                    break;
            }
        }];
    }
}




#pragma mark --- 微信回调
// 微信终端返回给第三方的关于支付结果的结构体
- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayResp class]])
    {
        switch (resp.errCode) {
            case WXSuccess:
                self.PaySuccess(PayReturnEnumWechatSucceed);
                break;
            case WXErrCodeUserCancel:
                self.PayError(PayReturnEnumWechatCancel);
                break;
            default:
                self.PayError(PayReturnEnumWechatError);
                break;
        }
    }
}



///回调处理
- (BOOL)handleOpenURL:(NSURL *)url
{
    if ([url.host isEqualToString:@"safepay"])
    {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            NSLog(@"result = %@",resultDic);
            NSInteger resultCode = [resultDic[@"resultStatus"] integerValue];
            switch (resultCode) {
                case 9000:
                    self.PaySuccess(PayReturnEnumAliPaySucceed);
                    break;
                case 6001:
                    self.PaySuccess(PayReturnEnumAliPayCancel);
                    break;
                default:
                    self.PaySuccess(PayReturnEnumAliPayError);
                    break;
            }
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
        return YES;
    }
    //([url.host isEqualToString:@"pay"]) //微信支付
    return [WXApi handleOpenURL:url delegate:self];
//    return nil;
}


@end
