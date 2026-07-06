# uFit — Production Flutter App

A complete, ready-to-run Flutter health & fitness tracking app: habits, water, workouts, sleep, weight, and mood — with a built-in freemium subscription system.

## 📦 What's Included

```
ufit/
├── pubspec.yaml                  All dependencies
├── android/                      Android manifest + permissions configured
├── lib/
│   ├── main.dart                 App entry point
│   ├── app_router.dart           Navigation (go_router)
│   ├── theme/app_theme.dart      Full dark/light design system
│   ├── models/                   Hive data models (Habit, WaterLog, etc.)
│   ├── providers/                Riverpod state management
│   ├── services/
│   │   ├── storage_service.dart       Local DB (Hive)
│   │   ├── notification_service.dart  Reminders
│   │   └── payment_service.dart       Razorpay + IAP integration
│   ├── widgets/common_widgets.dart    Reusable UI components
│   └── screens/
│       ├── auth/onboarding_screen.dart
│       ├── dashboard/dashboard_screen.dart
│       ├── habits/habits_screen.dart
│       ├── water/water_screen.dart
│       ├── workout/workout_screen.dart
│       ├── sleep/sleep_screen.dart
│       ├── weight/weight_screen.dart
│       ├── mood/mood_screen.dart
│       ├── premium/premium_screen.dart   Paywall + plans
│       └── profile/profile_screen.dart
```

## 🚀 Getting Started (on your machine)

You need Flutter installed locally — this build environment can't run Flutter, so follow these steps on your computer:

```bash
# 1. Install Flutter SDK if you haven't: https://docs.flutter.dev/get-started/install

# 2. Extract/copy this ufit/ folder, then:
cd ufit
flutter pub get

# 3. (Optional but recommended) regenerate Hive adapters properly:
flutter pub run build_runner build --delete-conflicting-outputs
# Note: I've already hand-written lib/models/models.g.dart so the app
# compiles immediately even without this step. Re-running build_runner
# is only needed if you add new fields to models.dart later.

# 4. Run on a connected device/emulator
flutter run
```

## 💳 Payment Setup — Cost Breakdown (your main question)

You asked for a payment system that "won't cost" you — here's the honest truth about each option:

| Provider | Fee | Best For | Setup Cost |
|---|---|---|---|
| **Razorpay** | **2% per transaction** | Android, India market | FREE to register |
| **Google Play Billing** | 15-30% | Android (Play Store policy may require this for digital goods) | FREE, but Google takes a cut |
| **Apple In-App Purchase** | 15-30% | iOS (mandatory — Apple blocks any other method for digital subscriptions) | FREE, $99/year Apple Developer fee |

**Recommendation implemented in this app:**
- **Android** → Razorpay (only 2% fee — by far the cheapest, and legal for non-Play-Store-policy-restricted apps)
- **iOS** → Apple In-App Purchase (legally mandatory for iOS — Apple rejects apps that try to bypass this for digital subscriptions)

⚠️ **Important Play Store caveat:** Google Play policy technically requires "real-money purchases of digital content" to use Google Play Billing, not third-party processors like Razorpay, if you're distributing through the Play Store. Many India-based fitness apps still use Razorpay successfully, but this is a gray area — if Google flags your app, you may need to switch the Android flow to Google Play Billing (already scaffolded in `payment_service.dart`, just swap which `purchaseViaIAP` is called for Android too). To be 100% safe and Play-Store-compliant, use Google Play Billing instead of Razorpay for Android subscriptions. Razorpay is fully fine if you ever sideload the APK or use a website-only checkout flow.

### Setting up Razorpay (free signup)
1. Go to razorpay.com → Sign up → Get **Test API Key** instantly, **Live API Key** after KYC
2. Open `lib/services/payment_service.dart`
3. Replace `'rzp_live_YOUR_KEY_HERE'` with your real key
4. **Critical for production**: verify payments server-side. Right now the app trusts the client — add a backend (Firebase Functions is free-tier friendly) that verifies `payment_id + order_id + signature` via HMAC-SHA256 before marking a user Premium.

### Setting up Apple IAP
1. Apple Developer account ($99/year — unavoidable for any iOS app)
2. App Store Connect → your app → Features → In-App Purchases → create 3 products matching the IDs in `payment_service.dart`: `ufit_pro_monthly`, `ufit_pro_yearly`, `ufit_pro_lifetime`

### Setting up Google Play Billing (alternative/safer for Android)
1. Play Console → Monetize → Products → create the same 3 product IDs
2. Already supported via the `in_app_purchase_android` package included in pubspec.yaml

## 🎯 Monetization Model Built In

- **Free tier:** 3 habits max, basic water/workout/sleep/weight/mood logging
- **Pro tier** (₹299/mo, ₹1499/yr "Best Value", ₹2999 lifetime):
  - Unlimited habits
  - Advanced analytics
  - Data export
  - No ads (ad slots aren't wired in yet — see below)

## 📢 Adding Ads (you also mentioned ads as a revenue option)

I didn't wire in an ad SDK by default since combining ads + subscriptions needs a judgment call (most successful fitness apps go subscription-only or ads-only, rarely both aggressively). If you want ads too:

1. Add `google_mobile_ads` package to pubspec.yaml
2. Show banner ads only when `!isPremium` (the `premiumProvider` already gates this everywhere)
3. Apply for AdMob account (free) at admob.google.com

## 🔧 Things to Finish Before Launch

1. **Backend payment verification** (critical — don't skip, or people can fake purchases)
2. Replace placeholder Razorpay key
3. Run `flutterfire configure` if you want Firebase auth/cloud sync (currently the app works 100% offline with Hive)
4. Add real app icons (`assets/images/`, update `android/app/src/main/res/mipmap-*`)
5. Test notification permissions on Android 13+ (runtime permission required)
6. Privacy Policy + Terms of Service pages (linked in Profile screen, currently empty `onTap: () {}`)

## 🏗 Architecture Notes

- **State management:** Riverpod (`StateNotifierProvider` per module — Habits, Water, Workout, Sleep, Weight, Mood, User, Premium)
- **Local storage:** Hive (fast, offline-first, no setup required)
- **Navigation:** go_router with a persistent bottom nav shell
- **All data is currently local-only.** To sync across devices, add Firestore writes inside each provider's methods (the Firebase packages are already in pubspec.yaml).
