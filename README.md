# ProfileForge

A portfolio-making app that lets you create, publish, and discover talent—built with Flutter.

**Prototype / kickstarter** – Core flows work end-to-end. Ready to extend into a full product.

## Features

- **Local portfolio** – Build your portfolio offline with name, headline, bio, skills, experience, and links
- **Firebase Auth** – Sign in / sign up with email to publish your portfolio online
- **Publish online** – Push your portfolio to Firestore so others can discover it
- **Discover** – AI-style search: describe who you're looking for (e.g. "Flutter developer with backend experience") and get matching portfolios
- **Explore** – Browse all public portfolios
- **Public profile** – View other users' portfolios in full detail
- **Hire requests** – Companies can send hire requests; portfolio owners see them in-app
- **Account types** – Portfolio owner (showcase work) or Hirer (find talent)

## Roadmap

- [ ] Notifications for hire requests
- [ ] Rich portfolio themes & templates
- [ ] Analytics for portfolio views
- [ ] Team/company profiles for hirers

## Firebase setup

Works on the **free Spark plan** (no Blaze needed).

1. Create a project at [Firebase Console](https://console.firebase.google.com)
2. Enable **Authentication** (Email/Password) and **Firestore**
3. Run: `dart run flutterfire configure` to generate `lib/firebase_options.dart` and platform config files
4. Create a Firestore collection `portfolios` (or let the app create it on first publish)

## Namespace

The app uses `com.harunalhamdy.profileforge` on Android, iOS, and macOS.

## Android build

If you see **"Namespace not specified"** for `isar_flutter_libs` when building for Android, run once (and again after `flutter pub get` if you clear the cache):

```powershell
.\scripts\patch_isar_android.ps1
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
