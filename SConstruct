buildDirectory = 'Build'

environment = Environment(
    tools=['ldc', 'link'],
)

Export('environment')

Alias('release', SConscript('SConscripts/Release', variant_dir=buildDirectory + '/Release', duplicate=0))

Alias('unitTests', SConscript('SConscripts/UnitTests', variant_dir=buildDirectory + '/UnitTests', duplicate=0), '$TARGET')

Alias('integrationTests', SConscript('SConscripts/IntegrationTests', variant_dir=buildDirectory + '/IntegrationTests', duplicate=0), '$TARGET')

Default(['unitTests', 'integrationTests'])

Clean('.', buildDirectory)
