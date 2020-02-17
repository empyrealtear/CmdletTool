# Powershell Module Development Tool

## File lists

- [PSModuleDevTool.psd1](PSModuleDevTool.psd1)
- [PSModuleDevTool.psm1](PSModuleDevTool.psm1)
- [PSModuleDevTool-Help.xml](PSModuleDevTool-Help.xml)
- bin/
  - [PublicFunction.ps1](bin/PublicFunction.ps1)
  - [PSFormatXml.ps1](bin/PSFormatXml.ps1)
  - [PSHelpXml.ps1](bin/PSHelpXml.ps1)
  - [PSTypeXml.ps1](bin/PSTypeXml.ps1)
  - [PSModuleDevTool-Help.ps1](bin/PSModuleDevTool-Help.ps1)
  - [PSModuleDevTool-Format.ps1](bin/PSModuleDevTool-Format.ps1)

## Function lists

- New-PSDevEnvironment
- New-PSDevExternalFile
- ConvertTo-PSHelpXml
- ConvertTo-PSFormatXml
- ConvertTo-PSTypeXml
- Resolve-PSIndentSyntax

## Example

```powershell
# Install-Module PSModuleDevTool

Import-Module .\PSModuleDevTool.psm1
ConvertTo-PSHelpXml -Path .\bin\PSModuleDevTool-Help.ps1 -OutXml .\bin\PSModuleDevTool-Help.xml
ConvertTo-PSFormatXml -Path .\bin\PSModuleDevTool-Format.ps1 -OutXml .\bin\PSModuleDevTool.format.ps1xml
ConvertTo-PSTypeXml -Path .\bin\PSModuleDevTool-Type.ps1 -OutXml .\bin\PSModuleDevTool.types.ps1xml
```

## Build

```powershell
# 构建模块
.\build.ps1 -Verbose
# 构建并复制到模块文件夹
.\build.ps1 -Release -Verbose
```

## Reference

- [Powershell, Example of comment based help](https://docs.microsoft.com/zh-cn/powershell/scripting/developer/help/examples-of-comment-based-help)
- [Powershell, Formatting File](https://docs.microsoft.com/zh-cn/powershell/scripting/developer/format/writing-a-powershell-formatting-file)
- [Powershell, About_Types.ps1xml](https://docs.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_types.ps1xml)
