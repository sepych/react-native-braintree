import { NativeModules } from 'react-native';

const { RNBraintree } = NativeModules;


class Braintree {

  constructor() {
    if (__DEV__ && !RNBraintree) {
      console.error(
        'RN Braintree native module is not correctly linked.'
      );
    }
  }

  replaceSpecialCharacters(str) {
    str = str.replace(/ä/g, "a");
    str = str.replace(/ö/g, "o");
    str = str.replace(/Ä/g, "A");
    str = str.replace(/Ö/g, "O");
    str = str.replace(/å/g, "a");
    str = str.replace(/Å/g, "A");
    return str;
  }

  async init(token) {
    return await RNBraintree.init(token);
  }



  async setBillingAddress(data) {
    if (data.firstName !== undefined) {
      data.firstName = this.replaceSpecialCharacters(data.firstName);
    }

    if (data.lastName !== undefined) {
      data.lastName = this.replaceSpecialCharacters(data.lastName);
    }
    return await RNBraintree.setBillingAddress(data);
  }

  async showDropIn() {
    return await RNBraintree.showDropIn();
  }
}

export const BraintreeSingleton = new Braintree();

