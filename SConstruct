import os
import subprocess

environment = Environment(
    tools=['dub', 'ldc', 'link'],
)

testEnvironment = environment.Clone()
testEnvironment.AddDubLibrary('unit-threaded', '0.7.15')

buildDirectory = 'Build'

release = SConscript('source/SConscript_Release', variant_dir=buildDirectory + '/Release', duplicate=0, exports='environment')
Alias('release', release)

unitTests = SConscript('source/SConscript_UnitTests', variant_dir=buildDirectory + '/UnitTests', duplicate=0, exports='testEnvironment')
Alias('unittests',unitTests)
run_unittests = Command('run_unittests', unitTests, './$SOURCE')

integrationTests = SConscript('test-source/SConscript_IntegrationTests', variant_dir=buildDirectory + '/IntegrationTests', duplicate=0, exports='testEnvironment')
Alias('integrationtests', integrationTests)
run_integrationtests = Command('run_integrationtests', integrationTests, './$SOURCE')

Alias('build', release)
Alias('unittest', unitTests)
Alias('integrationtest', integrationTests)
Default(Alias('test', [run_unittests, run_integrationtests]))

Clean('.', [buildDirectory])

# Also clean up the Dub stuff.
Clean('.', ['bin', 'generated'])
