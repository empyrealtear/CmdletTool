function Add-ChildNode {
    <#
    .Description
        Add a child node to root node
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Name,

        [Parameter(Position = 1)]
        [Alias("Text")]
        [string]
        $InnerText,

        [Parameter(Position = 2)]
        [Alias("NameSpace", "URI")]
        [string]
        $NamespaceURI,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root,

        [switch]$OutNull,

        [Alias("rm", "Remove", "RemoveNullNode")]
        [switch]$RemoveNull
    )

    process {
        $IsNameNull = [string]::IsNullOrEmpty($Name)
        $IsTextNull = [string]::IsNullOrEmpty($InnerText)
        if ($IsNameNull -or $($RemoveNull -and $IsTextNull)) {
            return
        }

        $ChildNode = $Root.AppendChild(
            $Script:doc.CreateElement($Name, $NamespaceURI))
        if (-not $IsTextNull) {
            $ChildNode.InnerText = $InnerText
        }

        if (-not $OutNull) {
            Write-Output $ChildNode
        }
    }
}

function Resolve-PSIndentSyntax {
    <#
    .Description
        Resolve content by different indent and colon
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string[]]
        $Content,

        [Parameter(Position = 1)]
        [string]
        $CommentPattern = "^\s*#\s?",

        [Parameter(Position = 2)]
        [string]
        $PropertyPattern = "^\S",

        [Parameter(Position = 3)]
        [string[]]
        $Exclude,

        [switch]$StrArrayToRaw,
        [switch]$Recurse
    )

    $Content = $Content | Where-Object { $_ }

    if ($Content.Count -eq 0) {
        return
    }

    $Add_Hash = {
        $NowRecurse = if ($null -ne $Exclude) {
            $Name -notmatch $($Exclude -join "|")
        }
        else {
            $Recurse
        }
        if ($null -eq $Value -and $Name.IndexOf(":") -gt 0) {
            [string[]]$Temp = $Name.Split(":", 2).Trim() | Where-Object { $_ }
            $Name = $Temp[0]
            $Value = switch -Regex ($Temp[1]) {
                "^\d+$" { [int]$Temp[1] }
                "^true|false$" { [bool]::Parse($Temp[1]) }
                Default { $Temp[1] }
            }
        }
        elseif ($NowRecurse -and $($Value -match "^\s+\S|^\w+\s+:").Count -gt 0) {
            $Value = Resolve-PSIndentSyntax -Content $Value -Recurse:$NowRecurse `
                -Exclude $Exclude -StrArrayToRaw:$StrArrayToRaw
        }

        if ($StrArrayToRaw -and $Value -is [string[]]) {
            $Value = $Value -join "`n"
        }

        if ($Hash.Contains($Name)) {
            $Hash[$Name] = $($Hash[$Name]; $Value)
        }
        else {
            $Hash.Add($Name, $Value)
        }
    }

    [string]$Name = $null
    [string[]]$Value = $null
    $Hash = [Ordered]@{ }

    if (-not [string]::IsNullOrEmpty($CommentPattern)) {
        $Content = $Content -notmatch $CommentPattern
    }

    foreach ($_ in $Content) {
        if ($_ -match $PropertyPattern) {
            if (-not [string]::IsNullOrEmpty($Name)) {
                & $Add_Hash
                $Value = $null
            }
            $Name = $_.Trim().Trim(".")
            Write-Verbose "> $Name"
        }
        else {
            Write-Verbose "+ $_"
            $Value += [string[]]($_.TrimEnd() -replace "^\s{1,4}", "")
        }
    }

    if (-not [string]::IsNullOrEmpty($Name)) {
        & $Add_Hash
    }

    Write-Output $Hash
}
