#Requires -Assembly 'System.Xml'

#region public
# . $PSScriptRoot\PublicFunction.ps1
#endregion public

#region Add-ConfigurationNode
#region DefaultSetting
function Script:Add-SelectionCondition {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Type")]
        [string]
        $TypeName,

        [Parameter(Position = 1)]
        [Alias("SetName")]
        [string]
        $SelectionSetName,

        [Parameter(Position = 2)]
        [Alias("PropName")]
        [string]
        $PropertyName,

        [Parameter(Position = 3)]
        [string]
        $ScriptBlock,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $SelectNode = $Root | Add-ChildNode "SelectionCondition"
        @(
            @{ Name = "TypeName"; Text = $TypeName }
            @{ Name = "SelectionSetName"; Text = $SelectionSetName }
            @{ Name = "PropertyName"; Text = $PropertyName }
            @{ Name = "ScriptBlock"; Text = $ScriptBlock } ) |
            ForEach-Object {
                $SelectNode | Add-ChildNode @_ -OutNull -RemoveNull
            }
    }
}

function Script:Add-EntrySelectedBy {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Type")]
        [string]
        $TypeName,

        [Parameter(Position = 1)]
        [Alias("SetName")]
        [string]
        $SelectionSetName,

        [Parameter(Position = 2)]
        [Alias("Condition")]
        [hashtable]
        $SelectionCondition,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $EntryNode = $Root | Add-ChildNode "EntrySelectedBy"
        $EntryNode | Add-ChildNode "TypeName" $TypeName -OutNull -RemoveNull
        $EntryNode | Add-ChildNode "SelectionSetName" $SelectionSetName -OutNull -RemoveNull
        $EntryNode | Script:Add-SelectionCondition @SelectionCondition
    }
}

function Script:Add-EnumerableExpansion {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateSet("EnumOnly", "CoreOnly", "Both", $null)]
        [string]
        $Expand,

        [Parameter(Position = 1)]
        [Alias("SelectBy")]
        [hashtable]
        $EntrySelectedBy,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $EnumExpansNode = $Root.AppendChild($Script:doc.CreateElement("EnumerableExpansion"))
        $EnumExpansNode | Add-ChildNode "Expand" $Expand -OutNull -RemoveNull
        $EnumExpansNode | Script:Add-EntrySelectedBy @EntrySelectedBy
    }
}

function Add-DefaultSetting {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("PropCount")]
        [int]
        $PropertyCountForTable,

        [Parameter(Position = 1)]
        [Alias("Enums", "Expans")]
        [hashtable[]]
        $EnumerableExpansions,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root,

        [switch]$ShowError,
        [switch]$DisplayError,
        [switch]$WarpTable
    )

    process {
        $DefaultSetNode = $Root | Add-ChildNode "DefaultSettings"

        if ($ShowError) {
            $DefaultSetNode | Add-ChildNode "ShowError" -OutNull
        }
        if ($DisplayError) {
            $DefaultSetNode | Add-ChildNode "DisplayError" -OutNull
        }
        if ($PropertyCountForTable -ne 0) {
            $DefaultSetNode | Add-ChildNode "PropertyCountForTable" $PropertyCountForTable -OutNull
        }
        if ($WarpTable) {
            $DefaultSetNode | Add-ChildNode "WarpTable" -OutNull
        }
        foreach ($_ in $EnumerableExpansions) {
            $DefaultSetNode | Script:Add-EnumerableExpansion @_
        }
    }
}
#endregion DefaultSetting

#region SelectionSets
function Script:Add-SelectionSet {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("SetName")]
        [string]
        $Name,

        [Parameter(Position = 1)]
        [Alias("Type")]
        [string]
        $TypeName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $SetNode = $Root | Add-ChildNode "SelectionSet"
        $SetNode | Add-ChildNode "Name" -InnerText $Name -OutNull
        $SetNode |
            Add-ChildNode "Type" |
            Add-ChildNode "TypeName" -InnerText $TypeName -OutNull
    }
}

function Add-SelectionSets {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Sets")]
        [hashtable[]]
        $SelectionSets,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        if ($null -eq $SelectionSets) {
            return
        }

        $SetsNode = $Root | Add-ChildNode "SelectionSets"
        foreach ($_ in $SelectionSets) {
            $SetsNode | Script:Add-SelectionSet @_
        }
    }
}
#endregion SelectionSets

