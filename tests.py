#!/usr/bin/env python
# coding=utf-8

import unittest

from app import main


class TestCase(unittest.TestCase):

    def setUp(self):
        self.app = main.app.test_client()

    def test_main_page(self):
        response = self.app.get('/', follow_redirects=True)
        self.assertEqual(response.status_code, 200)

    def test_status_page(self):
        response = self.app.get('/status', follow_redirects=True)
        self.assertEqual(response.status_code, 200)


if __name__ == '__main__':
    import xmlrunner
    unittest.main(testRunner=xmlrunner.XMLTestRunner(output='test-reports'))
