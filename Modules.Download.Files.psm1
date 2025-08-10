#Requires -Modules Microsoft.PowerShell.ThreadJob


function Get-FileNameFromURI {
    
    [CmdletBinding()]
    param (

        [Parameter(Mandatory, Position = 0)]
        [string]$InputObject

    )

    $uri = $InputObject
    $FileName = ($uri -split "/")[$_.Length -1]                                                         # Get the File Name, from the link.

    if ($FileName -match ".7z\?") {                                                                     # If a File Link matches the Pattern ".7z?", then
        
        $FileName = ($FileName -split "\?")[0]                                                          # Split the File at the QuestionMark and Select only the First Part of this
        
    } elseif ($FileName -match "\..{0,}\?") {

        $FileName = ($FileName -split "\?")[0]

    }

    return $FileName


}

function Get-NameFromInput {

    param (

        [Parameter(ValueFromPipeline = $true, Mandatory, Position = 0)]
        [array]$link,

        [parameter(Mandatory, Position = 1)]
        [string]$DownloadDirectory,

        [array]$DownloadFile,

        [string]$uri

    )

    if ($DownloadFile) {

        $index = $link.IndexOf("$uri")

        if ($DownloadFile[$index]) {                                                             # If a Name exist at the current Link index
    
            if (-not [System.IO.File]::Exists("$DownloadDirectory\$($DownloadFile[$index])")) {  # And if a File with the specified File Name, at the current index, does not already Exist

                $FileName = $DownloadFile[$index]                                                # use this, instead of trying to extract a name from the link

                Write-Verbose "Downloading to file '$FileName'"

            }
        
        } else {                                                                                                # If an Index match could not be found (i.e. no further Name is given)
                
            $FileName = $null

        }

    } else {

        $FileName = $null

    }

    return $FileName

}

function Get-NameFromRequest {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [hashtable]$Headers,
        
        [string]$uri,

        [string]$tmp

    )

    if ($Headers.Values -match "filename") {                                                # If a FileName is available

        $NameSplit = $Headers.Values -match "filename" -split "="                           # Select the FileName specified inside the Request Header
        $FileName = $NameSplit[$NameSplit.Length - 1]

        if ($FileName -match '"') {                                                         # If the FileName is given with parenthesis

            $FileName = $FileName -replace '"', ''                                          # remove them
        }

    } else {                                                                                # If no FileName was found in the request

        try {
                
            $FileName = Get-FileNameFromURI -InputObject $uri -ErrorAction Stop             # Try to get it from the Url

        }
        catch {

            [System.Object]$Message = $_.Exception.Message
            [System.Object]$PositionMessage = $_.InvocationInfo.PositionMessage
            [System.Object]$record = @($Message, $PositionMessage)
            [System.IO.File]::AppendAllText($tmp, "$($record | out-string)`n")              # When an Error has occured, the Script will write its information to a temporary file

        }

    }

    return $FileName
}


class DownloadFile {                                                                                        # Class which contains Download Methods
  
