import os
import subprocess

environment = Environment(
    tools=['dub', 'ldc', 'link'],
)

testEnvironment = environment.Clone()
testEnvironment.AddDubLibrary('unit-threaded', '0.7.13')


buildDirectory = 'Build'

release = SConscript('source/SConscript_Release', variant_dir=buildDirectory + '/Release', duplicate=0, exports='environment')
Alias('release', release)

unitTests = SConscript('source/SConscript_UnitTests', variant_dir=buildDirectory + '/UnitTests', duplicate=0, exports='testEnvironment')
Alias('unittests',unitTests)
Command('run_unittests', unitTests, './$SOURCE')

integrationTests = SConscript('test-source/SConscript_IntegrationTests', variant_dir=buildDirectory + '/IntegrationTests', duplicate=0, exports='testEnvironment')
Alias('integrationtests', integrationTests)
Command('run_integrationtests', integrationTests, './$SOURCE')

Alias('build-all', [release, unitTests, integrationTests])

Default(['run_unittests', 'run_integrationtests'])

Clean('.', [buildDirectory, 'approx-gc', 'unit-tests', 'integration-tests', 'ut_main.d'])
