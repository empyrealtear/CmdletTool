#Requires -Assembly ./PSModuleDevTool.psm1

[CmdletBinding()]
Param(
    [Parameter()]
    [switch]$Release
)

$Leaf = Split-Path $PSScriptRoot -Leaf
Push-Location
Set-Location $PSScriptRoot

#region <code>
# Creat *.psd1
New-ModuleManifest "$Leaf.psd1" `
    -RootModule "$Leaf.psm1" `
    -Guid "3f507e4a-1e3c-41de-b95c-dd921fb879d4" `
    -ModuleVersion "1.0.0.1" `
    -Author "Empyrealtear" `
    -CompanyName "None" `
    -ProjectUri "https://github.com/empyrealtear/PSModuleDevTool" `
    -IconUri "https://raw.githubusercontent.com/empyrealtear/PSModuleDevTool/master/asset/psdev.ico" `
    -LicenseUri "https://github.com/empyrealtear/PSModuleDevTool/blob/master/LICENSE" `
    -ReleaseNotes "https://github.com/empyrealtear/PSModuleDevTool/blob/master/CHANGELOG.md" `
    -Description "Build a development enviroment for powershell module" `
    -Tags @("module", "ps1xml", "development")
Update-ModuleManifest -Path "$Leaf.psd1"
Write-Verbose "Build $Leaf.psd1"

# *-Help.xml, *.format.ps1xml
Import-Module .\PSModuleDevTool.psm1
ConvertTo-PSHelpXml -Path "bin\$Leaf-Help.ps1" -OutXml "$Leaf-Help.xml"
Write-Verbose "Build $Leaf-Help.xml"
# ConvertTo-PSFormatXml -Path "bin\$Leaf-Foramt.ps1" -OutXml "$Leaf.format.ps1xml"
# Write-Verbose "Build $Leaf.format.ps1xml"
# ConvertTo-PSTypeXml -Path "bin\$Leaf-Type.ps1" -OutXml "$Leaf.types.ps1xml"
# Write-Verbose "Build $Leaf.types.ps1xml"
Remove-Module PSModuleDevTool
#endregion </code>

if ($Release) {
    powershell.exe -NoLogo -ExecutionPolicy ByPass -Command {
        $Leaf = Split-Path $PWD -Leaf
        $DestPath = "$($HOME)\Documents\WindowsPowerShell\Modules"
        Remove-Item "$DestPath\$Leaf" -Recurse -Force
        Copy-Item $PWD -Destination $DestPath -Recurse -Force
    }
    Write-Verbose "Copy to $($HOME)\Documents\WindowsPowerShell\Modules\$Leaf"
}
Pop-Location
