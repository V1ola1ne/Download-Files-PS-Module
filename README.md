# Download-Files PS-Module

This is a Module for Powershell, which, when imported, provides you with a single function, you can use, to Download direct File links to a specific directory.

## Requirements

    Microsoft.PowerShell.ThreadJob -> Newest Version
        
        This Module is what makes the Module differ from default Behavoir. Without Thread-jobs this whole thing would not work.

### How to install requirements

Open Powershell and type the following Command

    Install-Module Microsoft.Powershell.ThreadJob


## How to install

After Downloading the Release, extract it.
You can no do tow things:

either
1. Open Powershell and type:

       env:PSModulePath
   
    This will display the Folders, from which powershell is able to directly import Modules
    Go to one off the Specified folder and inside of it, create an new folder named\
    `Modules.Download.Files`\
    Place `Modules.Download.Files.psm1` and `Modules.Download.Files.psd1` inside this Folder.\
    Now you should be able to import the module by using:

       Import-Module Modules.Download.Files

or

2. Do what-ever you want with the files.
   Just remember when importing the Module you have to import it like this:

       Import-Module YOURMODULEPATH\Modules.Download.Files.psd1


### Additional Info

You could add the Import command to an exisisting Profile, or create a new one, which
contains it.
Do this, when you want to make sure, you always have access to the provided function

## Why does this exist?

Downloading files through the default Powershell way, (with "Invoke-WebRequest") is extremly slow. Using a special Technique you can increase the Download Speed by a factor of at least 10x.
This makes this module (almost) the absolute Fastest Way, to Download a File, from the internet, or any Weblink, with Powershell.
If you Remove everything around it and just use the Core Methods, you can Download even Faster, However that benefit is rather Small

## How to use

### Parameters

    -link <string> 
        this is a direct link to a file. It may look like this "https://example.com/test.txt"

    -DownloadDirectory <string>
        This is the Directory to which you want to Download the file.

    -UnZip <switch>
        Using this parameter, the Script will unzip any File, with the .zip File extension. (May also work von .rar or .7z files, but untested)

    -DownloadFile <string> 
        This is the Name of the Donwloaded file, in your File-System. Usefull when the function is unable to get an Name from the link

### Usage

If you have a direct file link, use the -link and -DownloadDirectory parameters to get Download the File from the Direct file link

Keep in Mind that the Module currently only works with files, for which you don't need any Authentication
Adding the Option for Authentication may come in Future Releases.

Also keep in Mind, that the Module is currently not singed in any way, which means, that you may have to circumvent default windows Protections
To do so use

    Set-ExecutionPolicy
