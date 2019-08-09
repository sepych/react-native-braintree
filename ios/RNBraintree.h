
/*#if __has_include("RCTBridge.h")
#import "RCTBridge.h"
#else
#import <React/RCTBridge.h>
#endif*/

#import "RCTRootView.h"

#import "BraintreePaymentFlow.h"

@interface RNBraintree : NSObject <RCTBridgeModule, BTViewControllerPresentingDelegate, BTThreeDSecureRequestDelegate>

@property (nonatomic, strong, readwrite) BTPaymentFlowDriver *paymentFlowDriver;

@end
