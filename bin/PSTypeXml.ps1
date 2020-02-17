#Requires -Assembly 'System.Xml'

#region public
# . $PSScriptRoot\PublicFunction.ps1
#endregion public

#region Add-Node
function Script:Add-AliasPropertyNode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Name,

        [Parameter(Position = 1)]
        [Alias("Refer")]
        [string]
        $ReferMemberName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        if ([string]::IsNullOrEmpty($Name)) {
            return
        }

        $AliasNode = $Root | Add-ChildNode "AliasProperty"
        $AliasNode | Add-ChildNode "Name" -InnerText $Name -OutNull
        $AliasNode | Add-ChildNode "ReferencedMemberName" -InnerText $ReferMemberName -OutNull
    }
}

function Script:Add-ScriptPropertyNode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Name,

        [Parameter(Position = 1)]
        [Alias("Script")]
        [string]
        $GetScriptBlock,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        if ([string]::IsNullOrEmpty($Name)) {
            return
        }

        $ScriptNode = $Root | Add-ChildNode "ScriptProperty"
        $ScriptNode | Add-ChildNode "Name" -InnerText $Name -OutNull
        $FormatScript = $GetScriptBlock.Split("`n").Trim() | Where-Object { $_ }
        $GetScriptBlock = $(""; $FormatScript; "") -join "`n$("`t" * 4)"
        $ScriptNode | Add-ChildNode "GetScriptBlock" -InnerText $GetScriptBlock -OutNull
    }
}

function Script:Add-CodePropertyNode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Name,

        [Parameter(Position = 1)]
        [Alias("Type")]
        [string]
        $TypeName,

        [Parameter(Position = 2)]
        [Alias("Method")]
        [string]
        $MethodName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        if ([string]::IsNullOrEmpty($Name)) {
            return
        }

        $CodeNode = $Root | Add-ChildNode "CodeProperty"
        $CodeNode | Add-ChildNode "Name" -InnerText $Name -OutNull
        $ReferNode = $CodeNode | Add-ChildNode "GetCodeReference"
        $ReferNode | Add-ChildNode "TypeName" -InnerText $TypeName -OutNull
        $ReferNode | Add-ChildNode "MethodName" -InnerText $MethodName -OutNull
    }
}

function Script:Add-NotePropertyNode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Name,

        [Parameter(Position = 1)]
        [string]
        $Value,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $NoteNode = $Root | Add-ChildNode "NoteProperty"
        $NoteNode | Add-ChildNode "Name" -InnerText $Name -OutNull
        $NoteNode | Add-ChildNode "Value" -InnerText $Value -OutNull
    }
}

function Script:Add-MemberSetNode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Member")]
        [string]
        $MemberSetName,

        [Parameter(Position = 1)]
        [Alias("Prop")]
        [string]
        $PropertyName,

        [Parameter(Position = 2)]
        [Alias("Refers")]
        [string[]]
        $ReferProperties,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        if ([string]::IsNullOrEmpty($MemberSetName)) {
            return
        }

        $MemberSetNode = $Root | Add-ChildNode "MemberSet"

        $MemberSetNode | Add-ChildNode "Name" -InnerText $MemberSetName -OutNull
        $PropSetNode = $MemberSetNode | Add-ChildNode "Members" | Add-ChildNode "PropertySet"
        $PropSetNode | Add-ChildNode "Name" -InnerText $PropertyName -OutNull
        if ($null -ne $ReferProperties) {
            $ReferPropsNode = $PropSetNode | Add-ChildNode "ReferencedProperties"
            foreach ($_ in $ReferProperties) {
                $ReferPropsNode | Add-ChildNode "Name" -InnerText $_ -OutNull
            }
        }
    }
}

function Script:Add-ScriptMethodNode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Name,

        [Parameter(Position = 1)]
        [string]
        $Script,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        if ([string]::IsNullOrEmpty($Name)) {
            return
        }

        $ScriptNode = $Root | Add-ChildNode "ScriptMethod"
        $ScriptNode | Add-ChildNode "Name" -InnerText $Name -OutNull
        $FormatScript = $Script.Split("`n").Trim()
        $FormatScript = $Script.Split("`n").Trim() | Where-Object { $_ }
        $Script = $(""; $FormatScript; "") -join "`n$("`t" * 4)"
        $ScriptNode | Add-ChildNode "Script" -InnerText $Script -OutNull
    }
}

function Script:Add-MemberNode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateSet(
            "AliasProperty", "CodeProperty", "NoteProperty",
            "ScriptProperty", "MemberSet", "ScriptMethod")]
        [string]
        $MemberType,

        [Parameter(Position = 1)]
        [hashtable]
        $Member,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        if ($null -eq $Member) {
            return
        }

        switch ($MemberType) {
            "AliasProperty" {
                $Root | Script:Add-AliasPropertyNode @Member
            }
            "CodeProperty" {
                $Root | Script:Add-CodePropertyNode @Member
            }
            "NoteProperty" {
                $Root | Script:Add-NotePropertyNode @Member
            }
            "ScriptProperty" {
                $Root | Script:Add-ScriptPropertyNode @Member
            }
            "MemberSet" {
                $Root | Script:Add-MemberSetNode @Member
            }
            "ScriptMethod" {
                $Root | Script:Add-ScriptMethodNode @Member
            }
            Default { }
        }
    }
}

function Script:Add-TypeNode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Name,

        [Parameter(Position = 1)]
        [hashtable[]]
        $Members,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $TypeNode = $Root | Add-ChildNode "Type"
        $TypeNode | Add-ChildNode "Name" -InnerText $Name -OutNull
        if ($null -ne $Members) {
            $MembersNode = $TypeNode | Add-ChildNode "Members"
            foreach ($_ in $Members) {
                $MembersNode | Script:Add-MemberNode @_
            }
        }
    }
}

function Add-TypesNode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [hashtable[]]
        $Types,

        [Parameter()]
        [string]
        $OutXml
    )

    process {
        if ($null -eq $Types) {
            return
        }

        [xml]$Script:doc = [xml]::new()
        $null = $Script:doc.AppendChild($Script:doc.CreateXmlDeclaration("1.0", "utf-8", $null))
        $TypesNode = $Script:doc.AppendChild($Script:doc.CreateElement("Types"))
        Write-Verbose "Creat xml element - Types"

        foreach ($item in $Types) {
            $TypesNode | Script:Add-TypeNode @item
        }

        if ($OutXml -ne $null) {
            $Script:doc.Save($OutXml)
            Write-Verbose "Save in $OutXml"
        }
    }
}
#endregion Add-Node

#region ConvertTo-PSTypeXml
function Script:ConvertTo-TypeNode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string[]]
        $InputObject
    )

    process {
        $Types = Resolve-PSIndentSyntax $InputObject -Exclude "^Members" -StrArrayToRaw -Verbose:$false
        $Types = $Types.Types
        for ($i = 0; $i -lt $Types.Count; $i++) {
            $Members =
            foreach ($item in [string[]]$Types[$i].Members) {
                switch -Regex ($item) {
                    '^\$_\.(?<Name>\w+)\s*->\s*\$_\.(?<Refer>\w+)$' {
                        @{
                            MemberType = "AliasProperty"
                            Member     = @{
                                Name  = $Matches.Name
                                Refer = $Matches.Refer
                            }
                        }
                    }
                    '^\$_\.(?<Name>\w+)\s*->\s*{(?<Script>(.|\n)+)}' {
                        @{
                            MemberType = "ScriptProperty"
                            Member     = @{
                                Name   = $Matches.Name
                                Script = $Matches.Script + "`t"
                            }
                        }
                    }
                    '^\$_\.(?<Name>\w+)\s*->\s*\[(?<Type>[A-z0-9_.]+)\]\.(?<Method>\w+)' {
                        @{
                            MemberType = "CodeProperty"
                            Member     = @{
                                Name       = $Matches.Name
                                TypeName   = $Matches.Type
                                MethodName = $Matches.MethodName
                            }
                        }
                    }
                    '^\$_\.(?<Name>\w+)\s*->\s*\b(?<Value>.*)' {
                        @{
                            MemberType = "NoteProperty"
                            Member     = @{
                                Name  = $Matches.Name
                                Value = $Matches.Value
                            }
                        }
                    }
                    '^\[(?<Member>\w+)\]\.(?<Prop>\w+)\s*->\s*(?<Refers>.+)$' {
                        @{
                            MemberType = "MemberSet"
                            Member     = @{
                                Member = $Matches.Member
                                Prop   = $Matches.Prop
                                Refers = $Matches.Refers.Split(",", [System.StringSplitOptions]1).Trim()
                            }
                        }
                    }
                    '^\$_\.(?<Name>\w+)\(\)\s*->\s*{(?<Script>(.|\n)+)}' {
                        @{
                            MemberType = "ScriptMethod"
                            Member     = @{
                                Name   = $Matches.Name
                                Script = $Matches.Script
                            }
                        }
                    }
                    Default { }
                }
            }
            $Types[$i].Members = $Members
        }

        Write-Output $Types
    }
}

