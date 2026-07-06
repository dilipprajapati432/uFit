// lib/screens/premium/premium_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../services/payment_service.dart';
import '../../theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  String _selectedPlanId = 'ufit_pro_yearly';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    PaymentService.initRazorpay(
      onSuccess: _onPaymentSuccess,
      onFailure: _onPaymentFailure,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlan = SubscriptionPlan.plans.firstWhere((p) => p.id == _selectedPlanId);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    onPressed: _restorePurchases,
                    child: Text('Restore', style: TextStyle(color: context.textSecondary)),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Hero
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text('✨', style: TextStyle(fontSize: 40))),
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                    SizedBox(height: 16),
                    Text(
                      'uFit Pro',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                    ).animate().fadeIn(delay: 100.ms),
                    SizedBox(height: 6),
                    Text(
                      'Unlock your full potential',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.textSecondary),
                    ).animate().fadeIn(delay: 150.ms),
                  ],
                ),
              ),
              SizedBox(height: 28),

              // Feature list
              ..._features.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(entry.value.$1, style: TextStyle(fontSize: 16))),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(entry.value.$2, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: 200 + entry.key * 60)).slideX(begin: 0.1)),

              SizedBox(height: 28),

              // Plan cards
              ...SubscriptionPlan.plans.map((plan) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PlanCard(
                  plan: plan,
                  isSelected: _selectedPlanId == plan.id,
                  onTap: () => setState(() => _selectedPlanId = plan.id),
                ),
              )),
              SizedBox(height: 20),

              // Purchase button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _handlePurchase(selectedPlan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isProcessing
                      ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          selectedPlan.period == 'lifetime'
                              ? 'Get Lifetime Access'
                              : 'Start ${selectedPlan.period == 'yearly' ? 'Yearly' : 'Monthly'} Plan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              SizedBox(height: 12),

              Center(
                child: Text(
                  (!kIsWeb && Platform.isIOS)
                      ? 'Payment will be charged to your Apple ID. Cancel anytime in Settings.'
                      : 'Secure payment via Razorpay (Cards, UPI, Netbanking, Wallets)',
                  style: TextStyle(color: context.textMuted, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),

              // Trust badges
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _trustBadge('🔒', 'Secure'),
                  SizedBox(width: 20),
                  _trustBadge('↩️', 'Cancel Anytime'),
                  SizedBox(width: 20),
                  _trustBadge('⭐', '4.8 Rating'),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trustBadge(String emoji, String label) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 18)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: context.textMuted, fontSize: 10)),
      ],
    );
  }

  static final _features = [
    ('🎯', 'Unlimited habits & custom categories'),
    ('📊', 'Advanced analytics & AI insights'),
    ('📸', 'Progress photos & body measurements'),
    ('🏋️', 'Custom workout builder & templates'),
    ('📤', 'Export your data (CSV/PDF)'),
    ('🚫', 'No ads, ever'),
    ('💬', 'Priority customer support'),
  ];

  void _handlePurchase(SubscriptionPlan plan) {
    setState(() => _isProcessing = true);

    if (!kIsWeb && Platform.isAndroid) {
      // Use Razorpay for Android (lower fees, India-friendly)
      final user = ref.read(userProvider);
      PaymentService.openRazorpay(
        plan: plan,
        userName: user?.name ?? 'uFit User',
        userEmail: user?.email ?? '',
        userPhone: '',
      );
    } else {
      // Use Apple IAP for iOS (mandatory per App Store guidelines)
      _purchaseViaIAP(plan);
    }
  }

  Future<void> _purchaseViaIAP(SubscriptionPlan plan) async {
    final products = await PaymentService.getProducts();
    final product = products.where((p) => p.id == plan.id).firstOrNull;
    if (product == null) {
      setState(() => _isProcessing = false);
      _showError('Product not available. Please try again later.');
      return;
    }
    await PaymentService.purchaseProduct(product);
    setState(() => _isProcessing = false);
  }

  void _onPaymentSuccess(String paymentId) async {
    setState(() => _isProcessing = false);
    final plan = SubscriptionPlan.plans.firstWhere((p) => p.id == _selectedPlanId);
    DateTime? expiry;
    if (plan.period == 'monthly') expiry = DateTime.now().add(const Duration(days: 31));
    if (plan.period == 'yearly') expiry = DateTime.now().add(const Duration(days: 365));

    await ref.read(userProvider.notifier).setPremium(true, expiry: expiry);

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: context.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎉', style: TextStyle(fontSize: 56)),
              SizedBox(height: 16),
              Text('Welcome to Pro!', style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 8),
              Text(
                'You now have access to all premium features.',
                style: TextStyle(color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('Awesome!'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _onPaymentFailure(String error) {
    setState(() => _isProcessing = false);
    _showError(error);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _restorePurchases() async {
    await PaymentService.restorePurchases();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checking for previous purchases...')),
    );
  }

  @override
  void dispose() {
    PaymentService.disposeRazorpay();
    super.dispose();
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({required this.plan, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : context.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : context.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(color: isSelected ? AppColors.primary : context.border, width: 2),
                  ),
                  child: isSelected ? Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.name, style: Theme.of(context).textTheme.titleLarge),
                      Text(plan.description, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${plan.priceINR.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isSelected ? AppColors.primary : null,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      plan.period == 'lifetime' ? 'one-time' : '/${plan.period == 'monthly' ? 'mo' : 'yr'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (plan.isPopular)
            Positioned(
              top: -10,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'BEST VALUE',
                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
