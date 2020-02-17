@'
# DefaultSettings
# SelectionSets
# Controls
# ViewDefinitions
Views
    Name : ViewName
    SelectBy
        [TypeName]
        # (SetName)

    # Controls
    GroupBy
        Label : Label Text
        $_.PropName
        # { ScriptBlock }
        CtrlName : ControlName
        # Entries

    Table
        # -AutoSize
        # -HideTableHeaders
        Headers
            Label : Mode
            Width : 20
            Alignment : Left
        Rows
            SelectBy
                [TypeName]
            Items
                Alignment : Center
                $_.Mode
        Headers
            Label : LastWriteTime
            Width : 50
            Alignment : Right
        Rows
            Items
                { $_.LastWriteTime }
        Headers
            Label : Name
            # Width : 50
            Alignment : Right
        Rows
            Items
                { $_.Name }
            
    # List
    # Wide
    # CustomCtrl
'@
