# Verb-Noun
[string[]]$Text = @"
.Synopsis
    Verb-Noun
    简述 1
    简述 2
.Description
    概述 1
    概述 2
.Syntax
    Verb-Noun -param1 <type> -param2
    Verb-Noun
        [-param1 <type>] [-param2]
    Verb-Noun [[-param1] <type>] [[-param2]]
    Verb-Noun [-param1 {A | B | ...}] [-param2]
.Parameters
    -param1 <type>
        # 参数描述
        .Required:  True
        .Position:  0
        .Default:   None
        .Pipeline:  False
        .Wildcard:  False

    -param2 <SwitchParameter>
        # 参数描述
        .Required:  False
        .Position:  Named
        .Default:   False
        .Pipeline:  False
        .Wildcard:  False
.Inputs
    None
    # 输入描述
.Outputs
    None
    # 输出描述
.Examples
    Example 1: 例子简述
        PS C:\> Verb-Noun -param1 value
        返回值
    
        # 例子详述
    
    Example 2: 例子简述
        PS C:\> Verb-Noun -param2 value
        返回值
    
        # 例子详述
.RelatedLinks
    Text: url
    Text
"@

Push-Location
Set-Location $PSScriptRoot

Import-Module .\PSModuleDevTool.psm1
ConvertTo-PSHelpXml -InputObject $Text -OutXml .\build.test.xml
Remove-Module PSModuleDevTool

Pop-Location
