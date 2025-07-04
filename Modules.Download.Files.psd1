#
# Module Manifest for Modules.Download.Files
#
# Generated by V1ola1ne
#
# Generated on 20.06.2024
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule = "Modules.Download.Files.psm1"

    # Author of this module
    Author = 'V1ola1ne'

    GUID = '476c926c-408b-41bf-9e23-6c00ca34e3f2'

    # Version number of this module.
    ModuleVersion = '1.0.1'

    # Description of the functionality provided by this module
    Description = '
    This provides the (almost) fastest Way to Download Files trough Powershell.
    for further Information visit the Project-Repo and check out the wiki, at https://github.com/V1ola1ne/Download-Files-PS-Module/wiki
    '

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @('Invoke-FileDownload')

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    AliasesToExport = @()

    # Modules Required to Work
    RequiredModules = @('Microsoft.PowerShell.ThreadJob')


    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/V1ola1ne/Download-Files-PS-Module'
            
            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/V1ola1ne/Download-Files-PS-Module/releases/tag/v1.0.1'

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # A URL to get more information about this module
    HelpInfoURI = 'https://github.com/V1ola1ne/Download-Files-PS-Module/wiki'

}