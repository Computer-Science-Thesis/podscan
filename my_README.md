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