#region Controls
function Script:Add-ItemSelectionCondition {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("PropName")]
        [string]
        $PropertyName,

        [Parameter(Position = 1)]
        [string]
        $ScriptBlock,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $ItemNode = $Root | Add-ChildNode "ItemSelectionCondition"

        $ItemNode | Add-ChildNode "PropertyName" -InnerText $PropertyName -OutNull -RemoveNull
        $ItemNode | Add-ChildNode "ScriptBlock" -InnerText $ScriptBlock -OutNull -RemoveNull
    }
}

function Script:Add-ExpressionBinding {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("CtrlName")]
        [string]
        $CustomControlName,

        [Parameter(Position = 1)]
        [Alias("PropName")]
        [string]
        $PropertyName,

        [Parameter(Position = 2)]
        [string]
        $ScriptBlock,

        [Parameter(Position = 3)]
        [Alias("Entries")]
        [hashtable[]]
        $CustomEntries,

        [Parameter(Position = 4)]
        [Alias("Condition")]
        [hashtable]
        $ItemSelectionCondition,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root,

        [Alias("Enum")]
        [switch]$EnumerateCollection
    )

    process {
        $ExpressNode = $Root | Add-ChildNode "ExpressionBinding"

        if ($null -ne $CustomEntries) {
            $ExpressNode | Script:Add-CustomControl @CustomEntries
        }
        $ExpressNode | Add-ChildNode "CustomControlName" -InnerText $CustomControlName -OutNull -RemoveNull
        if ($EnumerateCollection) {
            $ExpressNode | Add-ChildNode "EnumerateCollection" -OutNull
        }
        $ExpressNode | Add-ChildNode "PropertyName" -InnerText $PropertyName -OutNull -RemoveNull
        $ExpressNode | Add-ChildNode "ScriptBlock" -InnerText $ScriptBlock -OutNull -RemoveNull
        if ($null -ne $ItemSelectionCondition) {
            $ExpressNode | Script:Add-ItemSelectionCondition @ItemSelectionCondition
        }
    }
}

function Script:Add-Frame {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Left")]
        [int]
        $LeftIndent,

        [Parameter(Position = 1)]
        [Alias("Right")]
        [int]
        $RightIndent,

        [Parameter(Position = 2)]
        [Alias("Hanging")]
        [int]
        $FirstLineHanging,

        [Parameter(Position = 3)]
        [Alias("Indent")]
        [int]
        $FirstLineIndent,

        [Parameter(Position = 4)]
        [Alias("Item")]
        [hashtable]
        $CustomItem,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $FrameNode = $Root | Add-ChildNode "Frame"
        if ($LeftIndent -gt 0) {
            $FrameNode | Add-ChildNode "LeftIndent" -InnerText $LeftIndent -OutNull -RemoveNull
        }
        if ($RightIndent -gt 0) {
            $FrameNode | Add-ChildNode "RightIndent" -InnerText $RightIndent -OutNull -RemoveNull
        }
        if ($FirstLineHanging -gt 0) {
            $FrameNode | Add-ChildNode "FirstLineHanging" -InnerText $FirstLineHanging -OutNull -RemoveNull
        }
        if ($FirstLineIndent -gt 0) {
            $FrameNode | Add-ChildNode "FirstLineIndent" -InnerText $FirstLineIndent -OutNull -RemoveNull
        }
        if ($null -ne $CustomItem) {
            $FrameNode | Script:Add-CustomItem @CustomItem
        }
    }
}

function Script:Add-CustomItem {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Text,

        [Parameter(Position = 1)]
        [Alias("Express", "Binding")]
        [hashtable]
        $ExpressionBinding,

        [Parameter(Position = 2)]
        [hashtable]
        $Frame,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root,

        [switch]$NewLine
    )

    process {
        $ItemNode = $Root | Add-ChildNode "CustomItem"

        if ($null -ne $ExpressionBinding) {
            $ItemNode | Script:Add-ExpressionBinding @ExpressionBinding
        }
        if ($NewLine) {
            $ItemNode | Add-ChildNode "NewLine" -OutNull
        }
        $ItemNode | Add-ChildNode "Text" -InnerText $Text -OutNull -RemoveNull
        if ($null -ne $Frame) {
            $ItemNode | Script:Add-Frame @Frame
        }
    }
}

