# ConvertTo-PSHelpXml
@"
.Synopsis
    ConvertTo-PSHelpXml
    转化指定语法帮助为 Help.xml
.Description
    转化指定语法帮助为 Help.xml
.Syntax
    ConvertTo-PSHelpXml
        [-Path] <String>
        [[-Encoding] {Unicode | UTF8 | Ascii | Default | ...}]
        [-OutXml <string>]
    ConvertTo-PSHelpXml
        [-InputObject] <String[]>
        [-OutXml <string>]
.Parameters
    -Path <String>
        # 建议搭配 vscode 编写 Help.ps1
        # 支持 Get-Content -Raw 输入
        Required:   True
        Position:   0
        Default :   None
        Pipeline:   False
        Wildcard:   False

    -Encoding <Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding>
        # powershell支持编码的枚举器
        Required:   False
        Position:   1
        Default :   UTF8
        Pipeline:   False
        Wildcard:   False

    -InputObject <string[]>
        # 帮助文本字符串
        Required:   True
        Position:   0
        Default :   None
        Pipeline:   False
        Wildcard:   False

    -OutXml <string>
        # 保存 xml 的路径
        Required:   False
        Position:   Named
        Default :   None
        Pipeline:   True
        Wildcard:   False
.Inputs
    None
.Outputs
    None
.Examples
    Example 1: 文本字符串输入
        PS C:\> ConvertTo-PSHelpXml -IntputObject `$(Get-Content .\CmdletHelp-Help.txt -Raw)
        # 将帮助文本作为字符串整体进行重构
    Example 2: Help.ps1 文件输入
        PS C:\> ConvertTo-PSHelpXml -Path .\Cmdlet-Help.ps1 -OutXml .\Cmdlet-Help.xml
        # 在 ps1 中编写好易读的帮助文档, 语法格式参考脚本帮助的编写方式
        # https://docs.microsoft.com/zh-cn/powershell/scripting/developer/help/placing-comment-based-help-in-scripts
.RelatedLinks
    github: https://github.com/empyrealtear/PSModuleDevTool
    Resolve-PSIndentSyntax
    ConvertTo-PSFormatXml
    ConvertTo-PSTypeXml
"@
# ConvertTo-PSFormatXml
@"
.Synopsis
    ConvertTo-PSFormatXml
    转化指定哈希表为 format.ps1xml
.Description
    转化指定哈希表为 format.ps1xml
.Syntax
    ConvertTo-PSFormatXml
        [-Path] <string>
        [[-Encoding] {Unicode | UTF8 | Ascii | Default | ...}]
        [-OutXml <string>]
    ConvertTo-PSFormatXml
        [-InputObject] <String[]> [-OutXml <string>]
.Parameters
    -Path <String>
        # 建议搭配 vscode 编写 Format.ps1
        # 支持 Get-Content -Raw 输入
        Required:   True
        Position:   0
        Default :   None
        Pipeline:   False
        Wildcard:   False

    -Encoding <Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding>
        # powershell支持编码的枚举器
        Required:   False
        Position:   1
        Default :   UTF8
        pipeline:   False
        wildcard:   False

    -InputObject <string[]>
        # 类格式文本字符串
        Required:   True
        Position:   0
        Default :   None
        Pipeline:   False
        Wildcard:   False

    -OutXml <string>
        # 保存 xml 的路径
        Required:   False
        Position:   Named
        Default :   None
        Pipeline:   True
        Wildcard:   False
.Inputs
    None
.Outputs
    None
.Examples
    Example 1: 文本字符串输入
        PS C:\> ConvertTo-PSFormatXml -IntputObject `$(Get-Content .\Cmdlet-Format.txt -Raw)
        # 将类格式文本作为字符串重构为哈希表, 并生成 xml
    Example 2: Format.ps1 文件输入
        PS C:\> ConvertTo-PSFormatXml -Path .\Cmdlet-Format.ps1 -OutXml .\Cmdlet.format.ps1xml
        # 在 ps1 中编写好易读的格式架构, 语法格式参考格式架构的编写方式
        # https://docs.microsoft.com/zh-cn/powershell/scripting/developer/format/writing-a-powershell-formatting-file
.RelatedLinks
    github: https://github.com/empyrealtear/PSModuleDevTool
    Resolve-PSIndentSyntax
    ConvertTo-PSHelpXml
    ConvertTo-PSTypeXml
"@
# ConvertTo-PSTypeXml
@"
.Synopsis
    ConvertTo-PSTypeXml
    转化指定哈希表为 types.ps1xml
.Description
    转化指定哈希表为 types.ps1xml
.Syntax
    ConvertTo-PSTypeXml
        [-Path] <string>
        [[-Encoding] {Unicode | UTF8 | Ascii | Default | ...}]
        [-OutXml <string>]
    ConvertTo-PSTypeXml
        [-InputObject] <String[]> [-OutXml <string>]
.Parameters
    -Path <String>
        # 建议搭配 vscode 编写 Type.ps1
        # 支持 Get-Content -Raw 输入
        Required:   True
        Position:   0
        Default :   None
        Pipeline:   False
        Wildcard:   False

    -Encoding <Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding>
        # powershell支持编码的枚举器
        Required:   False
        Position:   1
        Default :   UTF8
        pipeline:   False
        wildcard:   False

    -InputObject <string[]>
        # 成员扩展文本字符串
        Required:   True
        Position:   0
        Default :   None
        Pipeline:   False
        Wildcard:   False

    -OutXml <string>
        # 保存 xml 的路径
        Required:   False
        Position:   Named
        Default :   None
        Pipeline:   True
        Wildcard:   False
.Inputs
    None
.Outputs
    None
.Examples
    Example 1: 文本字符串输入
        PS C:\> ConvertTo-PSTypeXml -IntputObject `$(Get-Content .\Cmdlet-Type.txt)
        # 将成员扩展文本作为字符串重构为哈希表, 并生成 xml
    Example 2: Type.ps1 文件输入
        PS C:\> ConvertTo-PSTypeXml -Path .\Cmdlet-Type.ps1 -OutXml .\Cmdlet.types.ps1xml
        # 在 ps1 中编写好易读的成员扩展文档, 语法格式参考成员扩展的编写方式
        # https://docs.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_types.ps1xml
.RelatedLinks
    github: https://github.com/empyrealtear/PSModuleDevTool
    Resolve-PSIndentSyntax
    ConvertTo-PSHelpXml
    ConvertTo-PSFormatXml
"@
