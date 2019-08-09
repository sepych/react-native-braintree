@import UIKit;
#import "RNBraintree.h"
#import "BraintreeCore.h"
#import "BraintreeDropIn.h"
#import <React/RCTBridge.h>

@implementation RNBraintree () <BTViewControllerPresentingDelegate, BTThreeDSecureRequestDelegate>

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
    //RCTLogInfo(@"RNBraintree in showDropIn, token:  %@", clientTokenOrTokenizationKey);
    UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    BTDropInRequest *request = [[BTDropInRequest alloc] init];

    BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:token request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
        [viewController dismissViewControllerAnimated:YES completion:nil];
        //NSLog(@"RNBraintree.. @",result.paymentMethod.nonce);

        if (error != nil) {
            NSLog(@"ERROR");
            reject(@"ERROR", @"Braintree Dropin error", error);
        } else if (result.cancelled) {
            NSLog(@"CANCELLED");
            reject(@"CANCELLED", @"Braintree Dropin canceled", nil);
        } else {
            //resolve(result.paymentMethod.nonce);

            self.paymentFlowDriver = [[BTPaymentFlowDriver alloc] initWithAPIClient:token];
            self.paymentFlowDriver.viewControllerPresentingDelegate = self;

            BTThreeDSecureRequest *request = [[BTThreeDSecureRequest alloc] init];
            request.amount = [NSDecimalNumber decimalNumberWithString:@"1"];
            request.nonce = result.paymentMethod.nonce;
            request.email = @"test@email.com";
            request.versionRequested = BTThreeDSecureVersion2;

            // Make sure that self conforms BTThreeDSecureRequestDelegate
            request.threeDSecureRequestDelegate = self;

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
            request.billingAddress = address;


            [self.paymentFlowDriver startPaymentFlow:request completion:^(BTPaymentFlowResult * _Nonnull result, NSError * _Nonnull error) {
                if (error) {
                    // Handle error
                } else if (result) {
                    BTThreeDSecureResult *threeDSecureResult = (BTThreeDSecureResult *)result;

                    if (threeDSecureResult.tokenizedCard.threeDSecureInfo.liabilityShiftPossible) {
                        if (threeDSecureResult.tokenizedCard.threeDSecureInfo.liabilityShifted) {
                            // 3D Secure authentication success
                        } else {
                            // 3D Secure authentication failed
                        }
                    } else {
                        // 3D Secure authentication was not possible
                    }

                    resolve(threeDSecureResult.tokenizedCard.nonce);
                    // Use the `threeDSecureResult.tokenizedCard.nonce`
                }
            }];




            // Use the BTDropInResult properties to update your UI
            // result.paymentOptionType
            // result.paymentMethod
            // result.paymentIcon
            // result.paymentDescription
        }
    }];

    [viewController presentViewController:dropIn animated:YES completion:^{}];
}


- (void)paymentDriver:(id)driver requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentDriver:(id)driver requestsDismissalOfViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)onLookupComplete:(nonnull BTThreeDSecureRequest *)request
                  result:(nonnull BTThreeDSecureLookup *)result
                    next:(nonnull void (^)(void))next {
    [next];                  
}

@end
