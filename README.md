![Alt text](./balance_home_app.png?raw=true "")

# Balance Home App or *BalHom*

[![Generic badge](https://img.shields.io/badge/BalHom-v.0.0.2-GREEN.svg)](https://shields.io/)
[![Generic badge](https://img.shields.io/badge/os-android-GREEN.svg)](https://shields.io/)
[![Generic badge](https://img.shields.io/badge/os-web-GREEN.svg)](https://shields.io/)

![Django](https://img.shields.io/badge/django-7B9D4B?style=for-the-badge&logo=django&logoColor=ffdd54)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)

**Balance Home App** or ***BalHom*** is an open source multi-platform app that helps people to manage their day-to-day expenses and revenues.

Some of its advantages are:

* The useof different types of currencies, managing in a transparent way the exchange between currencies by adding an expense or income, as well as, including the possibility to add new currencies.

* By default, at the end of each month it sends an email with the summary of the monthly balance. It also applies to an annual period.

* Classification tool for expenses and incomes. More categories can be added to those that come by default from the admin panel.

* Options to manage monthly or annual balance thanks to an expectation threshold that can be configured from the user profile.

* Support for different languages (English, French and Spanish).

## For developers

This app is divided into two components, backend and frontend. On the bckend side, the Django framework was chosen with Celery and Redis for tasks scheduling. On the other hand, the Flutter framework was used in fronted, due to its multiplatform capability.

Extra information is available for people interested in checking the source code or testing the system. Just check the next links:

* [Frontend Documentation](https://github.com/fabbo-repo/BalanceHomeApp/tree/main/frontend/flutter#readme)
* [Backend Documentation](https://github.com/fabbo-repo/BalanceHomeApp/tree/main/backend/djangorest#readme)

## Usage

To use the app, the server of the content located in the [deployment](https://github.com/fabbo-repo/BalanceHomeApp/tree/main/backend) folder must be previously deployed. It is recommended to read its [documentation](https://github.com/fabbo-repo/BalanceHomeApp/tree/main/backend/djangorest#readme)
