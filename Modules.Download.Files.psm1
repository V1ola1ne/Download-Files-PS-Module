#Requires -Modules Microsoft.PowerShell.ThreadJob -Version 2.2.0

function Invoke-FileDownload {

    [CmdletBinding()]
    param(

        [Parameter(ValueFromPipeline = $true, Mandatory, Position = 0)]                                         # Provide all links, from which you want to Download files. These must be direct File links.
        [array]$link,

        [Parameter(Mandatory, Position = 1)]                                                                    # Provide the Folder to which you want to Download you files.
        [string]$DownloadDirectory,

        [switch]$UnZip,                                                                                         # If this Parameter is Specified, .Zip Files will be automatically unzipped

        [array]$DownloadFile

    )


    Import-Module Microsoft.PowerShell.ThreadJob                                                                # Import the ThreadJob Module to ensure Execution


    class DownloadFile {                                                                                        # Class which contains Download Methods

        static [object] ZipDownload([string]$uri, [string]$DownloadPath) {                                      # Method used, when -UnZip Parameter is used
            
            return Start-ThreadJob {                                                                            # Initialize a thread job and return it
                
                $uri = $Using:uri                                                                               # Make Method Parameters usable in Job.
                
                $DownloadPath = $Using:DownloadPath
                
                Invoke-WebRequest -Uri $uri -OutFile $DownloadPath                                              # Start the Web Request and send it to the Specified Path, then

                Expand-Archive -Path $DownloadPath -DestinationPath $DownloadPath.Replace(".zip", '')           # Extract the Archive to a Folder, which is derived from the File Name
                
                [System.IO.File]::Delete("$DownloadPath")                                                       # And remove the downloaded Zip File and only leave the new Folder

            } 

        }
    
        static [object] FileDownload([string]$uri, [string]$DownloadPath) {                                     # Method used, by Default

            return Start-ThreadJob {                                                                            # Initialize a thread job and return it
                
                $uri = $Using:uri                                                                               # Make Method Parameters usable in Job.
                
                $DownloadPath = $Using:DownloadPath
                
                Invoke-WebRequest -Uri $uri -OutFile $DownloadPath                                              # Start the Web Request and send it to the Specified Path

            }

        }

    }

    
    [System.Console]::WriteLine("Downloading files, from specified links...")                                   # Write this string to the Console
    
    $Jobs = foreach ($uri in $link) {                                                                           # Send all "Job-Objects, created by the Loop to this variable"
        
        Write-Verbose "Attempt to download from '$uri'"

        if ($null -ne $DownloadFile[$link.IndexOf("$uri")]) {                                                   # If a Name exist at the current Link index
        
            if (-not [System.IO.File]::Exists("$DownloadDirectory\$($DownloadFile[$link.IndexOf("$uri")])")) {  # And if a File with the specified File Name, at the current index, does not already Exist

                $FileName = $DownloadFile[$link.IndexOf("$uri")]                                                # use this, instead of trying to extract a name from the link

            }
            
        } else {                                                                                                # If an Index match could not be found (i.e. no further Name is given)
                    
            $FileName = ($uri -split "/")[(($uri -split "/").Length -1)]                                        # Get the File Name, from the link.

            if ($FileName -match ".7z\?") {                                                                     # If a File Link matches the Pattern ".7z?", then
        
                $FileName = ($FileName -split "\?")[0]                                                          # Split the File at the QuestionMark and Select only the First Part of this
        
            }

        }

        Write-Verbose "Downloading to file '$FileName'"
        
        $DownloadPath = $DownloadDirectory, $FileName -join "\"                                                 # Create a useable Download Path from the Extracted File Name and the Download Directory
        
        if (($FileName -match ".zip$") -and $UnZip) {                                                           # When the File-Extension matches .zip, then

            try {

                [DownloadFile]::ZipDownload($uri, $DownloadPath)                                                # Use the ZipDownload() Method of the [DownloadFile] class with the Provided Parameters.
            
            }
            catch {
            
                throw $Error                                                                                    # if an error occurs (which should never happen), end the Script and show all Errors that have since occured
            
            }

        } else {

            try {
            
                [DownloadFile]::FileDownload($uri, $DownloadPath)                                               # Use the FileDownload() Method of the [DownloadFile] class with the Provided Parameters
            
            }
            catch {
            
                throw $Error                                                                                    # if an error occurs (which should never happen), end the Script and show all Errors that have since occured
            
            }

        }

    }
    
    $null = $Jobs | Wait-Job                                                                                    # Wait for all Jobs to finish Downloading. This is not strictly necessary, but will stop you from using the Files in other Scripts
    
    [System.Console]::WriteLine("`nAll files have been downloaded. Please checkout '$DownloadDirectory' ...")   # Please check if the File Download was successfull

}