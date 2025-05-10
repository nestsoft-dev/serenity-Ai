import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

import 'package:in_app_purchase/in_app_purchase.dart';

class BillingService {
  BillingService._();
  //    static BillingService get instance => _instance;
  //   static final BillingService _instance = BillingService._();

  //   final InAppPurchase _iap = InAppPurchase.instance;

  //    Future<void> initialize() async {
  //      if(!(await _iap.isAvailable())) return;
  //      if (Platform.isIOS) {
  //        final iosPlatformAddition = _iap
  //           .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
  //        await iosPlatformAddition.setDelegate(PaymentQueueDelegate()!);
  //      }
  //    }

  //    Future<void> dispose() async {
  //      if (Platform.isIOS) {
  //        final iosPlatformAddition = _inAppPurchase
  //            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
  //        await iosPlatformAddition.setDelegate(null);
  //      }
  //    }

  //    Future<List<ProductDetails>> fetchProducts(List<String> productIds) async {
  //  Set<String> ids = Set.from(productIds);
  //  List<ProductDetails> =[
  //   PurchaseDetails(productID: productID, verificationData: verificationData, transactionDate: transactionDate, status: status)
  //  ];

  //    ProductDetailsResponse response =
  //        await _iap.queryProductDetails(ids);

  //    if (response.notFoundIDs.isNotEmpty) {
  //      // Handle not found product IDs
  //    }

  //    return response.productDetails;
  //  }
}
