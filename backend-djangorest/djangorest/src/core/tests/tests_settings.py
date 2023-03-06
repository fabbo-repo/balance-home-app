from configurations import Configuration
from django.conf import settings
from django.test import TestCase


class DevTestCase(TestCase):

    def test_dev_settings_class(self):
        """
        Testing that Dev class is a child of Configuration class
        """
        from core.settings import Dev
        self.assertTrue(issubclass(Dev, Configuration))

    def test_debug_settings(self):
        """
        Testing DEBUG const is setup correctly in Dev and OnPremise
        """
        from core.settings import Dev
        self.assertTrue(Dev.DEBUG)
        from core.settings import OnPremise
        self.assertFalse(OnPremise.DEBUG)

    def test_logging_settings(self):
        """
        Testing logging config in Debug mode
        """
        from core.settings import Dev
        logging_settings = Dev.LOGGING

        self.assertEqual(logging_settings["version"], 1)
        self.assertEqual(logging_settings["disable_existing_loggers"], False)
        self.assertEqual(
            logging_settings["handlers"]["console"]["class"], "logging.StreamHandler")
        self.assertEqual(
            logging_settings["handlers"]["console"]["stream"], "ext://sys.stdout")
        if "formatter" in logging_settings["handlers"]["console"]:
            self.assertIn(logging_settings["handlers"]["console"]
                          ["formatter"], logging_settings["formatters"])
        self.assertIn("console", logging_settings["root"]["handlers"])
        self.assertEqual(logging_settings["root"]["level"], "DEBUG")
