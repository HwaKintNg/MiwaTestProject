//
//  Alv2BLEModule.m
//  GentingApp
//
//  Created by Beans Group on 27/09/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_REMAP_MODULE(ALV2BLE, Alv2BLEModule, NSObject)
RCT_EXTERN_METHOD(startMiwa:(NSString *)serial)
RCT_EXTERN_METHOD(stopMiwa)
RCT_EXTERN_METHOD(delSelectedKey:(NSInteger *)roomNo resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(delAllKey:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(addKey:(NSString *)keyData1 keyData2:(NSString *)keyData2 keyData3:(NSString *)keyData3 keyName:(NSString *)keyName roomNo:(NSInteger *)roomNo ci:(NSString *)ci co:(NSString *)co resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(loadKeyData:(NSString *)keyName roomNo:(NSInteger *)roomNo resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(openLocationSetting:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(startRecv:(NSString *)etRoom resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(startAuth:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
@end
