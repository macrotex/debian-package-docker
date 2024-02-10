#!/usr/bin/env python

"""Tests for scripts used in the Debian Package build container.
"""

import unittest

import os
import shutil
import subprocess
import tempfile

from typing import Tuple

class TestDebianPackage(unittest.TestCase):
    """Tests for scripts used in the Debian Package build container."""

    @staticmethod
    def run_command(cmd: list[str]) -> Tuple[str, str, int]:
        """Run a command and return stdout, stderr, and return code."""
        result = subprocess.run(cmd, capture_output=True, check=False)
        stdout     = result.stdout.decode("ascii")
        stderr     = result.stderr.decode("ascii")
        returncode = result.returncode

        return (stdout, stderr, returncode)

    def test_install_dependencies(self) -> None:
        """Test the extract-dependencies.pl Perl script on a control file."""
        start_dir = os.getcwd()

        with tempfile.TemporaryDirectory() as temp_dir:
            # 1. Make the debian subdirectory
            debian_directory = os.path.join(temp_dir, 'debian')
            os.mkdir(debian_directory)

            # 2. Copy the control file into the debian directory.
            control_file = 'control'
            shutil.copy(control_file, debian_directory)

            # 3. Change working directory into the temporary directory and
            #    check dependencies.
            os.chdir(temp_dir)
            cmd = ['ls', '-l']
            (stdout, stderr, _) = TestDebianPackage.run_command(cmd)

            # 4. Run "dpkg-checkbuilddeps"
            cmd = ['dpkg-checkbuilddeps']
            (stdout, stderr, _) = TestDebianPackage.run_command(cmd)
            results = stderr # Any unmet dependencies will end up in stderr

            # We no longer need the temporary directory so we leave its context.

        # Return to starting directory.
        os.chdir(start_dir)

        # 5. Run the output through extract-dependencies.pl
        cmd = ['perl', '../extract-dependencies.pl', results]
        (stdout, stderr, _) = TestDebianPackage.run_command(cmd)
        missing_packages = sorted(stdout.split(' '))
        correct_result = [
            'fake-package1',
            'fake-package2',
            'libipc-run-perl',
            'libnet-dns-perl'
        ]
        self.assertEqual(missing_packages, correct_result)

#############################################################
if __name__ == '__main__':
    unittest.main()
