#Requires -Modules Microsoft.PowerShell.ThreadJob

function Invoke-FileDownload {

    [CmdletBinding()]
    param(

        [Parameter(ValueFromPipeline = $true, Mandatory, Position = 0)]                         # Provide all links, from which you want to Download files. These must be direct File links.
        [string]$link,

        [Parameter(Mandatory, Position = 1)]                                                    # Provide the Folder to which you want to Download you files.
        [string]$DownloadDirectory,

        [switch]$UnZip,                                                                          # If this Parameter is Specified, .Zip Files will be automatically unzipped

        [string]$DownloadFile

        )


    Import-Module Microsoft.PowerShell.ThreadJob


    class DownloadFile {                                                                                # Class which contains Download Methods

        static [object] ZipDownload([string]$uri, [string]$DownloadPath) {                              # Method used, when -UnZip Parameter is used
            
            return Start-ThreadJob {                                                                    # Initialize a thread job and return it
                
                $uri = $Using:uri                                                                       # Make Method Parameters usable in Job
                
                $DownloadPath = $Using:DownloadPath
                
                Invoke-WebRequest -Uri $uri -OutFile $DownloadPath                                      # Start the Web Request and send it to the Specified Path

                Expand-Archive -Path $DownloadPath -DestinationPath $DownloadPath.Replace(".zip", '')   # Extract the Archive to a Folder, which is derived from the File Name
                
                [System.IO.File]::Delete("$DownloadPath")                                               # Remove the downloaded Zip File and only leave the new Folder
            } 

        }
    
        static [object] FileDownload([string]$uri, [string]$DownloadPath) {                             # Method used, by Default

            return Start-ThreadJob {                                                                    # Initialize a thread job and return it
                
                $uri = $Using:uri                                                                       # Make Method Parameters usable in Job
                
                $DownloadPath = $Using:DownloadPath
                
                Invoke-WebRequest -Uri $uri -OutFile $DownloadPath                                      # Start the Web Request and send it to the Specified Path
            }

        }
    }

    
    [System.Console]::WriteLine("Downloading Files, from Specified links...")                           # Write this string to the Console
    
    $Jobs = foreach ($uri in $link) {                                                                   # Send all "Job-Objects, created by the Loop to this variable"

        if ($DownloadFile) {                                                                            # If Direct Export Name is given

            $FileName = $DownloadFile                                                                   # use this, instead of trying to extract a name from the link
        
        } else {

            $FileName = ($uri -split "/")[(($uri -split "/").Length -1)]                                # Get the File Name, from the link

            if ($FileName -match ".7z\?") {                                                             # If a File Link matches the Pattern ".7z?" do this:
        
                $FileName = ($FileName -split "\?")[0]                                                  # Split the File at the QuestionMark and Select only the First Part of this
        
            }

        }

        $DownloadPath = $DownloadDirectory, $FileName -join "\"                                         # Create a useable Download Path from the Extracted File Name and the Download Directory
        
        if (($FileName -match ".zip$") -and $UnZip) {                                                   # When the File-Extension matches .zip do this:

            try {

                [DownloadFile]::ZipDownload($uri, $DownloadPath)                                        # Use the ZipDownload() Method of the [DownloadFile] class with the Provided Parameters
            
            }
            catch {
            
                throw $Error                                                                            # if an error occurs (which should never happen), end the Script and show all Errors that have since occured
            
            }

        } else {

            try {
            
                [DownloadFile]::FileDownload($uri, $DownloadPath)                                       # Use the FileDownload() Method of the [DownloadFile] class with the Provided Parameters
            
            }
            catch {
            
                throw $Error                                                                            # if an error occurs (which should never happen), end the Script and show all Errors that have since occured
            
            }
        }
    }
    
    $null = $Jobs | Wait-Job                                                                            # Wait for all Jobs to finish Downloading. This is not strictly necessary, but will stop you from using the Files in other Scripts
    
    [System.Console]::WriteLine("`nAll Files have been Donwloaded. Please checkout '$DownloadDirectory' ...")# Please check if the File Download was successfull

}