function Script:Add-CustomEntry {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("SelectBy")]
        [hashtable]
        $EntrySelectedBy,

        [Parameter(Position = 1)]
        [Alias("Item")]
        [hashtable]
        $CustomItem,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $EntryNode = $Root | Add-ChildNode "CustomEntry"
        if ($null -ne $EntrySelectedBy) {
            $EntryNode | Script:Add-EntrySelectedBy @EntrySelectedBy
        }
        if ($null -ne $CustomItem) {
            $EntryNode | Script:Add-CustomItem @CustomItem
        }
    }
}

function Script:Add-CustomControl {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Entries")]
        [hashtable[]]
        $CustomEntries,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        if ($null -eq $CustomEntries) {
            return
        }
        $CustomNode = $Root |
            Add-ChildNode "CustomControl" |
            Add-ChildNode "CustomEntries"
        foreach ($_ in $CustomEntries) {
            $CustomNode | Script:Add-CustomEntry @_
        }
    }
}

function Script:Add-Control {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Name,

        [Parameter(Position = 1)]
        [Alias("Entries")]
        [hashtable[]]
        $CustomEntries,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $CtrlNode = $Root | Add-ChildNode "Control"
        $CtrlNode | Add-ChildNode "Name" -InnerText $Name -OutNull -RemoveNull
        $CtrlNode | Script:Add-CustomControl $CustomEntries
    }
}

function Add-Controls {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Ctrls")]
        [hashtable[]]
        $Controls,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        if ($null -eq $Controls) {
            return
        }

        $CtrlsNode = $Root | Add-ChildNode "Controls"
        foreach ($_  in $Controls) {
            $CtrlsNode | Script:Add-Control @_
        }
    }
}
#endregion Controls

#region ViewDefinitions
function Script:Add-GroupBy {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("PropName")]
        [string]
        $PropertyName,

        [Parameter(Position = 1)]
        [string]
        $ScriptBlock,

        [Parameter(Position = 2)]
        [string]
        $Label,

        [Parameter(Position = 3)]
        [Alias("CtrlName")]
        [string]
        $CustomControlName,

        [Parameter(Position = 4)]
        [Alias("Entries")]
        [hashtable[]]
        $CustomEntries,

        [Parameter(Mandatory, ValueFromPipeline)]
        $Root
    )

    process {
        $GroupByNode = $Root | Add-ChildNode "GroupBy"

        $GroupByNode | Add-ChildNode "PropertyName" -InnerText $PropertyName -OutNull -RemoveNull
        $GroupByNode | Add-ChildNode "ScriptBlock" -InnerText $ScriptBlock -OutNull -RemoveNull
        $GroupByNode | Add-ChildNode "Label" -InnerText $Label -OutNull -RemoveNull
        $GroupByNode | Add-ChildNode "CustomControlName" -InnerText $CustomControlName -OutNull -RemoveNull
        $GroupByNode | Script:Add-CustomControl $CustomControl
    }
}

function Script:Add-TableColumnHeader {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Label,

        [Parameter(Position = 1)]
        [int]
        $Width,

        [Parameter(Position = 2)]
        [ValidateSet("Left", "Center", "Right", $null)]
        [string]
        $Alignment = "Left",

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $HeaderNode = $Root | Add-ChildNode "TableColumnHeader"
        $HeaderNode | Add-ChildNode "Label" $Label -OutNull -RemoveNull
        $HeaderNode | Add-ChildNode "Width" $Width -OutNull -RemoveNull
        $HeaderNode | Add-ChildNode "Alignment" $Alignment -OutNull -RemoveNull
    }
}

function Script:Add-TableColumnItem {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateSet("Left", "Center", "Right", $null)]
        [string]
        $Alignment,

        [Parameter(Position = 1)]
        [Alias("Format")]
        [string]
        $FormatString,

        [Parameter(Position = 2)]
        [Alias("PropName")]
        [string]
        $PropertyName,

        [Parameter(Position = 3)]
        [string]
        $ScriptBlock,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $ItemNode = $Root | Add-ChildNode "TableColumnItem"

        $ItemNode | Add-ChildNode "Alignment" -InnerText $Alignment -OutNull -RemoveNull
        $ItemNode | Add-ChildNode "FormatString" -InnerText $FormatString -OutNull -RemoveNull
        $ItemNode | Add-ChildNode "PropertyName" -InnerText $PropertyName -OutNull -RemoveNull
        $ItemNode | Add-ChildNode "ScriptBlock" -InnerText $ScriptBlock -OutNull -RemoveNull
    }
}

