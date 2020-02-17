#Requires -Version 5.1

#region Import external script
Import-Module $(Get-Item $PSScriptRoot\bin\* -Include *.ps1, *.psm1 -Exclude *-Help.ps1, *-Format.ps1, *-Type.ps1)
# Add ConvertTo-PSTypeXml
#endregion Import external script

function New-PSDevEnvironment {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline)]
        [string]$Path = $PWD
    )

    Push-Location
    Set-Location $Path

    $null = New-Item .\bin -ItemType Directory -Force
    Copy-Item $PSScriptRoot\.vscode -Destination .\ -Recurse -Force
    $Leaf = Split-Path $PWD -Leaf

    "# psdev-help" | Out-File bin\$Leaf-Help.ps1
    "# psdev-format" | Out-File bin\$Leaf-Format.ps1
    "# psdev-type" | Out-File bin\$Leaf-Type.ps1
    "# PSDev-Build" | Out-File build.ps1
    @(
        "#region Import external script"
        'Import-Module $(Get-Item .\bin\* -Include *.ps1, *.psm1 -Exclude *-Help.ps1, *-Format.ps1, *-Type.ps1)'
        "#endregion Import external script`n"
    ) | Out-File "$Leaf.psm1"
    Write-Verbose "Creat powershell module development enviroment"
    Pop-Location
}

function New-PSDevExternalFile {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Position = 0)]
        [ValidateSet("Build", "Help", "Format", "Type", "MainPsm1")]
        [string[]]$FileList,

        [Parameter(Position = 1)]
        [string]$Path = $PWD,

        [switch]$Force
    )

    begin {
        Push-Location
        Set-Location $Path
        $Leaf = Split-Path $PWD -Leaf
        [scriptblock]$WhetherOverwrite = {
            param(
                [string]$Name,
                [string]$Content
            )
            if ($Force) { return $true }
            (Test-Path build.ps1) -and $PSCmdlet.ShouldContinue(
                "  Whether to overwrite path $PWD\$Name",
                "Please choose:"
            )
        }
    }

    process {
        foreach ($item in $FileList) {
            switch ($item) {
                Build {
                    if (-not $(& $WhetherOverwrite -Name build.ps1)) { break }
                    "# PSDev-Build" | Out-File build.ps1
                }
                Help {
                    if (-not $(& $WhetherOverwrite -Name bin\$Leaf-Help.ps1)) { break }
                    "# psdev-help" | Out-File bin\$Leaf-Help.ps1
                }
                Format {
                    if (-not $(& $WhetherOverwrite -Name bin\$Leaf-Format.ps1)) { break }
                    "# psdev-format" | Out-File bin\$Leaf-Format.ps1
                }
                Type {
                    if (-not $(& $WhetherOverwrite -Path $PWD -Name bin\$Leaf-Type.ps1)) { break }
                    "# psdev-type" | Out-File bin\$Leaf-Type.ps1
                }
                Default {
                    Write-Warning "$item is unknow value"
                }
            }
        }
    }

    end {
        Pop-Location
    }
}

# Set export function
Export-ModuleMember -Function @(
    "Resolve-PSIndentSyntax"
    "ConvertTo-PSHelpXml"
    "ConvertTo-PSFormatXml"
    "ConvertTo-PSTypeXml"
    "New-PSDevEnvironment"
    "New-PSDevExternalFile"
)
