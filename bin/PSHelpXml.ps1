#Requires -Assembly 'System.Xml'

#region public
# . $PSScriptRoot\PublicFunction.ps1
#endregion public

#region Add-HelpItemNode
function Script:Add-Paragraph {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("i", "Text", "Content")]
        [string[]]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        foreach ($_ in $InputObject) {
            $Root | Add-ChildNode "maml:para" -InnerText $_ -OutNull
        }
    }
}

function Script:Add-Description {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("i", "Text", "Content")]
        [string[]]
        $InputObject = @(),

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    begin {
        Write-Verbose "Creat xml element - maml:description"
    }

    process {
        $Root |
            Add-ChildNode "maml:description" |
            Script:Add-Paragraph $InputObject
    }
}

function Script:Add-Details {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $CommandName,

        [Parameter(Position = 1)]
        [string[]]
        $Description,

        [Parameter(Position = 2)]
        [string[]]
        $Copyright,

        [Parameter(Position = 3)]
        [string[]]
        $Version,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    begin {
        Write-Verbose "Creat xml element - command:details"
    }

    process {
        $NameCache = $CommandName.Trim().Split(" -", [System.StringSplitOptions]1)
        $DetailsNode = $Root | Add-ChildNode "command:details"

        $DetailsNode | Add-ChildNode "command:name" $($NameCache -join "-") -OutNull
        $DetailsNode | Script:Add-Description $Description
        $DetailsNode |
            Add-ChildNode "maml:copyright" |
            Script:Add-Paragraph $Copyright
        $DetailsNode |
            Add-ChildNode "command:version" |
            Script:Add-Paragraph $Version
        $DetailsNode | Add-ChildNode "command:verb" $NameCache[0] -OutNull
        $DetailsNode | Add-ChildNode "command:noun" $NameCache[1] -OutNull
    }
}

function Script:Add-SyntaxItem {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Name,

        [Parameter(Position = 1)]
        [hashtable[]]
        $Parameters,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    begin {
        Write-Verbose "Creat xml element - command:syntax"
    }

    process {
        $SyntaxItemNode = $Root | Add-ChildNode "command:syntaxItem"
        $SyntaxItemNode | Add-ChildNode "maml:name" $Name -OutNull

        foreach ($item in $Parameters) {
            $SyntaxItemNode | Script:Add-Parameter @item
        }
    }
}

function Script:Add-Parameter {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $ParamName,

        [Parameter(Position = 1)]
        [Alias("Values")]
        [string[]]
        $ParamValues,

        [Parameter(Position = 2)]
        [Alias("Mandatory")]
        [bool]
        $Required,

        [Parameter(Position = 3)]
        [Alias("Wild", "Wildcard", "WildcardChar")]
        [bool]
        $Globbing,

        [Parameter(Position = 4)]
        [Alias("Pipeline")]
        [bool]
        $PipelineInput,

        [Parameter(Position = 5)]
        [ValidatePattern("^\d+|named$")]
        [string]
        $Position = "named",

        [Parameter(Position = 6)]
        [Alias("Default")]
        [string]
        $DefaultValue = "None",

        [Parameter(Position = 6)]
        [string[]]
        $Description,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    begin {
        Write-Verbose "Creat xml element - command:parameter"
    }

    process {
        $ParamNode = $Root | Add-ChildNode "command:parameter"
        $ParamNode.SetAttribute("required", $Required.ToString().ToLower())
        $ParamNode.SetAttribute("position", $Position.ToLower())
        $ParamNode.SetAttribute("globbing", $Globbing.ToString().ToLower())
        $ParamNode.SetAttribute("pipelineInput", $PipelineInput.ToString().ToLower())
        $ParamNode.SetAttribute("variableLength", "true")

        $ParamNode | Add-ChildNode "maml:name" $ParamName -OutNull
        $ParamNode | Script:Add-Description $Description

        if ($ParamValues.Count -eq 1) {
            $NextNode = $ParamNode
        }
        elseif ($ParamValues.Count -gt 1) {
            $NextNode = $ParamNode | Add-ChildNode "command:parameterValueGroup"
        }

        if ($ParamValues.Count -gt 0) {
            foreach ($value in $ParamValues) {
                $ParamValueNode = $NextNode | Add-ChildNode "command:parameterValue" $value
                $ParamValueNode.SetAttribute("required", "true")
                $ParamValueNode.SetAttribute("variableLength", "false")
            }
        }
    }
}

