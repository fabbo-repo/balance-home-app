# Balance Home App

It is a multi platform app which allows people to manage their day-to-day expenses and revenues.

Some of the advantages of using this app:

* It supports different types of currencies, transparently managing the exchange between currencies by adding an expense or income. More types can be added from the admin panel.

* By default, at the end of each month it sends an email with the summary of the monthly balance. T also applies to each year.

* It offers classification of expenses and income by types. More can be added to those that come by default from the admin panel.

* Allows you to manage the monthly or annual balance thanks to a threshold that can be configured from the user profile.

* Offers support for different languages (English, French and Spanish).

## For developers

This app is divided into two components, backend and frontend. On the bckend side, the Django framework was chosen with celery and redis for tasks scheduling. On the other hand, the flutter framework was used in fronted, thanks to its multiplatform capability.

There is some extra information to those who wants to check the source code or test the system. Just check the next links:

- [Frontend Documentation](https://github.com/fabbo-repo/BalanceHomeApp/tree/main/flutter#readme)
- [Backend Documentation](https://github.com/fabbo-repo/BalanceHomeApp/tree/main/djangorest#readme)

## Usage

To use the app, the server of the content located in the [deployment](https://github.com/fabbo-repo/BalanceHomeApp/tree/main/deployment/production) folder must be previously deployed. For this it is recommended to read its [documentation](https://github.com/fabbo-repo/BalanceHomeApp/tree/main/deployment#readme)