# Android Build Guide - OriLang

Build, sign, and run the Ori C VM as an Android APK (API >= 24).

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| JDK | 17+ | JAVA_HOME must be set |
| Android SDK Build-Tools | 35.0.0+ | Installed via SDK Manager |
| Android NDK | 26+ | For cross-compiling libori.so |
| Android Platform | 34 | platforms/android-34/android.jar |
| Debug keystore | - | ~/.android/debug.keystore |

## Quick verification



## Build



The build script:
1. Compiles oriandroid.c into libori.so (x86_64) via the NDK
2. Compiles java/ sources into .dex
3. Packages everything into an unsigned APK
4. Signs with the debug keystore

## Install and run



## Permissions

The AndroidManifest.xml declares INTERNET permission - needed when
your .orb program uses http_get. No runtime permission prompt is required
(INTERNET is a normal permission, granted at install time on API >= 24).

### Adding more permissions

If your Ori program needs camera, storage, or location access, edit
platforms/android/AndroidManifest.xml and add the appropriate
uses-permission entry before the application block:



For dangerous permissions (CAMERA, LOCATION, READ_EXTERNAL_STORAGE),
request them at runtime in java/ori/app/MainActivity.java.

## File layout



## Troubleshooting

| Symptom | Likely fix |
|---------|-----------|
| JAVA_HOME not set | Install JDK 17+ and set the env var |
| aapt not found | Install Android SDK Build-Tools 35.0.0 |
| NDK toolchain missing | Install NDK 26+ via SDK Manager |
| debug.keystore missing | Run Android Studio once, or keytool -genkey |
| INSTALL_FAILED_OLDER_SDK | Device API < 24; raise minSdkVersion in manifest |
