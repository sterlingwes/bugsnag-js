#import "NativeStackUnhandledScenario.h"

@implementation NativeStackUnhandledScenario

- (void)run: (RCTPromiseResolveBlock)resolve
     reject:(RCTPromiseRejectBlock)reject {
  NSLog(@"%s", __PRETTY_FUNCTION__);
  reject(@"NativeError", @"NativeStackUnhandledScenario", [NSError errorWithDomain:@"com.example" code:408 userInfo:nil]);
}

@end
