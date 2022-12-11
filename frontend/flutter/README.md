# Flutter Frontend

Multiplatform frontend of Balance Home App, ```riverpod``` is used for state management and ```go_router``` for navigation.

## Directory tree example

~~~bash
flutter/
    ├── lang
    │   ├── app_en.arb
    │   └── ...
    ├── src
    │   ├── core
    │   |   ├── data
    |   │   |   ├── repositories
    |   │   |   └── models
    │   |   ├── env
    │   |   ├── exceptions
    │   |   ├── forms
    │   |   ├── providers
    │   |   ├── services
    │   |   ├── views
    │   |   └── widgets
    │   ├── features
    │   |   ├── feature1
    │   |   |   ├── data
    |   │   |   |   ├── repositories
    |   │   |   |   └── models
    │   |   |   ├── logic
    |   │   |   |   └── providers
    │   |   |   └── presentation
    |   │   |       ├── forms
    |   │   |       ├── widgets
    |   │   |       └── views
    │   |   └── ...
    │   ├── navigation
    │   |   ├── router_provider.dart
    │   |   └── router.dart
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
