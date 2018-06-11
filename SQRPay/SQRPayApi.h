//
//  SQRPayApi.h
//  CommunityPeople
//
//  Created by macMini on 2018/6/4.
//  Copyright © 2018年 PR. All rights reserved.
//

#import <Foundation/Foundation.h>

//支付方式
typedef NS_ENUM(NSInteger, PayTypeEnum) {
    
    PayTypeEnumDefault = 0, //默认，微信支付
    PayTypeEnumWeChat,      //微信支付
    PayTypeEnumAliPay       //支付宝支付
    
};


//支付回调结果
typedef NS_ENUM(NSInteger, PayReturnEnum) {
    
    PayReturnEnumWechatSucceed      = 1001,  //微信支付成功
    PayReturnEnumWechatError        = 1002,  //微信支付失败
    PayReturnEnumWechatCancel       = 1003,  //微信支付取消
    PayReturnEnumWechatNotInstall   = 1004,  //未安装微信
    PayReturnEnumWechatUNSUPPORT    = 1005,  //微信不支持
    PayReturnEnumWechatNonsupport   = 1006,  //微信支付参数错误
    PayReturnEnumAliPaySucceed      = 1101,  //支付宝支付成功
    PayReturnEnumAliPayError        = 1102,  //支付宝支付失败
    PayReturnEnumAliPayCancel       = 1103,  //支付宝支付取消
    
};

@interface SQRPayApi : NSObject

/**
 *  获取单例
 */
+ (instancetype)sharedInstance;

/**
 *  调起支付
 *
 *  @param payType      支付类型
 *  @param param        支付参数 （微信传后台给的字典，支付宝是订单编码）
 *  @param appScheme    项目名称
 *  @param successBlock 成功
 *  @param failBlock    失败
 */
- (void)SQRPayWithPayType:(PayTypeEnum)payType
                    param:(id)param
                appScheme:(NSString *)appScheme
                  success:(void (^)(PayReturnEnum code))successBlock
                  failure:(void (^)(PayReturnEnum code))failBlock;


/**
 *  回调入口
 *
 *  @param   url
 *  @return  value
 */
- (BOOL)handleOpenURL:(NSURL *)url;

@end
