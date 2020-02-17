@'
Types
    Name : System.IO.FileInfo
    Members
        # AliasProperty
        $_.Count -> $_.Length
    Members
        # ScriptProperty
        $_.Age -> {
            ((Get-Date) - ($this.CreationTime)).Days
        }
    Members
        # CodeProperty
        $_.Mode ->
        [Microsoft.PowerShell.Commands.FileSystemProvider].Mode
    Members
        # NoteProperty
        $_.Status -> Value
    Members
        [PSStandardMembers].DefaultDisplayPropertySet ->
            Status, Name, DisplayName
    Members
        # ScriptMethod
        $_.ConvertToDateTime() -> {
            [System.Management.ManagementDateTimeConverter]::ToDateTime($args[0])
        }
Types
    Name : System.Array
    Members
        # AliasProperty
        $_.Count -> $_.Length
    Members
        # ScriptProperty
        $_.Age -> { ((Get-Date) - ($this.CreationTime)).Days }
    Members
        # CodeProperty
        $_.Mode ->
        [Microsoft.PowerShell.Commands.FileSystemProvider].Mode
    Members
        # NoteProperty
        $_.Status -> Value
    Members
        [PSStandardMembers].DefaultDisplayPropertySet ->
            Status, Name, DisplayName
    Members
        # ScriptMethod
        $_.ConvertToDateTime() -> {
            [System.Management.ManagementDateTimeConverter]::ToDateTime($args[0])
            [System.Management.ManagementDateTimeConverter]::ToDateTime($args[0])
        }
'@
