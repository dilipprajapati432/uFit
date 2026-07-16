// lib/services/payment_service.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../providers/app_providers.dart';

class PaymentService {
  static Future<void> initIAP(WidgetRef ref) async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration("goog_YNDBRXxzyKgCvzEjoNBsCTzPbuE");
    } else {
      // You will need to replace this with your real Apple RevenueCat key later
      configuration = PurchasesConfiguration("appl_placeholder_key_here");
    }
    
    await Purchases.configure(configuration);

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      _checkAndUpdatePremiumStatus(customerInfo, ref);
    });
    
    // Initial check on app startup
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      _checkAndUpdatePremiumStatus(customerInfo, ref);
    } catch (e) {
      debugPrint("Failed to get initial customer info: $e");
    }
  }

  static void _checkAndUpdatePremiumStatus(CustomerInfo customerInfo, WidgetRef ref) async {
    // Check if there is any active subscription
    bool hasActiveSub = customerInfo.activeSubscriptions.isNotEmpty;
    
    if (hasActiveSub) {
      String planId = customerInfo.activeSubscriptions.first;
      DateTime? expiry;
      if (planId.contains('monthly')) expiry = DateTime.now().add(const Duration(days: 31));
      if (planId.contains('yearly')) expiry = DateTime.now().add(const Duration(days: 365));
      await ref.read(userProvider.notifier).setPremium(true, expiry: expiry, plan: planId);
    } else {
      // If no active subscriptions, revoke premium (in case it expired)
      await ref.read(userProvider.notifier).setPremium(false, expiry: null, plan: null);
    }
  }

  // Fetch available packages from RevenueCat Offerings
  static Future<List<Package>> getProducts() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }
    } catch (e) {
      debugPrint("Error fetching offerings: $e");
    }
    return [];
  }

  // Purchase a package via RevenueCat
  static Future<bool> purchaseProduct(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.activeSubscriptions.isNotEmpty;
    } catch (e) {
      debugPrint("Purchase error: $e");
      return false;
    }
  }

  // Restore previous purchases
  static Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      debugPrint("Restore error: $e");
    }
  }
}