    static [object] ThreadedFileDownload([string]$uri, [string]$DownloadDirectory, [string]$FileName, [bool]$uzip, [array]$def) {                                     # Method used, by Default

        return Start-ThreadJob {                                                                            # Initialize a thread job and return it
            
            $uri = $Using:uri                                                                               # Make Method Parameters usable in Job.
            $DownloadDirectory = $Using:DownloadDirectory
            $tmp = $Using:tmp
            $FileName =$Using:FileName
            $UnZip = $Using:uzip
            ${function:Get-NameFromRequest}, ${function:Get-FileNameFromURI} = $Using:def
            
            try {

                $request = Invoke-WebRequest -Uri $uri -ErrorAction Stop                                    # Start the Web Request and send it to the Specified Path, then  

                $Content = $request.Content                                                                 # Collect the content
                $Headers = $request.Headers                                                                 # Get Header Information
                $contentType = $Headers.'Content-Type'                                                      # Get ContentType Information

                if (-not $FileName) {
   
                    try {

                        $FileName = Get-NameFromRequest -Headers $Headers -uri $uri -tmp $tmp -ErrorAction Stop

                    }
                    catch {

                        [System.Object]$Message = $_.Exception.Message
                        [System.Object]$PositionMessage = $_.InvocationInfo.PositionMessage
                        [System.Object]$record = @($Message, $PositionMessage)
                        [System.IO.File]::AppendAllText($tmp, "$($record | out-string)`n")                    # When an Error has occured, the Script will write its information to a temporary file
            
                    }

                }

                $DownloadPath = $DownloadDirectory, $FileName -join '\'                                     # Create the Download Path
                $FileContent = $Content

                Write-Verbose "Downloading File '$FileName' to $DownloadDirectory"

                if ($ContentType -notmatch "text/") {

                    $File = [System.IO.File]::Create("$DownloadPath")                                           # Create the File
                    $File.Write($FileContent, 0, $FileContent.Length)                                           # Write the WebRequestContent to it
                    $File.Close()                                                                               # Close the File, so that it can be used later

                } elseif ($contentType -match "text/") {

                    [System.IO.File]::WriteAllText($DownloadPath, "$FileContent")

                }

                if ($FileName -match "zip$" -and $UnZip) {                                                      # if the unzip parameter is given and the .zip file Type was detected

                    try {

                        Expand-Archive -Path $DownloadPath -DestinationPath $DownloadPath.Replace(".zip", '') -ErrorAction Stop # Extract the Archive to a Folder, which is derived from the File Name
                        [System.IO.File]::Delete("$DownloadPath")                                             # And remove the downloaded Zip File and only leave the new Folder

                    }
                    catch {
            
                        [System.Object]$Message = $_.Exception.Message
                        [System.Object]$PositionMessage = $_.InvocationInfo.PositionMessage
                        [System.Object]$record = @($Message, $PositionMessage)
                        [System.IO.File]::AppendAllText($tmp, "$($record | out-string)`n")                    # When an Error has occured, the Script will write its information to a temporary file
            
                     }

                } elseif ($FileName -match "7z$" -and $UnZip) {                                               # if the unzip parameter is given and the .zip file Type was detected

                    try {

                        Expand-Archive -Path $DownloadPath -DestinationPath $DownloadPath.Replace(".7z", '') -ErrorAction Stop # Extract the Archive to a Folder, which is derived from the File Name
                        [System.IO.File]::Delete("$DownloadPath")                                             # And remove the downloaded Zip File and only leave the new Folder

                    }
                    catch {
            
                        [System.Object]$Message = $_.Exception.Message
                        [System.Object]$PositionMessage = $_.InvocationInfo.PositionMessage
                        [System.Object]$record = @($Message, $PositionMessage)
                        [System.IO.File]::AppendAllText($tmp, "$($record | out-string)`n")                    # When an Error has occured, the Script will write its information to a temporary file
            
                    }


                }

            }
            catch {
            
                [System.Object]$Message = $_.Exception.Message
                [System.Object]$PositionMessage = $_.InvocationInfo.PositionMessage
                [System.Object]$record = @($Message, $PositionMessage)
                [System.IO.File]::AppendAllText($tmp, "$($record | out-string)`n")                            # When an Error has occured, the Script will write its information to a temporary file
            
            }

        }

    }

    static [object] UnThreadedFileDownload([string]$uri, [string]$DownloadDirectory, [string]$FileName, [bool]$uzip, [array]$def) {

        return $(

            ${function:Get-NameFromRequest}, ${function:Get-FileNameFromURI} = $def

            try {

                $request = Invoke-WebRequest -Uri $uri -ErrorAction Stop

                $Content = $request.content
                $Headers = $request.Headers
                $contentType = $Headers.'Content-Type'                                                      # Get ContentType Information

                if (-not $FileName) {

                    try {

                        $FileName = Get-NameFromRequest -Headers $Headers -uri $uri -ErrorAction Stop

                    }
                    catch {
                        
                    }

                }

                
                $DownloadPath = $DownloadDirectory, $FileName -join '\'                                     # Create the Download Path
                $FileContent = $Content

                Write-Verbose "Downloading File '$FileName' to $DownloadDirectory"

                if ($ContentType -notmatch "text/") {

                    $File = [System.IO.File]::Create("$DownloadPath")                                           # Create the File
                    $File.Write($FileContent, 0, $FileContent.Length)                                           # Write the WebRequestContent to it
                    $File.Close()                                                                               # Close the File, so that it can be used later

                } elseif ($contentType -match "text/") {

                    [System.IO.File]::WriteAllText($DownloadPath, "$FileContent")

                }

                Write-Verbose "Download Finished"

                if ($FileName -match "zip$" -and $uzip) {                                                      # if the unzip parameter is given and the .zip file Type was detected

                    try {

                        Write-Verbose "Unzipping Zip File"

                        Expand-Archive -Path $DownloadPath -DestinationPath $DownloadPath.Replace(".zip", '') -ErrorAction Stop # Extract the Archive to a Folder, which is derived from the File Name
                        [System.IO.File]::Delete("$DownloadPath")                                             # And remove the downloaded Zip File and only leave the new Folder

                    }
                    catch {
            
                    }

                } elseif ($FileName -match "7z$" -and $uzip) {                                               # if the unzip parameter is given and the .zip file Type was detected

                    try {

                        Write-Verbose "Unzipping 7z File"

                        Expand-Archive -Path $DownloadPath -DestinationPath $DownloadPath.Replace(".7z", '') -ErrorAction Stop # Extract the Archive to a Folder, which is derived from the File Name
                        [System.IO.File]::Delete("$DownloadPath")                                             # And remove the downloaded Zip File and only leave the new Folder

                    }
                    catch {

                    }

                } else {

                    Write-Verbose "The Unzip Parameter was not used or the file was not a Zip file, continuing..."

                }
                
            }
            catch {
                <#Do this if a terminating exception happens#>
            }

        )

    }

}

