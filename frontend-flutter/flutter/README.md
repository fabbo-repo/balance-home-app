# Flutter Frontend

Multiplatform frontend of Balance Home App, ```riverpod``` is used for state management and ```go_router``` for navigation.

## Architecture diagram

Based on [flutter clean architecture with riverpod](https://otakoyi.software/blog/flutter-clean-architecture-with-riverpod-and-supabase)

## Directory tree example

~~~
flutter/
    ├── lang
    │   ├── app_colors.dart
    │   ├── app_layout.dart
    │   ├── providers.dart
    │   ├── router.dart
    │   ├── theme.dart
    │   ├── environment.dart
    │   └── ...
    ├── config
    │   ├── app_en.arb
    │   └── ...
    ├── src
    │   ├── core
    │   |   ├── application
    |   │   |   ├── controller1.dart
    |   │   |   └── ...
    │   |   ├── domain
    |   │   |   ├── entities
    |   │   |   ├── failures
    |   │   |   ├── repositories
    |   │   |   └── values
    │   |   ├── infrastructure
    |   │   |   ├── datasources
    |   │   |   |   |── local
    |   │   |   |   └── remote
    |   │   |   └── repositories
    │   |   ├── presentation
    │   |   └── providers.dart
    │   ├── features
    │   |   ├── feature1
    |   │   |   ├── application
    |   |   │   |   ├── controller1.dart
    |   |   │   |   └── ...
    |   │   |   ├── domain
    |   |   │   |   ├── entities
    |   |   │   |   ├── failures
    |   |   │   |   ├── repositories
    |   |   │   |   └── values
    |   │   |   ├── infrastructure
    |   |   │   |   ├── datasources
    |   |   │   |   |   |── local
    |   |   │   |   |   └── remote
    |   |   │   |   └── repositories
    |   │   |   ├── presentation
    |   │   |   └── providers.dart
    │   |   └── ...
    │   |── bootstrap.dart
    │   └── app.dart
    └── main.dart
~~~

## Useful commands

* Create a project

~~~bash
flutter create --project-name <app_name> --org dev.flutter --android-language java --ios-language objc <dir_name>
~~~

* Fetch packages

~~~bash
flutter pub get
~~~

* Generate translations files:

~~~bash
flutter gen-l10n
~~~

* Generate platform icons:

~~~bash
flutter pub run flutter_launcher_icons:main
~~~

* Code generation:

~~~bash
flutter pub run build_runner build --delete-conflicting-outputs
~~~

* Generate splash screen:

~~~bash
flutter pub run flutter_native_splash:create
~~~

* Generate keystore:

~~~bash
keytool -genkey -v -keystore ./keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias <ALIAS>
~~~

* Generate SHA1 and SHA2 keys:

~~~bash
cd android: ./gradlew signingreport; cd ..
~~~

or

~~~bash
keytool -list -v -alias <ALIAS> -keystore <PATH_KEYSTORE>
~~~
