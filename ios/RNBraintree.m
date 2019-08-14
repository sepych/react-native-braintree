@import UIKit;
#import "RNBraintree.h"
#import "BraintreeCore.h"
#import "BraintreeDropIn.h"
#import <React/RCTBridge.h>





@implementation RNBraintree



static NSString* token;
static NSString* givenName;
static NSString* surname;
static NSString* phoneNumber;
static NSString* streetAddress;
static NSString* extendedAddress;
static NSString* locality;
static NSString* region;
static NSString* postalCode;
static NSString* countryCodeAlpha2;

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

RCT_EXPORT_METHOD(setBillingAddress: (NSDictionary *)data)
{
    givenName = [data objectForKey:@"firstName"] ? data[@"firstName"] : NULL;
    surname = [data objectForKey:@"lastName"] ? data[@"lastName"] : NULL;
    phoneNumber = [data objectForKey:@"phoneNumber"] ? data[@"phoneNumber"] : NULL;
    streetAddress = [data objectForKey:@"streetAddress"] ? data[@"streetAddress"] : NULL;
    extendedAddress = [data objectForKey:@"extendedAddress"] ? data[@"extendedAddress"] : NULL;
    locality = [data objectForKey:@"locality"] ? data[@"locality"] : NULL;
    region = [data objectForKey:@"region"] ? data[@"region"] : NULL;
    postalCode = [data objectForKey:@"postalCode"] ? data[@"postalCode"] : NULL;
    countryCodeAlpha2 = [data objectForKey:@"countryCodeAlpha2"] ? data[@"countryCodeAlpha2"] : NULL;
}

RCT_REMAP_METHOD(showDropIn, resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];

    BTThreeDSecureRequest *secureRequest = [[BTThreeDSecureRequest alloc] init];
    secureRequest.amount = [NSDecimalNumber decimalNumberWithString:@"1"];
    // secureRequest.email = @"";
    secureRequest.versionRequested = BTThreeDSecureVersion2;

    // Make sure that self conforms BTThreeDSecureRequestDelegate
    secureRequest.threeDSecureRequestDelegate = self;

    BTThreeDSecurePostalAddress *address = [BTThreeDSecurePostalAddress new];
    address.givenName = givenName;
    address.surname = surname;
    address.phoneNumber = phoneNumber;
    address.streetAddress = streetAddress;
    address.extendedAddress = extendedAddress;
    address.locality = locality;
    address.region = region;
    address.postalCode = postalCode;
    address.countryCodeAlpha2 = countryCodeAlpha2;
    secureRequest.billingAddress = address;

    //RCTLogInfo(@"RNBraintree in showDropIn, token:  %@", clientTokenOrTokenizationKey);

    BTDropInRequest *request = [[BTDropInRequest alloc] init];
    request.amount = @"1.00";
    request.threeDSecureVerification = YES;
    request.threeDSecureRequest = secureRequest;

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