function Start-ThreadedOperation {

    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory, Position = 0)]
        [array]$link,

        [parameter(Mandatory, Position = 1)]
        [string]$DownloadDirectory,

        [bool]$UnZip,

        [array]$DownloadFile,

        [array]$def

    )

    $tmp = New-TemporaryFile                                                                                    # Create the Temporary File for error handling

    $Jobs = foreach ($uri in $link) {                                                                           # Send all "Job-Objects, created by the Loop to this variable"
        
        Write-Verbose "Attempt to download from '$uri'"

        $FileName = Get-NameFromInput -link $link -DownloadDirectory $DownloadDirectory -DownloadFile $DownloadFile -uri $uri

        Write-Verbose "Starting Download..."
        
        [DownloadFile]::ThreadedFileDownload($uri, $DownloadDirectory, $FileName, $UnZip, $def)                 # Use the FileDownload() Method of the [DownloadFile] class with the Provided Parameters

    }
    
    $null = $Jobs | Wait-Job                                                                                    # Wait for all Jobs to finish Downloading. This is not strictly necessary, but will stop you from using the Files in other Scripts
    
    $size = [System.IO.FileInfo]::new($tmp).Length                                                              # Get File Information of the Temporary File

    if ($size -gt 0) {                                                                                          # Test, if errors have been added.

        $errorlist = [System.IO.File]::ReadAllText($tmp)                                                        # if so, read all contents and
        [System.Console]::WriteLine("Download could not finish. Some Errors have occured`n")                    # Display this message
        [System.Console]::ForegroundColor = [System.ConsoleColor]::Red                                          
        [System.Console]::Write("$errorlist")                                                                   # Display all Error information
        [System.Console]::ResetColor()

    } else {

        [System.Console]::WriteLine("`nAll files have been downloaded. Please checkout '$DownloadDirectory' ...")# Please check if the File Download was successfull
        
    }

    $null = [System.IO.File]::Delete($tmp)                                                                      # Silently Remove the Temporary File

}

function Start-UnThreadedOperation {

    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory, Position = 0)]
        [array]$link,

        [parameter(Mandatory, Position = 1)]
        [string]$DownloadDirectory,

        [bool]$UnZip,

        [array]$DownloadFile,

        [array]$def

    )

    foreach ($uri in $link) {

        Write-Verbose "Attempt to download from '$uri'"

        $FileName = Get-NameFromInput -link $link -DownloadDirectory $DownloadDirectory -DownloadFile $DownloadFile -uri $uri

        Write-Verbose "Starting Download..."

        [DownloadFile]::UnThreadedFileDownload($uri, $DownloadDirectory, $FileName, $UnZip, $def)                     # Use the UnThreadedFileDownload() Method of the [DownloadFile] class with the Provided Parameters

    }

    [System.Console]::WriteLine("`nAll files have been downloaded. Please checkout '$DownloadDirectory' ...")        # Please check if the File Download was successfull

}


function Invoke-FileDownload {

    [CmdletBinding()]
    param(

        [Parameter(ValueFromPipeline = $true, Mandatory, Position = 0)]                                         # Provide all links, from which you want to Download files. These must be direct File links.
        [array]$link,

        [Parameter(Mandatory, Position = 1)]                                                                    # Provide the Folder to which you want to Download you files.
        [string]$DownloadDirectory,

        [switch]$UnZip,                                                                                         # If this Parameter is Specified, .Zip Files will be automatically unzipped

        [array]$DownloadFile,

        [ValidateSet("Threaded", "UnThreaded")]
        [string]$Mode = "Threaded"

        

    )

    $def = ${function:Get-NameFromRequest}.ToString(), ${function:Get-FileNameFromURI}.ToString()

    if (![System.IO.Directory]::Exists("$DownloadDirectory")) {

        $null = [System.IO.Directory]::CreateDirectory("$DownloadDirectory")

    }

    [System.Console]::WriteLine("Downloading files ({0}), from specified links...", $link.Count)                    # Write this string to the Console
    
    if ($Mode -match "^Threaded") {

        Import-Module Microsoft.PowerShell.ThreadJob                                                                # Import the ThreadJob Module to ensure Execution

        Start-ThreadedOperation -link $link -DownloadDirectory $DownloadDirectory -UnZip $UnZip -DownloadFile $DownloadFile -def $def

    } elseif ($Mode -match "^UnThreaded") {

        Start-UnThreadedOperation -link $link -DownloadDirectory $DownloadDirectory -UnZip $UnZip -DownloadFile $DownloadFile -def $def

    }
    
}