function Script:Add-TableRowEntry {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("SelectBy")]
        [hashtable]
        $EntrySelectedBy,

        [Parameter(Position = 1)]
        [Alias("Items")]
        [hashtable[]]
        $TableColumnItems,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root,

        [switch]$Wrap
    )

    process {
        $EntryNode = $Root | Add-ChildNode "TableRowEntry"

        if ($Wrap) {
            $EntryNode | Add-ChildNode "Wrap" -OutNull -RemoveNull
        }
        if ($null -ne $EntrySelectedBy) {
            $EntryNode | Script:Add-EntrySelectedBy @EntrySelectedBy
        }
        if ($null -ne $TableColumnItems) {
            $ItemsNode = $EntryNode | Add-ChildNode "TableColumnItems"
            foreach ($_ in $TableColumnItems) {
                $ItemsNode | Script:Add-TableColumnItem @_
            }
        }
    }
}

function Script:Add-TableControl {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Headers")]
        [hashtable[]]
        $TableHeaders,

        [Parameter(Position = 1)]
        [Alias("Rows")]
        [hashtable[]]
        $TableRowEntries,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root,

        [switch]$AutoSize,
        [switch]$HideTableHeaders
    )

    process {
        $TableNode = $Root | Add-ChildNode "TableControl"

        if ($AutoSize) {
            $TableNode | Add-ChildNode "AutoSize" -OutNull
        }
        if ($HideTableHeaders) {
            $TableNode | Add-ChildNode "HideTableHeaders" -OutNull
        }
        if ($null -ne $TableHeaders) {
            $HeadersNode = $TableNode | Add-ChildNode "TableHeaders"
            foreach ($_ in $TableHeaders) {
                $HeadersNode | Script:Add-TableColumnHeader @_
            }
        }
        if ($null -ne $TableRowEntries) {
            $RowsNode = $TableNode | Add-ChildNode "TableRowEntries"
            foreach ($_ in $TableRowEntries) {
                $RowsNode | Script:Add-TableRowEntry @_
            }
        }
    }
}

function Script:Add-ListItem {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("PropName")]
        [string]
        $PropertyName,

        [Parameter(Position = 1)]
        [string]
        $ScriptBlock,

        [Parameter(Position = 2)]
        [string]
        $Label,

        [Parameter(Position = 3)]
        [Alias("Format")]
        [string]
        $FormatString,

        [Parameter(Position = 4)]
        [Alias("Select", "Condition")]
        [hashtable]
        $ItemSelectionCondition,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        if ([string]::IsNullOrEmpty($PropertyName)) {
            return
        }

        $ItemNode = $Root | Add-ChildNode "ListItem"
        $ItemNode | Add-ChildNode "PropertyName" -InnerText $PropertyName -OutNull -RemoveNull
        $ItemNode | Add-ChildNode "ScriptBlock" -InnerText $ScriptBlock -OutNull -RemoveNull
        $ItemNode | Add-ChildNode "Label" -InnerText $Label -OutNull -RemoveNull
        $ItemNode | Add-ChildNode "FormatString" -InnerText $FormatString -OutNull -RemoveNull
        if ($null -ne $ItemSelectionCondition) {
            $ItemNode | Script:Add-ItemSelectionCondition @ItemSelectionCondition
        }
    }
}

function Script:Add-ListEntry {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("SelectBy")]
        [hashtable]
        $EntrySelectedBy,

        [Parameter(Position = 1)]
        [Alias("Items")]
        [hashtable[]]
        $ListItems,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $EntryNode = $Root | Add-ChildNode "ListEntry"

        if ($null -ne $EntrySelectedBy) {
            $EntryNode | Script:Add-EntrySelectedBy @EntrySelectedBy
        }
        if ($null -ne $ListItems) {
            $ItemsNode = $EntryNode | Add-ChildNode "ListItems"
            foreach ($_ in $ListItems) {
                $ItemsNode | Script:Add-ListItem @_
            }
        }
    }
}

