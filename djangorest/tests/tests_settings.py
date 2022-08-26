from configurations import Configuration
from django.conf import settings
from django.test import TestCase


class DevTestCase(TestCase):


    """
    Testing that Dev class is a child of Configuration class
    """
    def test_dev_settings_class(self):
        from core.settings import Dev
        self.assertTrue(issubclass(Dev, Configuration))
    
    """
    Testing DEBUG const is setup correctly in Dev and Prod
    """
    def test_debug_settings(self):
        from core.settings import Dev
        self.assertTrue(Dev.DEBUG)
        from core.settings import Prod
        self.assertFalse(Prod.DEBUG)
    
    """
    Testing logging config in Debug mode
    """
    def test_logging_settings(self):
        logging_settings = settings.LOGGING

        self.assertEqual(logging_settings["version"], 1)
        self.assertEqual(logging_settings["disable_existing_loggers"], False)
        self.assertEqual(logging_settings["handlers"]["console"]["class"], "logging.StreamHandler")
        self.assertEqual(logging_settings["handlers"]["console"]["stream"], "ext://sys.stdout")
        if "formatter" in logging_settings["handlers"]["console"]:
            self.assertIn(logging_settings["handlers"]["console"]["formatter"], logging_settings["formatters"])
        self.assertIn("console", logging_settings["root"]["handlers"])
        self.assertEqual(logging_settings["root"]["level"], "DEBUG")
