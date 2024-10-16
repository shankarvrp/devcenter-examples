param (
    [Parameter()]
    [string]$SourceURL,
    [Parameter()]
    [string]$Package,
    [Parameter()]
    [string]$Version,
    [Parameter()]
    [string]$DestinationDirectory,
    [Parameter()]
    [string]$FileExtension
)

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

if($SourceURL -ne "" -and $Package -ne "" -and $DestinationDirectory -ne "") {
    $SourceURL = $SourceURL.TrimEnd('/')
    $packageFileURL = "$SourceURL/$Package"
    Write-Host "packageFileURL:$packageFileURL"

    if(!(Test-Path $DestinationDirectory)) {
        New-Item $DestinationDirectory -ItemType Directory
    }

    $zipFile = Join-Path $DestinationDirectory "$Package"

    if(!(${env:REPO-GET-SECRET})){
		 Write-Host "No Secret!"
		 Write-Host  $packageFileURL
		 Write-Host $zipfile
        Invoke-RestMethod $packageFileURL -OutFile $zipFile
    }else{
        Invoke-RestMethod -Headers @{Authorization=('Basic {0}' -f ${env:REPO-GET-SECRET})} $packageFileURL -OutFile $zipFile
    }

    if(Test-Path $zipfile){
		 Write-Host "Zip file exists"
        $packageFolder = "$DestinationDirectory/$Package" 
		
		 if($FileExtension -eq "zip"){
            Unzip $zipFile "$DestinationDirectory" 
        }
		
         if(Test-Path $packageFolder) {
             Remove-Item $packageFolder -Force -Recurse
         }
        
       
    }else{
        Write-Host "Cannot download the zip file: $packageFileURL to $zipFile"
    }
} else {
    Write-Host "SourceURL, Package, Version and DestinationDirectory are not expected. SourceURL: $SourceURL, Package: $Package, DestinationDirectory: $DestinationDirectory"
}
