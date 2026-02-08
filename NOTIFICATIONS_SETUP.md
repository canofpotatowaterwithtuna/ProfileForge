# Push Notifications Setup (Firebase Spark Plan)

This app uses **OneSignal + Zapier/Make.com** for push notifications—no Cloud Functions or Blaze plan required.

> **Note:** The `functions/` folder contains Cloud Functions that would work on the Blaze plan. Ignore it if you're on Spark; use this OneSignal + Zapier/Make setup instead.

## 1. OneSignal Setup

1. Create a free account at [onesignal.com](https://onesignal.com)
2. Create a new app (mobile – Flutter)
3. Add your Android and iOS platforms (OneSignal will guide you)
4. Copy your **OneSignal App ID** from Settings → Keys & IDs
5. In `lib/features/hire/data/onesignal_notification_service.dart`, replace `YOUR_ONESIGNAL_APP_ID` with your App ID

## 2. Automate Notifications with Zapier (Free Tier)

**Zapier free plan:** 100 tasks/month, polls every 15 minutes.

1. Go to [zapier.com](https://zapier.com) and create a free account
2. Create a new Zap:
   - **Trigger:** Firebase / Firestore → "New Document Within a Firestore Collection"
     - Collection: `hireRequests`
     - Connect your Firebase project (use a Service Account key with Firestore read access)
   - **Action:** OneSignal → "Send Advanced Push Notification"
     - Title: `New hire request`
     - Message: Use dynamic data like `{{from_name}} from {{from_company}} wants to connect`
     - **Include External User IDs:** `{{to_user_id}}` (this targets the recipient; map from the Firestore document field `toUserId`)
     - Custom Data: Add `requestId` = `{{id}}` so the app opens the conversation when tapped

3. If Zapier's OneSignal action doesn't offer "External User IDs", use **Make.com** (below) instead.

## 3. Alternative: Make.com (More Flexible)

Make.com has a free tier and can call OneSignal's REST API directly.

1. Create a free account at [make.com](https://make.com)
2. Create a new scenario:
   - **Module 1 – Trigger:** Google Cloud Firestore → "Watch Document"
     - Collection: `hireRequests`
     - Or use "Watch Document Snapshot" with the path
   - **Module 2 – HTTP:** "Make a request"
     - URL: `https://api.onesignal.com/notifications`
     - Method: POST
     - Headers: `Authorization: Basic YOUR_REST_API_KEY`, `Content-Type: application/json`
     - Body (JSON):
       ```json
       {
         "app_id": "YOUR_ONESIGNAL_APP_ID",
         "include_external_user_ids": ["{{toUserId}}"],
         "headings": {"en": "New hire request"},
         "contents": {"en": "{{fromName}} from {{fromCompany}} wants to connect"},
         "data": {"requestId": "{{requestId}}"}
       }
       ```
     - Map `toUserId`, `fromName`, `fromCompany`, and `requestId` from the Firestore document

3. Get your OneSignal REST API Key from OneSignal → Settings → Keys & IDs

## 4. App Configuration

- Ensure `onesignal_notification_service.dart` has your OneSignal App ID
- Users are identified by Firebase UID (set via `OneSignal.login(uid)` on sign-in)
- Zapier/Make uses `toUserId` from the hire request document to target the recipient

## Notes

- **Zapier free tier:** Polls every 15 min; notifications may be delayed
- **Make.com free tier:** 1,000 operations/month
- **OneSignal free tier:** 10,000 subscribers, unlimited notifications
