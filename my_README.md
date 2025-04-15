# 📦 How to Install the APK (Debug Mode)

### ✅ 1. Ensure ProGuard Rules Exist

Make sure the file `android/app/proguard-rules.pro` contains the following:

```proguard
# Keep TensorFlow Lite GPU delegate classes
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
```

### ✅ 2. Edit `android/app/build.gradle.kts`
Replace this block:
```
buildTypes {
  release {
      // TODO: Add your own signing config for the release build.
      // Signing with the debug keys for now, so `flutter run --release` works.
      signingConfig = signingConfigs.getByName("debug")
  }
}
```
With this:
```
buildTypes {
  getByName("release") {
      // TODO: Add your own signing config for the release build.
      // Signing with the debug keys for now, so `flutter run --release` works.
      // signingConfig = signingConfigs.getByName("debug")
      isShrinkResources = true
      isMinifyEnabled = true
      proguardFiles(
          getDefaultProguardFile("proguard-android-optimize.txt"),
          "proguard-rules.pro"
      )
  }
}
```

### ✅ 3. Build the APK
Run:
```
flutter build apk --debug
```
This will generate the APK at:
```
build/app/outputs/flutter-apk/app-debug.apk
```

### ✅ 4. Edit `android/app/build.gradle.kts`
Ensure an Android device or emulator is connected. Then run:
```
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n com.example.podscan/.MainActivity
```

# Setup the icon of the app

### 1. Install the latest `flutter_launcher_icons`
In the pubspec.yaml:
```
dev_dependencies:
  ...
  flutter_launcher_icons: ^0.14.3
  ...
```

### 2. Create the `flutter_launcher_icons.yaml`
Run:
```
dart run flutter_launcher_icons:generate
```
Will generate the file:
```
flutter_launcher_icons.yaml
```
### 3. Edit `flutter_launcher_icons.yaml`
From:
```
flutter_launcher_icons:
  image_path: "assets/icon/icon.png"
  ...

  ios: true
  web:
    generate: true
    ...
  
  windows:
    generate: true
    ...
  
  maoc:
    generate: true
    ...
```
To:
```
flutter_launcher_icons:
  image_path: "assets/icons/logo_512px.png"
  ...

  ios: false
  web:
    generate: false
    ...
  
  windows:
    generate: false
    ...
  
  maoc:
    generate: false
    ...
```

### 3. Generate the icons
Run:
```
dart run flutter_launcher_icons
```
Which will generate the icon images inside of:
```
android/app/src/main/res/
```