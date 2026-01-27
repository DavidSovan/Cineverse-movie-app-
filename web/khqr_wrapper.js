// khqr_wrapper.js - Wrapper for BakongKHQR JavaScript SDK
(function () {
  "use strict";

  function checkKHQR() {
    if (typeof BakongKHQR === "undefined") {
      throw new Error("BakongKHQR SDK not loaded. Include khqr script first.");
    }
  }

  window.flutterBakongKHQR = {
    generateIndividual: function (info) {
      return new Promise(function (resolve, reject) {
        try {
          checkKHQR();
          var sdk = BakongKHQR;
          var khqr = new sdk.BakongKHQR();
          var khqrData = sdk.khqrData;

          var currencyStr = (info.currency || "USD").toUpperCase();
          var currency =
            currencyStr === "KHR"
              ? khqrData.currency.khr
              : khqrData.currency.usd;

          var optionalData = {
            currency: currency,
            amount: info.amount || 0,
            billNumber: info.billNumber || "",
            mobileNumber: info.mobileNumber || "",
            storeLabel: info.storeLabel || "",
            terminalLabel: info.terminalLabel || "",
            purposeOfTransaction: info.purposeOfTransaction || "",
            merchantCategoryCode: info.merchantCategoryCode || "5999",
          };

          if (info.expirationTimestamp) {
            optionalData.expirationTimestamp = info.expirationTimestamp;
          } else if (info.amount && info.amount > 0) {
            optionalData.expirationTimestamp = Date.now() + 5 * 60 * 1000;
          }

          var individualInfo = new sdk.IndividualInfo(
            info.bakongAccountId || info.accountId || "",
            info.merchantName || "",
            info.merchantCity || "Phnom Penh",
            optionalData
          );

          var response = khqr.generateIndividual(individualInfo);
          if (response && response.data) {
            resolve({
              qr: response.data.qr || "",
              md5: response.data.md5 || "",
            });
          } else {
            reject(new Error("Failed to generate KHQR"));
          }
        } catch (e) {
          reject(e);
        }
      });
    },

    generateMerchant: function (info) {
      return new Promise(function (resolve, reject) {
        try {
          checkKHQR();
          var sdk = BakongKHQR;
          var khqr = new sdk.BakongKHQR();
          var khqrData = sdk.khqrData;

          var currencyStr = (info.currency || "USD").toUpperCase();
          var currency =
            currencyStr === "KHR"
              ? khqrData.currency.khr
              : khqrData.currency.usd;

          var optionalData = {
            currency: currency,
            amount: info.amount || 0,
            billNumber: info.billNumber || "",
            mobileNumber: info.mobileNumber || "",
            storeLabel: info.storeLabel || "",
            terminalLabel: info.terminalLabel || "",
            purposeOfTransaction: info.purposeOfTransaction || "",
            merchantCategoryCode: info.merchantCategoryCode || "5999",
          };

          if (info.expirationTimestamp) {
            optionalData.expirationTimestamp = info.expirationTimestamp;
          } else if (info.amount && info.amount > 0) {
            optionalData.expirationTimestamp = Date.now() + 5 * 60 * 1000;
          }

          var merchantInfo = new sdk.MerchantInfo(
            info.bakongAccountId || info.accountId || "",
            info.merchantName || "",
            info.merchantCity || "Phnom Penh",
            info.merchantId || "",
            info.acquiringBank || "",
            optionalData
          );

          var response = khqr.generateMerchant(merchantInfo);
          if (response && response.data) {
            resolve({
              qr: response.data.qr || "",
              md5: response.data.md5 || "",
            });
          } else {
            reject(new Error("Failed to generate KHQR"));
          }
        } catch (e) {
          reject(e);
        }
      });
    },
  };

  console.log("flutterBakongKHQR wrapper loaded");
})();