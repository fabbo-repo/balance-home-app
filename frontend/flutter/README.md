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
    │   └── widgets
    │       └── ...
    ├── features
    │   ├── feature1
    │   │   ├── page
    │   │   │   └── create_event_page.dart
    │   │   ├── widgets
    │   │   │   └── event_card.dart
    │   │   └── controller
    │   │       └── create_event_controller.dart
    │   └── ...
    ├── app_state
    │   └── feature1
    │       └── ...
    ├── services
    │   ├── feature1
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
