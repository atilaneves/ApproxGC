# ApproxGC — A cleanup program for Approx
#
# Copyright © 2017  Russel Winder <russel@winder.org.uk>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

project(
  'ApproxGC',
  'd',
  version: '0.0.0',
  default_options: ['buildtype=release']
)

compiler_flags = [
]

dependencies = [
  # dependency('threads'),
]

sources = [
  'source/main.d',
]

test_sources = [
  'test-source/main.d',
  'source/main.d',
]

executable('approx-gc',
           sources,
           dependencies: dependencies,
           d_args: compiler_flags,
           install: false # true,
)

approx_gc_unit_test = executable('approx-gc-unit-test',
                                 sources,
                                 dependencies: dependencies,
                                 d_args: compiler_flags + ['-unittest'],
                                 link_args: ['--main'],
)

test('ApproxGC unit tests', approx_gc_unit_test)

approx_gc_system_test = executable('approx-gc-system-test',
                                   test_sources,
                                   dependencies: dependencies,
                                   d_args: compiler_flags + ['-unittest'],
                                   include_directories: include_directories('source'),
)

test('ApproxGC system tests', approx_gc_system_test)