function Script:Add-InputType {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Name")]
        [string]
        $TypeName,

        [Parameter(Position = 1)]
        [Alias("Link")]
        [string]
        $Uri,

        [Parameter(Position = 2)]
        [string[]]
        $Description,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root,

        [Parameter()]
        [switch]$IsReturnValue
    )

    begin {
        $NodeName = if ($IsReturnValue) { "returnValue" } else { "inputType" }
        Write-Verbose "Creat xml element - command:$NodeName"
    }

    process {
        $InputTypeNode = $Root | Add-ChildNode "command:$NodeName"

        $TypeNode = $InputTypeNode | Add-ChildNode "dev:type"
        $TypeNode | Add-ChildNode "maml:name" $TypeName -OutNull
        $TypeNode | Add-ChildNode "maml:uri" $Uri -OutNull

        $InputTypeNode | Script:Add-Description $Description
    }
}

function Script:Add-Example {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Title,

        [Parameter(Position = 1)]
        [Alias("Intro")]
        [string[]]
        $Introduction,

        [Parameter(Position = 2)]
        [string[]]
        $Code,

        [Parameter(Position = 3)]
        [string[]]
        $Remarks,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    begin {
        Write-Verbose "Creat xml element - command:example"
    }

    process {
        $ExampleNode = $Root | Add-ChildNode "command:example"

        $ExampleNode | Add-ChildNode "maml:title" $Title -OutNull
        $ExampleNode |
            Add-ChildNode "maml:introduction" |
            Script:Add-Paragraph $Introduction
        $ExampleNode |
            Add-ChildNode "dev:code" -InnerText ($Code -join " ") -OutNull
        $ExampleNode |
            Add-ChildNode "dev:remarks" |
            Script:Add-Paragraph $Remarks
    }
}

function Script:Add-RelatedLink {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Text")]
        [string]
        $LinkText,

        [Parameter(Position = 1)]
        [string]
        $Uri,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root,

        [switch]$PassThru
    )

    begin {
        Write-Verbose "Creat xml element - maml:navigationLink"
    }

    process {
        $LinkNode = $Root | Add-ChildNode "maml:navigationLink"
        $LinkNode | Add-ChildNode "maml:linkText" $LinkText -OutNull
        $LinkNode | Add-ChildNode "maml:uri" $Uri -OutNull

        if ($PassThru) {
            Write-Output $LinkNode
        }
    }
}

