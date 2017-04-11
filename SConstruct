buildDirectory = 'Build'

environment = Environment(
    tools=['ldc', 'link'],
)

Export('environment')


Alias('release', SConscript('SConscripts/Release', variant_dir=buildDirectory + '/Release', duplicate=0))
VariantDir(buildDirectory + '/Release/source', '#/source', duplicate=0)

unitTests = SConscript('SConscripts/UnitTests', variant_dir=buildDirectory + '/UnitTests', duplicate=0)
Alias('unitTests',unitTests)
Command('run_unitTests', unitTests, './$SOURCE')
VariantDir(buildDirectory + '/UnitTests/source', '#/source', duplicate=0)

integrationTests = SConscript('SConscripts/IntegrationTests', variant_dir=buildDirectory + '/IntegrationTests', duplicate=0)
Alias('integrationTests', integrationTests)
Command('run_integrationTests', integrationTests, './$SOURCE')
VariantDir(buildDirectory + '/IntegrationTests/source', '#/source', duplicate=0)

Default(['run_unitTests', 'run_integrationTests'])

Clean('.', buildDirectory)
