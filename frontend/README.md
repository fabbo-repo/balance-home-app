# DRF Backend

## Architecture Sample

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
