# Balance Home App or *BalHom*

> **DEPRECATED**
> 
> This repo is deprecated, new repo can be found in [BalHom](https://github.com/balhom)

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

* [New Flutter Documentation](https://github.com/balhom/balhom-flutter-ui)
* [New DRF API Documentation](https://github.com/balhom/balhom-djangorest-api)
