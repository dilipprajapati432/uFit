// lib/services/payment_service.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';

class PaymentService {
  static Razorpay? _razorpay;
  static Function(String planId)? _onSuccess;
  static Function(String error)? _onFailure;
  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _iapSubscription;

  static const Set<String> _productIds = {
    'ufit_pro_monthly',
    'ufit_pro_yearly',
    'ufit_pro_lifetime',
  };

  static void initRazorpay({
    required Function(String planId) onSuccess,
    required Function(String error) onFailure,
  }) {
    _onSuccess = onSuccess;
    _onFailure = onFailure;
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpaySuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorpayWallet);
  }

  static Future<void> initIAP(WidgetRef ref) async {
    final bool available = await _iap.isAvailable();
    if (!available) return;
    _iapSubscription = _iap.purchaseStream.listen(
      (purchases) => _handleIAPPurchases(purchases, ref),
      onDone: () => _iapSubscription?.cancel(),
      onError: (e) => debugPrint('IAP error: $e'),
    );
  }

  static void disposeRazorpay() {
    _razorpay?.clear();
    _iapSubscription?.cancel();
  }

  // ── Razorpay (Android / India) ────────────────────────────
  static void openRazorpay({
    required SubscriptionPlan plan,
    required String userName,
    required String userEmail,
    String userPhone = '',
  }) {
    final options = {
      // Using the user's provided test key ID
      'key': 'rzp_test_TA3G9a6KQmaPoZ',
      'amount': (plan.priceINR * 100).toInt(),
      'name': 'uFit',
      'description': plan.name,
      'prefill': {'contact': userPhone, 'email': userEmail, 'name': userName},
      'theme': {'color': '#6C63FF'},
      'notes': {'plan_id': plan.id, 'plan_period': plan.period},
      'method': {
        'netbanking': true, 'card': true, 'upi': true,
        'wallet': true, 'emi': plan.priceINR >= 999,
      },
    };
    _razorpay?.open(options);
  }

  static void _handleRazorpaySuccess(PaymentSuccessResponse response) {
    _onSuccess?.call(response.paymentId ?? '');
  }

  static void _handleRazorpayError(PaymentFailureResponse response) {
    _onFailure?.call(response.message ?? 'Payment failed');
  }

  static void _handleRazorpayWallet(ExternalWalletResponse response) {
    debugPrint('External wallet: ${response.walletName}');
  }

  // ── In-App Purchase (iOS / Play Store) ────────────────────
  static Future<List<ProductDetails>> getProducts() async {
    if (!await _iap.isAvailable()) return [];
    final response = await _iap.queryProductDetails(_productIds);
    return response.productDetails;
  }

  static Future<bool> purchaseProduct(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    return await _iap.buyNonConsumable(purchaseParam: param);
  }

  static Future<void> restorePurchases() async => await _iap.restorePurchases();

  static void _handleIAPPurchases(List<PurchaseDetails> purchases, WidgetRef ref) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        await _grantPremium(purchase, ref);
        await _iap.completePurchase(purchase);
      }
    }
  }

  static Future<void> _grantPremium(PurchaseDetails purchase, WidgetRef ref) async {
    DateTime? expiry;
    if (purchase.productID == 'ufit_pro_monthly') expiry = DateTime.now().add(const Duration(days: 31));
    else if (purchase.productID == 'ufit_pro_yearly') expiry = DateTime.now().add(const Duration(days: 365));
    await ref.read(userProvider.notifier).setPremium(true, expiry: expiry);
  }
}
