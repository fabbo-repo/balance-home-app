# Balance Home App

**Balance Home App** is an open source multi-platform app that helps people to manage their day-to-day expenses and revenues.

Some of its advantages are:

* The useof different types of currencies, managing in a transparent way the exchange between currencies by adding an expense or income, as well as, including the possibility to add new currencies.

* By default, at the end of each month it sends an email with the summary of the monthly balance. It also applies to an annual period.

* Classification tool for expenses and incomes. More categories can be added to those that come by default from the admin panel.

* Options to manage monthly or annual balance thanks to an expectation threshold that can be configured from the user profile.

* Support for different languages (English, French and Spanish).

## For developers

This app is divided into two components, backend and frontend. On the bckend side, the Django framework was chosen with Celery and Redis for tasks scheduling. On the other hand, the Flutter framework was used in fronted, due to its multiplatform capability.

Extra information is available for people interested in checking the source code or testing the system. Just check the next links:

* [Frontend Documentation](https://github.com/fabbo-repo/BalanceHomeApp/tree/main/flutter#readme)
* [Backend Documentation](https://github.com/fabbo-repo/BalanceHomeApp/tree/main/djangorest#readme)

## Usage

To use the app, the server of the content located in the [deployment](https://github.com/fabbo-repo/BalanceHomeApp/tree/main/deployment/release) folder must be previously deployed. It is recommended to read its [documentation](https://github.com/fabbo-repo/BalanceHomeApp/tree/main/deployment#readme)