function Script:Add-CommandNode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [hashtable]
        $Details,

        [Parameter(Position = 1)]
        [string[]]
        $Description,

        [Parameter(Position = 2)]
        [hashtable[]]
        $Syntax,

        [Parameter(Position = 3)]
        [hashtable[]]
        $Parameters,

        [Parameter(Position = 4)]
        [hashtable[]]
        $InputTypes,

        [Parameter(Position = 5)]
        [hashtable[]]
        $ReturnValues,

        [Parameter(Position = 6)]
        [hashtable[]]
        $Examples,

        [Parameter(Position = 7)]
        [hashtable[]]
        $RelatedLinks,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    begin {
        Write-Verbose "Creat xml element - command:command"
    }

    process {
        $CommandNode = $Root | Add-ChildNode "command:command"
        $CommandNode.SetAttribute("xmlns:maml", "http://schemas.microsoft.com/maml/2004/10")
        $CommandNode.SetAttribute("xmlns:command", "http://schemas.microsoft.com/maml/dev/command/2004/10")
        $CommandNode.SetAttribute("xmlns:dev", "http://schemas.microsoft.com/maml/dev/2004/10")

        $CommandNode | Script:Add-Details @Details

        if ($null -eq $Description -and $Details.Keys -contains "Description") {
            $Description = $Details.Description
        }
        $CommandNode | Script:Add-Description $Description

        $SyntaxNode = $CommandNode | Add-ChildNode "command:syntax"
        foreach ($syntaxItem in $Syntax) {
            $SyntaxNode | Script:Add-SyntaxItem @syntaxItem
        }

        $ParamsNode = $CommandNode | Add-ChildNode "command:parameters"
        foreach ($param in $Parameters) {
            $ParamsNode | Script:Add-Parameter @param
        }

        $InputTypesNode = $CommandNode | Add-ChildNode "command:inputTypes"
        foreach ($input in $InputTypes) {
            $InputTypesNode | Script:Add-InputType @input
        }

        $ReturnValuesNode = $CommandNode | Add-ChildNode "command:returnValues"
        foreach ($return in $ReturnValues) {
            $ReturnValuesNode | Script:Add-InputType @return -IsReturnValue
        }

        $CommandNode | Add-ChildNode "command:terminatingErrors" -OutNull
        $CommandNode | Add-ChildNode "command:nonTerminatingErrors" -OutNull

        $ExamplesNode = $CommandNode | Add-ChildNode "command:examples"
        foreach ($example in $Examples) {
            $ExamplesNode | Script:Add-Example @example
        }

        $RelatedLinksNode = $CommandNode | Add-ChildNode "command:relatedLinks"
        foreach ($link in $RelatedLinks) {
            $RelatedLinksNode | Script:Add-RelatedLink @link
        }
    }
}

function Add-HelpItemNode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Cmds")]
        [hashtable[]]
        $Commands,

        [Parameter(Position = 1)]
        [string]
        $OutXml
    )

    Write-Verbose "Start converting helpItem"
    $Script:doc = [xml]::new()
    $null = $Script:doc.AppendChild($Script:doc.CreateXmlDeclaration("1.0", "utf-8", $null))
    $helpItems = $Script:doc.AppendChild($Script:doc.CreateElement("helpItems"))
    $helpItems.SetAttribute("xmlns", "http://msh")
    $helpItems.SetAttribute("schema", "maml")

    foreach ($_ in $Commands) {
        $helpItems | Script:Add-CommandNode @_
    }

    if (-not [string]::IsNullOrEmpty($OutXml)) {
        $Script:doc.Save($OutXml)
        Write-Verbose "Save in $OutXml"
    }
}
#endregion Add-HelpItemNode

#region ConvertTo-PSHelpXml
function Script:ConvertTo-Syntax {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $InputObject
    )

    process {
        $InputObject = $InputObject -replace "\s*\n\s*(?=\[*-)", " "
        [string[]]$Syntaxs = $InputObject.Split("`n", [StringSplitOptions]1) |
            ForEach-Object { $_ -replace "\s+(?!\[*-)", "" }
        foreach ($_ in $Syntaxs) {
            $Parameters = $_ -split "\s+(?=\[{0,2}-)"
            $Name = $Parameters[0]
            $Parameters = [string[]]($Parameters | Select-Object -Skip 1)
            $Params =
            for ($i = 0; $i -lt $Parameters.Count; $i++) {
                $Values = $($Parameters[$i] -replace "\[{0,2}-(\w+)\]?([<{]?(\S+)[>}])?\]?", '$1-$3').Split(
                    "-|", [System.StringSplitOptions]1)

                [hashtable]$Param = @{
                    ParamName   = $Values[0]
                    ParamValues = $Values | Select-Object -Skip 1
                }

                $Param.Required = $Parameters[$i] -match "^\[?-\w+\]?$|[>}]$"
                if ($Parameters[$i] -match "\[-\w+\]") {
                    $Param.Position = $i
                }

                Write-Output $Param
            }

            Write-Output @{
                Name       = $Name
                Parameters = $Params
            }
        }
    }
}

