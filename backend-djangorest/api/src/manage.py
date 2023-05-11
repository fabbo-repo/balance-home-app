#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys


def main():
    """Run administrative tasks."""
    
    # Check On Premise configuration
    if "check" in sys.argv and "--deploy" in sys.argv:
        os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
        os.environ.setdefault("DJANGO_CONFIGURATION", "OnPremise")
        os.environ.setdefault("USE_HTTPS", "True")
        from configurations.management import execute_from_command_line
        execute_from_command_line(['manage.py', 'check', '--deploy'])
        sys.exit()

    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
    os.environ.setdefault("DJANGO_CONFIGURATION", "Dev")

    # Customization: run coverage.py around tests automatically
    try:
        command = sys.argv[1]
    except IndexError:
        command = "help"

    testing_mode = command == "test"
    if testing_mode:
        from coverage import Coverage
        cov = Coverage()
        cov.erase()
        cov.start()
    
    try:
        from configurations.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)

    if testing_mode:
        cov.stop()
        cov.save()
        covered = cov.report()
        if covered < 70:
            sys.exit(1)

if __name__ == '__main__':
    main()
