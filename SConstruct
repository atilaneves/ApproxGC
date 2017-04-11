buildDirectory = 'Build'

environment = Environment(
    tools=['ldc', 'link'],
)

Export('environment')


Alias('release', SConscript('SConscripts/Release', variant_dir=buildDirectory + '/Release', duplicate=0))
VariantDir(buildDirectory + '/Release/source', '#/source', duplicate=0)

Alias('unitTests', SConscript('SConscripts/UnitTests', variant_dir=buildDirectory + '/UnitTests', duplicate=0))
VariantDir(buildDirectory + '/UnitTests/source', '#/source', duplicate=0)

Alias('integrationTests', SConscript('SConscripts/IntegrationTests', variant_dir=buildDirectory + '/IntegrationTests', duplicate=0))
VariantDir(buildDirectory + '/IntegrationTests/source', '#/source', duplicate=0)

Default(['unitTests', 'integrationTests'])

Clean('.', buildDirectory)