function Script:Add-ListControl {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Entries")]
        [hashtable[]]
        $ListEntries,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        if ($null -eq $ListEntries) {
            return
        }

        $EntriesNode = $Root |
            Add-ChildNode "ListControl" |
            Add-ChildNode "ListEntries"

        foreach ($_ in $ListEntries) {
            $EntriesNode | Script:Add-ListEntry @_
        }
    }
}

function Script:Add-WideItem {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("PropName")]
        [string]
        $PropertyName,

        [Parameter(Position = 1)]
        [string]
        $ScriptBlock,

        [Parameter(Position = 2)]
        [Alias("Format")]
        [string]
        $FormatString,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $ItemNode = $Root | Add-ChildNode "WideItem"
        $ItemNode | Add-ChildNode "PropertyName" -InnerText $PropertyName -OutNull -RemoveNull
        $ItemNode | Add-ChildNode "ScriptBlock" -InnerText $ScriptBlock -OutNull -RemoveNull
        $ItemNode | Add-ChildNode "FormatString" -InnerText $FormatString -OutNull -RemoveNull
    }
}

function Script:Add-WideEntry {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("SelectBy")]
        [hashtable]
        $EntrySelectedBy,

        [Parameter(Position = 1)]
        [Alias("Item")]
        [hashtable]
        $WideItem,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $EntryNode = $Root | Add-ChildNode "WideEntry"

        if ($null -ne $EntrySelectedBy) {
            $EntryNode | Script:Add-EntrySelectedBy @$EntrySelectedBy
        }
        if ($null -ne $WideItem) {
            $EntryNode | Script:Add-WideItem @WideItem
        }
    }
}

function Script:Add-WideControl {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Col")]
        [int]
        $ColumnNumber,

        [Parameter(Position = 1)]
        [Alias("Entries")]
        [hashtable[]]
        $WideEntries,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root,

        [switch]$AutoSize
    )

    process {
        $CtrlNode = $Root | Add-ChildNode "WideControl"

        if ($AutoSize) {
            $CtrlNode | Add-ChildNode "AutoSize"
        }
        $CtrlNode | Add-ChildNode "ColumnNumber" -InnerText $ColumnNumber -OutNull -RemoveNull
        if ($null -ne $WideEntries) {
            $EntriesNode = $CtrlNode | Add-ChildNode "WideEntries"
            foreach ($_ in $WideEntries) {
                $EntriesNode | Script:Add-WideEntry @_
            }
        }
    }
}

function Script:Add-ViewSelectBy {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Type")]
        [string]
        $TypeName,

        [Parameter(Position = 1)]
        [Alias("SetName")]
        [string]
        $SelectionSetName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        $SelectByNode = $Root | Add-ChildNode "ViewSelectBy"
        $SelectByNode | Add-ChildNode "TypeName" -InnerText $TypeName -OutNull -RemoveNull
        $SelectByNode | Add-ChildNode "SelectionSetName" -InnerText $SelectionSetName -OutNull -RemoveNull
    }
}

function Script:Add-View {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Name,

        [Parameter(Position = 1)]
        [Alias("SelectBy")]
        [hashtable]
        $ViewSelectedBy,

        [Parameter(Position = 2)]
        [hashtable[]]
        $Controls,

        [Parameter(Position = 3)]
        [hashtable]
        $GroupBy,

        [Parameter(Position = 4)]
        [Alias("Table")]
        [hashtable]
        $TableControl,

        [Parameter(Position = 5)]
        [Alias("List")]
        [hashtable]
        $ListControl,

        [Parameter(Position = 6)]
        [Alias("Wide")]
        [hashtable]
        $WideControl,

        [Parameter(Position = 7)]
        [Alias("CustomCtrl")]
        [hashtable]
        $CustomControl,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        if ([string]::IsNullOrEmpty($Name)) {
            return
        }
        $ViewNode = $Root | Add-ChildNode "View"

        $ViewNode | Add-ChildNode "Name" -InnerText $Name -OutNull -RemoveNull
        if ($null -ne $ViewSelectedBy) {
            $ViewNode | Script:Add-ViewSelectBy @ViewSelectedBy
        }
        $ViewNode | Add-Controls -Controls $Controls
        if ($null -ne $GroupBy) {
            $ViewNode | Script:Add-GroupBy @GroupBy
        }
        if ($null -ne $TableControl) {
            $ViewNode | Script:Add-TableControl @TableControl
        }
        if ($null -ne $ListControl) {
            $ViewNode | Script:Add-ListControl @ListControl
        }
        if ($null -ne $WideControl) {
            $ViewNode | Script:Add-WideControl @WideControl
        }
        if ($null -ne $CustomControl) {
            $ViewNode | Script:Add-CustomControl @CustomControl
        }
    }
}

