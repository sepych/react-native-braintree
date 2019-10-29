
package com.reactbraintree;

import android.app.Activity;
import android.content.Intent;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.braintreepayments.api.BraintreeFragment;
import com.braintreepayments.api.ThreeDSecure;
import com.braintreepayments.api.dropin.DropInActivity;
import com.braintreepayments.api.dropin.DropInRequest;
import com.braintreepayments.api.dropin.DropInResult;
import com.braintreepayments.api.exceptions.InvalidArgumentException;
import com.braintreepayments.api.interfaces.BraintreeCancelListener;
import com.braintreepayments.api.interfaces.BraintreeErrorListener;
import com.braintreepayments.api.interfaces.BraintreePaymentResultListener;
import com.braintreepayments.api.interfaces.PaymentMethodNonceCreatedListener;
import com.braintreepayments.api.interfaces.ThreeDSecureLookupListener;
import com.braintreepayments.api.models.BraintreePaymentResult;
import com.braintreepayments.api.models.CardNonce;
import com.braintreepayments.api.models.PaymentMethodNonce;
import com.braintreepayments.api.models.ThreeDSecureLookup;
import com.braintreepayments.api.models.ThreeDSecurePostalAddress;
import com.braintreepayments.api.models.ThreeDSecureRequest;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;

public class RNBraintreeModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  private Callback successCallback;
  private Callback cancelCallback;

  private Promise braintreePromise = null;

  private static final int REQUEST_CODE = 1;
  private static final String CANCELED = "CANCELED";
  private static final String ERROR = "ERROR";
  private String token;
  private BraintreeFragment mBraintreeFragment;
  private String givenName;
  private String surname;
  private String phoneNumber;
  private String streetAddress;
  private String extendedAddress;
  private String locality;
  private String region;
  private String postalCode;
  private String countryCodeAlpha2;

  public RNBraintreeModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    reactContext.addActivityEventListener(new BraintreeActivityListener());
  }

  @Override
  public String getName() {
    return "RNBraintree";
  }

  public String getToken() {
    return token;
  }

  public void setToken(String token) {
    this.token = token;
  }

  @ReactMethod
  public void init(String token) {
    this.setToken(token);
  }

  @ReactMethod
  public void setBillingAddress(ReadableMap data) {
    this.givenName = data.hasKey("firstName") ? data.getString("firstName") : null;
    this.surname = data.hasKey("lastName") ? data.getString("lastName") : null;
    this.phoneNumber = data.hasKey("phoneNumber") ? data.getString("phoneNumber") : null;
    this.streetAddress = data.hasKey("streetAddress") ? data.getString("streetAddress") : null;
    this.extendedAddress = data.hasKey("extendedAddress") ? data.getString("extendedAddress") : null;
    this.locality = data.hasKey("locality") ? data.getString("locality") : null;
    this.region = data.hasKey("region") ? data.getString("region") : null;
    this.postalCode = data.hasKey("postalCode") ? data.getString("postalCode") : null;
    this.countryCodeAlpha2 = data.hasKey("countryCodeAlpha2") ? data.getString("countryCodeAlpha2") : null;
  }

  @ReactMethod
  public void showDropIn(final Promise promise) {
    this.braintreePromise = promise;

    if (this.getToken() == null) {
      promise.reject(ERROR, "You must call init method first!");
    } else {
      //dropin doesn't support 3DS2 yet
      DropInRequest dropInRequest = new DropInRequest()
      .clientToken(this.getToken());

      //.amount("1.00")
      //.requestThreeDSecureVerification(true)

      getCurrentActivity()
        .startActivityForResult(
          dropInRequest.getIntent(getCurrentActivity()), REQUEST_CODE);
    }
  }

  private class BraintreeActivityListener extends BaseActivityEventListener {
    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
      if (requestCode == REQUEST_CODE) {
        if (resultCode == Activity.RESULT_OK) {
          DropInResult result = data.getParcelableExtra(DropInResult.EXTRA_DROP_IN_RESULT);

          //disable 3DS2
          braintreePromise.resolve(result.getPaymentMethodNonce().getNonce());
          /*
          try {
            mBraintreeFragment = BraintreeFragment.newInstance(
                    (AppCompatActivity) activity, getToken());
            mBraintreeFragment.addListener(new BraintreeCancelListener() {
              @Override
              public void onCancel(int requestCode) {
                if (braintreePromise != null) {
                  braintreePromise.reject(CANCELED, "Drop In was canceled.");
                }
              }
            });
            mBraintreeFragment.addListener(new BraintreeErrorListener() {
              @Override
              public void onError(Exception error) {
                if (braintreePromise != null) {
                  braintreePromise.reject(ERROR, error.getMessage());
                }

              }
            });
            mBraintreeFragment.addListener(new PaymentMethodNonceCreatedListener() {
              @Override
              public void onPaymentMethodNonceCreated(PaymentMethodNonce paymentMethodNonce) {
                if (braintreePromise != null) {
                  braintreePromise.resolve(paymentMethodNonce.getNonce());
                }
              }
            });
          } catch (InvalidArgumentException e) {
            e.printStackTrace();
          }

          ThreeDSecureRequest threeDSecureRequest = new ThreeDSecureRequest()
              .nonce(nonce)
              .amount("5.00");
          ThreeDSecure.performVerification(mBraintreeFragment, threeDSecureRequest);

          // Card nonce that we wish to upgrade to a 3DS nonce.
          CardNonce cardNonce = (CardNonce) result.getPaymentMethodNonce();

          ThreeDSecurePostalAddress address = new ThreeDSecurePostalAddress()
              .givenName(givenName)
              .surname(surname)
              .phoneNumber(phoneNumber)
              .streetAddress(streetAddress)
              .extendedAddress(extendedAddress)
              .locality(locality)
              .region(region)
              .postalCode(postalCode)
              .countryCodeAlpha2(countryCodeAlpha2);

          ThreeDSecureRequest threeDSecureRequest = new ThreeDSecureRequest()
              .amount("1")
              .billingAddress(address)
              .nonce(cardNonce.getNonce())
              .versionRequested(ThreeDSecureRequest.VERSION_2);


          ThreeDSecure.performVerification(mBraintreeFragment, threeDSecureRequest, new ThreeDSecureLookupListener() {
              @Override
              public void onLookupComplete(ThreeDSecureRequest request, ThreeDSecureLookup lookup) {
                  // Optionally inspect the lookup result and prepare UI if a challenge is required
                  ThreeDSecure.continuePerformVerification(mBraintreeFragment, request, lookup);
              }
          });

          // use the result to update your UI and send the payment method nonce to your server
          */
        } else if (resultCode == Activity.RESULT_CANCELED) {
          // the user canceled
          braintreePromise.reject(CANCELED, "Drop In was canceled. 1");
        } else {
          // handle errors here, an exception may be available in
          Exception error = (Exception) data.getSerializableExtra(DropInActivity.EXTRA_ERROR);
          braintreePromise.reject(ERROR, error.getMessage());
        }
      }
    }
  }

}
