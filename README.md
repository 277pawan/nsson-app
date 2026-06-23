# NSSON Moto Crafter App

A Flutter B2B Mobile Application for Motorcycle Spare Parts.

---

## 📱 Running the Application (Android)

Since this is a **Flutter** application, you do **not** use Metro bundler (which is for React Native). Flutter uses its own built-in compiler and run system.

### Prerequisites
1. **Flutter SDK** installed and configured on your system.
2. **Android SDK** and platform tools installed (specifically `adb`).
3. A physical Android device with **USB Debugging** enabled and plugged into your laptop.

### Step-by-Step Guide

#### 1. Verify Android Device Connection
Ensure your device is recognized by the system:
```bash
adb devices
```
*(If your device is not listed, make sure USB debugging is turned on, the cable is secure, and you have authorized the USB connection on your phone screen.)*

#### 2. Set Up Backend Port Forwarding (Crucial)
Your backend is running locally on **`localhost:8080`**. Since your phone is a physical device, it doesn't automatically know how to reach your laptop's `localhost`.
Run the following command to forward the port from your phone to your laptop:
```bash
adb reverse tcp:8080 tcp:8080
```
This maps `localhost:8080` requests from the phone directly to `localhost:8080` on your laptop.

#### 3. Run the App
Launch the app in debug mode on your connected device:
```bash
flutter run
```

---

## 🛠️ Building the Application (Release APK)

To build a standalone APK that you can install on any Android device:

1. Build the release APK:
   ```bash
   flutter build apk --release
   ```
   *Note: The generated APK will be saved at `build/app/outputs/flutter-apk/app-release.apk`.*

2. *(Optional)* To build smaller APKs optimized for specific phone architectures (saves download size):
   ```bash
   flutter build apk --split-per-abi
   ```

---

## 🧹 Cleaning Up Unused Platforms

### Removing other platforms (Only building for Android)
If you are building **strictly** for Android, you can remove the other platform directories to keep your codebase clean. Run this command inside the project directory:
```bash
rm -rf ios macos windows linux web
```
*(Keep the `ios` folder if you plan to target iPhones in the future, otherwise it can be safely removed.)*
