# Firebase Login and App Check Setup Instructions

This document provides the necessary steps to configure Firebase Authentication with Google Sign-In and enable Firebase App Check for your project. These steps must be performed manually in the Google Cloud and Firebase consoles.

## Part 1: Enable Firebase App Check API

The error `Firebase App Check API has not been used in project...` indicates that the API is disabled. You must enable it.

1.  **Open the Google Cloud Console API Library** by navigating to the following URL (make sure you are logged into the correct Google account associated with your Firebase project):

    [https://console.developers.google.com/apis/api/firebaseappcheck.googleapis.com/overview?project=215737406861](https://console.developers.google.com/apis/api/firebaseappcheck.googleapis.com/overview?project=215737406861)

2.  Click the **"Enable"** button. If it's already enabled, you don't need to do anything.

## Part 2: Configure App Check Enforcement

After enabling the API, you need to configure which providers App Check will use to verify your app.

1.  **Go to the Firebase Console**: [https://console.firebase.google.com/](https://console.firebase.google.com/)

2.  Select your project: `cargarage-942ba`.

3.  In the left-hand navigation menu, under the **"Build"** section, click on **"App Check"**.

4.  You will see two tabs: **"Apps"** and **"API Verifications"**. Stay on the **"Apps"** tab.

### For Android:

1.  You should see your Android app listed with the package name `com.example.myapp`.
2.  Click on the app in the list.
3.  A panel will open. Click on **"Play Integrity"**.
4.  Follow the on-screen instructions to enable it. You will likely just need to click the **"Save"** button if your project is already linked to Google Play.

### For Web:

1.  You should see your Web app listed.
2.  Click on the web app in the list.
3.  A panel will open. Click on **"reCAPTCHA v3"**.
4.  You will be prompted to provide a **reCAPTCHA v3 site key**. You need to generate this key.
5.  Click the link to go to the **reCAPTCHA Enterprise admin console** (or open it in a new tab: [https://cloud.google.com/recaptcha-enterprise/](https://cloud.google.com/recaptcha-enterprise/)).
6.  Follow the instructions to create a new key. Select **reCAPTCHA v3** and add your app's domain when prompted. For local development, you can add `localhost`.
7.  Once the key is created, copy the **Site Key**.
8.  Go back to the Firebase Console and paste the Site Key into the reCAPTCHA v3 configuration panel.
9.  Click **"Save"**.

## Part 3: Update the App Code

Once you have the reCAPTCHA v3 site key, you need to provide it to the AI assistant (me!) so I can update the placeholder in the code.

**Example:**

Tell me: "My reCAPTCHA v3 site key is `AIzaSy...`"

I will then update the `lib/main.dart` file for you.

---

After you have completed all these steps, the authentication errors should be resolved, and the app should function correctly. It may take a few minutes for the new settings to propagate through Google's systems.