function Add-ViewDefinitions {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [hashtable[]]
        $Views,

        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Xml.XmlElement]
        $Root
    )

    process {
        if ($null -eq $Views) {
            return
        }

        $ViewsNode = $Root | Add-ChildNode "ViewDefinitions"
        foreach ($_ in $Views) {
            $ViewsNode | Script:Add-View @_
        }
    }
}
#endregion ViewDefinitions

function Add-ConfigurationNode {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias("Default")]
        [hashtable]
        $DefaultSet,

        [Parameter(Position = 1)]
        [Alias("Sets")]
        [hashtable[]]
        $SelectionSets,

        [Parameter(Position = 2)]
        [Alias("Ctrls")]
        [hashtable[]]
        $Controls,

        [Parameter(Position = 3)]
        [Alias("Views")]
        [hashtable[]]
        $ViewDefinitions,

        [Parameter(Position = 4)]
        [string]
        $OutXml
    )

    process {
        $Script:doc = [xml]::new()
        $null = $Script:doc.AppendChild($Script:doc.CreateXmlDeclaration("1.0", "utf-8", $null))
        $ConfigNode = $Script:doc.AppendChild($Script:doc.CreateElement("Configuration"))
        Write-Verbose "Creat xml element - Configuration"

        $ConfigNode | Add-DefaultSetting @DefaultSet
        $ConfigNode | Add-SelectionSets -SelectionSets $SelectionSets
        $ConfigNode | Add-Controls -Controls $Controls
        $ConfigNode | Add-ViewDefinitions -Views $ViewDefinitions

        if ($OutXml -ne $null) {
            $Script:doc.Save($OutXml)
            Write-Verbose "Save in $OutXml"
        }
    }
}
#endregion Add-ConfigurationNode

#region ConvertTo-PSFormatXml
function Script:Format-PSFormatContent {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string]
        $InputObject
    )

    process {
        $null = $InputObject -match "^(?<Indent>\s*)\S"
        $IndentNow = $Matches.Indent
        # $IndentNext = $IndentNow + "    "
        $InputStr = $InputObject.Trim()
        switch -Regex ($InputStr) {
            '^-\w+$' {
                "$($IndentNow)$($InputStr.TrimStart("-")) : true"
            }
            '^\[(\w|.)+\]$' {
                "$($IndentNow)TypeName : {0}" -f $InputStr.Trim('[]')
            }
            '^\(\w+\)$' {
                "$($IndentNow)SetName : {0}" -f $InputStr.Trim('()')
            }
            '^{.*}$' {
                "$($IndentNow)ScriptBlock : {0}" -f $InputStr.Trim('{}').Trim()
            }
            '^(\$_)?\.\w+' {
                "$($IndentNow)PropName : {0}" -f $($InputStr -replace '^(\$_)?\.', "")
            }
            '^-f\s+".+"$' {
                "$($IndentNow)Format : {0}" -f $($InputStr -replace '^-f\s+', '').Trim('"')
            }
            Default {
                Write-Output $InputObject
            }
        }
    }
}

function ConvertTo-PSFormatXml {
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
            $InputObject = & $Path
        }
        else {
            $InputObject = Get-Content $Path -Raw -Encoding $Encoding
        }
    }

    if ($null -eq $InputObject) {
        return
    }

    [string[]]$Content = $InputObject.Trim().Split("`n", [System.StringSplitOptions]1) |
        Script:Format-PSFormatContent

    $BoundParameter = Resolve-PSIndentSyntax -Content $Content -Recurse -Verbose:$false

    Add-ConfigurationNode @BoundParameter -OutXml $OutXml
}
#endregion ConvertTo-PSFormatXml
