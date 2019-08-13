@import UIKit;
#import "RNBraintree.h"
#import "BraintreeCore.h"
#import "BraintreeDropIn.h"
#import <React/RCTBridge.h>





@implementation RNBraintree



static NSString* token;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

-(RCTBridge*) getBridge {
    static dispatch_once_t once;
    static id bridge;
    dispatch_once(&once, ^{
        NSURL *jsCodeLocation;
#if DEBUG
        jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios&dev=true"];
#else
        jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
        bridge = [
                  [RCTBridge alloc] initWithBundleURL:jsCodeLocation
                  moduleProvider:nil
                  launchOptions:nil
                  ];
    });
    return bridge;
}

RCT_EXPORT_METHOD(init: (NSString *) ttoken)
{
    token = ttoken;
}

RCT_REMAP_METHOD(showDropIn, resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];

    BTThreeDSecureRequest *secureRequest = [[BTThreeDSecureRequest alloc] init];
    secureRequest.amount = [NSDecimalNumber decimalNumberWithString:@"1"];
//    secureRequest.nonce = result.paymentMethod.nonce;
    secureRequest.email = @"evgeni.gordejev@gmail.com";
    secureRequest.versionRequested = BTThreeDSecureVersion2;

    // Make sure that self conforms BTThreeDSecureRequestDelegate
    secureRequest.threeDSecureRequestDelegate = self;

    BTThreeDSecurePostalAddress *address = [BTThreeDSecurePostalAddress new];
    address.givenName = @"Jill";
    address.surname = @"Doe";
    address.phoneNumber = @"5551234567";
    address.streetAddress = @"555 Smith St";
    address.extendedAddress = @"#2";
    address.locality = @"Chicago";
    address.region = @"IL";
    address.postalCode = @"12345";
    address.countryCodeAlpha2 = @"US";
    secureRequest.billingAddress = address;

    //RCTLogInfo(@"RNBraintree in showDropIn, token:  %@", clientTokenOrTokenizationKey);

    BTDropInRequest *request = [[BTDropInRequest alloc] init];
    request.amount = @"1.00";
    request.threeDSecureVerification = YES;
    request.threeDSecureRequest = secureRequest;

    NSLog(@"DROP IN");

    BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:token request:request handler:^(BTDropInController * _Nonnull dropInController, BTDropInResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR");
            reject(@"ERROR", @"Braintree Dropin error", error);
        } else if (result.isCancelled) {
            NSLog(@"CANCELLED");
            reject(@"CANCELLED", @"Braintree Dropin canceled", nil);
        } else {
            NSLog(@"SUCCESS");
            resolve(result.paymentMethod.nonce);
        }
        [dropInController dismissViewControllerAnimated:YES completion:nil];
    }];

//    BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:token request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
//        [viewController dismissViewControllerAnimated:YES completion:nil];
//        //NSLog(@"RNBraintree.. @",result.paymentMethod.nonce);
//
//        if (error != nil) {
//            NSLog(@"ERROR");
//            reject(@"ERROR", @"Braintree Dropin error", error);
//        } else if (result.cancelled) {
//            NSLog(@"CANCELLED");
//            reject(@"CANCELLED", @"Braintree Dropin canceled", nil);
//        } else {
////            resolve(result.paymentMethod.nonce);
//
//
//             BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:token];
//             self.paymentFlowDriver = [[BTPaymentFlowDriver alloc] initWithAPIClient:apiClient];
//             self.paymentFlowDriver.viewControllerPresentingDelegate = self;
//
//
//
//
//             [self.paymentFlowDriver startPaymentFlow:secureRequest completion:^(BTPaymentFlowResult * _Nonnull result, NSError * _Nonnull error) {
//                 if (error) {
//                     // Handle error
//                     NSLog(@"ERROR");
//                     reject(@"ERROR", @"Braintree Dropin error", error);
//                 } else if (result) {
//                     BTThreeDSecureResult *threeDSecureResult = (BTThreeDSecureResult *)result;
//
//                     if (threeDSecureResult.tokenizedCard.threeDSecureInfo.liabilityShiftPossible) {
//                         if (threeDSecureResult.tokenizedCard.threeDSecureInfo.liabilityShifted) {
//                             // 3D Secure authentication success
//                         } else {
//                             // 3D Secure authentication failed
//                         }
//                     } else {
//                         // 3D Secure authentication was not possible
//                     }
//
//                     resolve(threeDSecureResult.tokenizedCard.nonce);
//                     // Use the `threeDSecureResult.tokenizedCard.nonce`
//                 }
//             }];
//
//
//
//
//            // Use the BTDropInResult properties to update your UI
//            // result.paymentOptionType
//            // result.paymentMethod
//            // result.paymentIcon
//            // result.paymentDescription
//        }
//    }];

    [viewController presentViewController:dropIn animated:YES completion:^{}];
}


- (void)paymentDriver:(id)driver requestsPresentationOfViewController:(UIViewController *)viewController {
    [viewController presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentDriver:(id)driver requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)onLookupComplete:(BTThreeDSecureRequest *)request
                  result:(BTThreeDSecureLookup *)result
                    next:(void (^)(void))next {
    next;
}

@end