function Script:ConvertTo-Parameters {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()]
        [string[]]
        $InputObject
    )

    process {
        if ($null -eq $InputObject) {
            return
        }

        $InputObject = $InputObject | Where-Object { $_ }
        $InputObject =
        foreach ($item in $InputObject) {
            $item = $item.TrimStart()
            switch ($item[0]) {
                "-" {
                    $Cache = $item.Split("-<> ", [System.StringSplitOptions]1)
                    "Parameters"
                    "    ParamName   : $($Cache[0])"
                    "    ParamValues : $($Cache[1])"
                }
                "#" { "    Description : $item" }
                Default { "    $item" }
            }
        }

        $(Resolve-PSIndentSyntax $InputObject $null -Recurse).Parameters
    }
}

function Script:ConvertTo-Examples {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()]
        [string[]]
        $InputObject
    )

    process {
        if ($null -eq $InputObject) {
            return
        }

        $InputObject =
        foreach ($item in $InputObject) {
            switch -Regex ($item) {
                "^\S" {
                    "Examples"
                    "    Title : $item"
                }
                "^\s+(?<Intro>PS\s[^>]+>)\s*(?<Code>.*)" {
                    "    Introduction : $($Matches.Intro)"
                    "    Code    : $($Matches.Code -replace '^+\s*', '')"
                }
                "^\s+\+\s" {
                    "    Code    : $($item.TrimStart())"
                }
                Default {
                    "    Remarks : $($item.TrimStart())"
                }
            }
        }

        $(Resolve-PSIndentSyntax $InputObject $null -Recurse).Examples
    }
}

function Script:ConvertTo-CommandNode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline)]
        [Alias("Contents", "Texts")]
        [AllowEmptyString()]
        [string[]]
        $InputObject
    )

    process {
        $Hash = Resolve-PSIndentSyntax $InputObject -CommentPattern $null

        [Ordered]@{
            Details      = @{
                CommandName = $Hash.Synopsis[0]
                Description = $Hash.Synopsis | Select-Object -Skip 1
            }
            Description  = $Hash.Description
            Syntax       = Script:ConvertTo-Syntax $($Hash.Syntax -join "`n")
            Parameters   = Script:ConvertTo-Parameters $Hash.Parameters
            InputTypes   = @{
                TypeName    = $Hash.Inputs[0]
                Description = $Hash.Inputs | Select-Object -Skip 1
            }
            ReturnValues = @{
                TypeName    = $Hash.Outputs[0]
                Description = $Hash.Outputs | Select-Object -Skip 1
            }
            Examples     = Script:ConvertTo-Examples $Hash.Examples
            RelatedLinks = foreach ($_ in $Hash.RelatedLinks) {
                $link = $_.Split(": ", 2, [System.StringSplitOptions]1)
                @{ LinkText = $link[0]; Uri = $link[1] }
            }
        }
    }
}

function ConvertTo-PSHelpXml {
    [CmdletBinding(DefaultParameterSetName = "LoadFile")]
    param (
        [Parameter(Position = 0, ValueFromPipeline, ParameterSetName = "Load")]
        [string[]]
        $InputObject,

        [Parameter(Position = 0, ValueFromPipeline, ParameterSetName = "LoadFile")]
        [string]
        $Path,

        [Parameter(Position = 1, ValueFromPipeline, ParameterSetName = "LoadFile")]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]
        $Encoding = "UTF8",

        [Parameter(ParameterSetName = "Load")]
        [Parameter(ParameterSetName = "LoadFile")]
        [Alias("Out")]
        [string]
        $OutXml = $($Path -replace "\.\w+$", ".xml")
    )

    if ($($PSCmdlet.ParameterSetName -eq "LoadFile") -and $(Test-Path $Path)) {
        $InputObject =
        if ($Path.EndsWith(".ps1")) {
            [string[]](& $Path)
        }
        else {
            $(Get-Content $Path -Raw -Encoding $Encoding) -split "^(?=\.Synopsis)", 0, "Multiline" |
                Where-Object { $_ }
        }
    }

    $Commands =
    foreach ($item in $InputObject) {
        Script:ConvertTo-CommandNode $item.Split("`n")
    }
    Add-HelpItemNode -Commands $Commands -OutXml $OutXml
}
#endregion ConvertTo-PSHelpXml