function ConvertTo-PSTypeXml {
    [CmdletBinding(DefaultParameterSetName = "Load")]
    param(
        [Parameter(Position = 0, ParameterSetName = "Load")]
        [string[]]
        $InputObject,

        [Parameter(Position = 0, ParameterSetName = "LoadFile")]
        [string]
        $Path,

        [Parameter(Position = 1, ParameterSetName = "LoadFile")]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]
        $Encoding = "UTF8",

        [Parameter(ValueFromPipeline, ParameterSetName = "Load")]
        [Parameter(ValueFromPipeline, ParameterSetName = "LoadFile")]
        [Alias("Out")]
        [string]
        $OutXml = $($Path -replace "\.\w+$", ".ps1xml")
    )

    if ($($PSCmdlet.ParameterSetName -eq "LoadFile") -and $(Test-Path $Path)) {
        if ($Path.EndsWith(".ps1")) {
            $InputObject = $(& $Path).Split("`n")
        }
        else {
            $InputObject = $(Get-Content $Path -Raw -Encoding $Encoding).Split("`n")
        }
    }

    if ($null -eq $InputObject) {
        return
    }

    $Types = Script:ConvertTo-TypeNode -InputObject $InputObject
    Add-TypesNode -Types $Types -OutXml $OutXml
}
#endregion ConvertTo-PSTypeXml
