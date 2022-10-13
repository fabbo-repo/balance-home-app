# Flutter Frontend

Multiplatform frontend of Balance Home App, ```riverpod``` is used for state management and ```go_router``` for navigation.

## Directory tree example

~~~bash
flutter/
    ├── domain
    │   ├── domain1
    │   │   └── object1.dart
    │   └── ...
    ├── common
    │   ├── app_config
    │   |   ├── ...
    │   |   └── env_model.dart
    │   └── widgets
    │       └── ...
    ├── ui
    │   ├── ui1
    │   │   ├── screens
    │   │   │   └── create_event_screen.dart
    │   │   ├── widgets
    │   │   │   └── event_card.dart
    │   │   └── controllers
    │   │       └── create_event_controller.dart
    │   └── ...
    ├── providers
    │   └── providers1
    │       └── ...
    ├── services
    │   ├── services1
    │   │   └── ...
    │   └── ...
    ├── lang
    │   ├── app_es.arb
    │   ├── app_en.arb
    │   └── app_fr.arb
    └── navigation
        └── ...
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
