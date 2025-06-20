# Download-Files PS-Module

This is a Module for Powershell, which, when imported, provides you with a single function, you can use, to Download direct File links to a specific directory.

## Requirements

    Microsoft.PowerShell.ThreadJob -> Newest Version
        
        This Module is what makes the Module differ from default Behavoir. Without Thread-jobs this whole thing would not work.

### How to install

Open Powershell and type the following Command

    Install-Module Microsoft.Powershell.ThreadJob

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

Keep in Mind that the Module currently only works with files, to which you don't need any Authentication
Adding the Option for Authentication may come in Future Releases.
