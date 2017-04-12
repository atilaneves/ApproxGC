buildDirectory = 'Build'

environment = Environment(
    tools=['ldc', 'link'],
)

Export('environment')

release = SConscript('SConscripts/Release', variant_dir=buildDirectory + '/Release', duplicate=0)
VariantDir(buildDirectory + '/Release/source', '#/source', duplicate=0)
Alias('release', release)

unitTests = SConscript('SConscripts/UnitTests', variant_dir=buildDirectory + '/UnitTests', duplicate=0)
VariantDir(buildDirectory + '/UnitTests/source', '#/source', duplicate=0)
Alias('unitTests',unitTests)
Command('run_unitTests', unitTests, './$SOURCE')

integrationTests = SConscript('SConscripts/IntegrationTests', variant_dir=buildDirectory + '/IntegrationTests', duplicate=0)
VariantDir(buildDirectory + '/IntegrationTests/source', '#/source', duplicate=0)
Alias('integrationTests', integrationTests)
Command('run_integrationTests', integrationTests, './$SOURCE')

Alias('build-all', [release, unitTests, integrationTests])

Default(['run_unitTests', 'run_integrationTests'])

Clean('.', buildDirectory)
