-- Cleanup previous instance
if InstructionAccessInspector  and InstructionAccessInspector .Form then
    InstructionAccessInspector .Form.destroy()
end

InstructionAccessInspector  = {}

-- Main form
local mainForm = createForm()
InstructionAccessInspector .Form = mainForm
mainForm.setSize(900, 600)
mainForm.Caption = "Find out what access this instruction"
mainForm.setBorderStyle(2)

mainForm.OnClose = function()
    mainForm.destroy()
    InstructionAccessInspector  = nil
end

-- Address label
local addressLabel = createLabel(mainForm)
addressLabel.Caption = "Code Address"
InstructionAccessInspector .AddressLabel = addressLabel

-- Address edit
local addressEdit = createEdit(mainForm)
addressEdit.setPosition(200, 0)
addressEdit.setSize(333, 0)
addressEdit.ReadOnly = true
addressEdit.NumbersOnly = true
addressEdit.Text = string.format("%X", getMemoryViewForm().DisassemblerView.SelectedAddress)
InstructionAccessInspector .AddressLine = addressEdit

-- Breakpoint settings group
local breakpointGroup = createGroupBox(mainForm)
breakpointGroup.setSize(858, 110)
breakpointGroup.setPosition(25, 35)
breakpointGroup.Caption = "Breakpoint settings"
InstructionAccessInspector .ControllerCover = breakpointGroup

-- Settings array
InstructionAccessInspector .Settings = {}
InstructionAccessInspector .Settings[1] = 2 -- exception breakpoint
InstructionAccessInspector .Settings[2] = 1 -- default trigger
InstructionAccessInspector .Settings[3] = 1 -- size

-- Breakpoint method
local exceptionCheckbox = createCheckBox(breakpointGroup)
exceptionCheckbox.Caption = "Exception Breakpoint"
exceptionCheckbox.setPosition(350, 0)
exceptionCheckbox.Checked = true
exceptionCheckbox.Enabled = false
InstructionAccessInspector .Method0 = exceptionCheckbox

-- Trigger: Execute
local onExecuteCheckbox = createCheckBox(breakpointGroup)
onExecuteCheckbox.Caption = "OnExecute"
onExecuteCheckbox.setPosition(200, 0)
InstructionAccessInspector .Trigger0 = onExecuteCheckbox

onExecuteCheckbox.OnChange = function()
    if onExecuteCheckbox.Checked then
        InstructionAccessInspector .Trigger1.Checked = false
        InstructionAccessInspector .Trigger2.Checked = false
        InstructionAccessInspector .Settings[2] = 0
    end
end

-- Trigger: Read/Write
local onReadWriteCheckbox = createCheckBox(breakpointGroup)
onReadWriteCheckbox.Caption = "OnReadWrite"
onReadWriteCheckbox.setPosition(200, 25)
onReadWriteCheckbox.Checked = true
InstructionAccessInspector .Trigger1 = onReadWriteCheckbox

onReadWriteCheckbox.OnChange = function()
    if onReadWriteCheckbox.Checked then
        setProperty(onExecuteCheckbox, "Checked", false)
        setProperty(InstructionAccessInspector .Trigger2, "Checked", false)
        InstructionAccessInspector .Settings[2] = 1
    end
end

-- Trigger: Write
local onWriteCheckbox = createCheckBox(breakpointGroup)
onWriteCheckbox.Caption = "OnWrite"
onWriteCheckbox.setPosition(200, 50)
InstructionAccessInspector .Trigger2 = onWriteCheckbox

onWriteCheckbox.OnChange = function()
    if onWriteCheckbox.Checked then
        setProperty(onReadWriteCheckbox, "Checked", false)
        setProperty(onExecuteCheckbox, "Checked", false)
        InstructionAccessInspector .Settings[2] = 2
    end
end

-- RTTI checkbox
local rttiCheckbox = createCheckBox(breakpointGroup)
rttiCheckbox.Caption = "Solve RTTI"
rttiCheckbox.setPosition(585, 0)
InstructionAccessInspector .ChkRTTI = rttiCheckbox

-- Read mode (disabled)
local readLogCheckbox = createCheckBox(breakpointGroup)
readLogCheckbox.Caption = "Read as log"
readLogCheckbox.setPosition(50, 0)
readLogCheckbox.Enabled = false
readLogCheckbox.Checked = true
readLogCheckbox.ShowHint = true
readLogCheckbox.Hint =
    "this option means it will try match existing items with incoming one and count"
InstructionAccessInspector .Read0 = readLogCheckbox

local readOpcodeCheckbox = createCheckBox(breakpointGroup)
readOpcodeCheckbox.Caption = "from opcode"
readOpcodeCheckbox.setPosition(50, 25)
readOpcodeCheckbox.Enabled = false
readOpcodeCheckbox.ShowHint = true
readOpcodeCheckbox.Hint =
    "this option means it will try act as default what access form"
InstructionAccessInspector .Read1 = readOpcodeCheckbox

-- Log window button
local logButton = createButton(mainForm)
logButton.setPosition(150, 150)
logButton.setSize(70, 50)
logButton.setCaption("Log")
InstructionAccessInspector .Form.LogBTN = logButton

logButton.OnClick = function()
    if not InstructionAccessInspector .Form2 then
        local logForm = createForm()
        InstructionAccessInspector .Form2 = logForm

        logForm.setPosition(mainForm.Left + mainForm.Width + 25, mainForm.Top)
        logForm.setSize(500, 400)
        logForm.setCaption("Log of 0x" .. addressEdit.Text)
        logForm.setBorderStyle(2)

        local logMemo = createMemo(logForm)
        logMemo.setSize(500, 400)
        logMemo.Anchors = [[akTop,akLeft,akBottom,akRight]]
        logMemo.ReadOnly = true
        logForm.log = logMemo

        logForm.OnClose = function()
            logForm.hide()
        end
    else
        InstructionAccessInspector .Form2.show()
    end
end

-- Inspect button
local inspectButton = createButton(mainForm)
inspectButton.setPosition(375, 150)
inspectButton.setSize(200, 50)
inspectButton.Caption = "Inspect"
InstructionAccessInspector .Check = inspectButton

inspectButton.OnClick = function()
    inspectButton.Enabled = false
    InstructionAccessInspector .Stop.Enabled = true
    InstructionAccessInspector .TempData = {}

    if targetIs64Bit() then
        InstructionAccessInspector .TempDataII = {RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP, R8, R9, R10, R11, R12, R13, R14, R15, RIP}
        InstructionAccessInspector .TempDataIII = {
            "RAX","RBX","RCX","RDX","RSI","RDI","RBP","RSP",
            "R8","R9","R10","R11","R12","R13","R14","R15","RIP"
        }
    else
        InstructionAccessInspector .TempDataII = {EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP, EIP}
        InstructionAccessInspector .TempDataIII = {"EAX","EBX","ECX","EDX","ESI","EDI","EBP","ESP","EIP"}
    end

    debug_setBreakpoint(
        addressEdit.Text,
        InstructionAccessInspector .Settings[3],
        InstructionAccessInspector .Settings[2],
        InstructionAccessInspector .Settings[1],
        function()
            -- Refresh registers
            if targetIs64Bit() then
                InstructionAccessInspector .TempDataII = {
                    RAX,RBX,RCX,RDX,RSI,RDI,RBP,RSP,
                    R8,R9,R10,R11,R12,R13,R14,R15,RIP
                }
            else
                InstructionAccessInspector .TempDataII = {EAX,EBX,ECX,EDX,ESI,EDI,EBP,ESP,EIP}
            end

            -- Logging
            if InstructionAccessInspector .Form2 and InstructionAccessInspector .Form2.Visible then
                local sl = createStringList()
                for i = 1, #InstructionAccessInspector .TempDataII do
                    local rtti = getRTTIClassName(InstructionAccessInspector .TempDataII[i]) or false
                    if rtti then
                        sl.add(
                            InstructionAccessInspector .TempDataIII[i] ..
                            " 0x" .. string.format("%X", InstructionAccessInspector .TempDataII[i]) ..
                            "==" .. rtti
                        )
                    else
                        sl.add(
                            InstructionAccessInspector .TempDataIII[i] ..
                            " 0x" .. string.format("%X", InstructionAccessInspector .TempDataII[i])
                        )
                    end
                end
                InstructionAccessInspector .Form2.log.Lines.addText(
                    sl.getText():gsub("%s*\n%s*", " ")
                )
            end

            -- Result matching
            local snapshot = {}
            for i = 1, #InstructionAccessInspector .TempDataII do
                table.insert(snapshot, string.format("%X", InstructionAccessInspector .TempDataII[i]))
            end

            local matched
            for i = 0, InstructionAccessInspector .Results.Items.Count - 1 do
                if InstructionAccessInspector .Results.Items.Item[i].SubItems.Text
                    :match("^%s*(.-)%s*$")
                    :gsub("\x0d\x0a", "\x0a")
                    ==
                    table.concat(snapshot, "\n"):match("^%s*(.-)%s*$")
                then
                    InstructionAccessInspector .Results.Items.Item[i].Caption =
                        InstructionAccessInspector .Results.Items.Item[i].Caption + 1
                    matched = true
                    break
                end
            end

            if not matched then
                local item = InstructionAccessInspector .Results.Items.add()
                item.Caption = 0
                for i = 1, #InstructionAccessInspector .TempDataIII do
                    item.SubItems.add(
                        string.format("%X", _G[InstructionAccessInspector .TempDataIII[i]])
                    )
                end
            end
        end
    )
end

-- Results list
local resultsList = createListView(mainForm)
InstructionAccessInspector .Results = resultsList
resultsList.Anchors = [[akLeft,akBottom,akRight,akTop]]
resultsList.BorderStyle = 2
resultsList.setPosition(25, 205)
resultsList.setSize(875, 375)
resultsList.GridLines = true

-- Quick column helper
InstructionAccessInspector .qca = function(columnBase, caption, width)
    local col = columnBase.add()
    col.Caption = caption
    col.Width = width
    return col
end

-- Columns
if targetIs64Bit() then
    InstructionAccessInspector .qca(resultsList.Columns, "Count", 100)
    for _, reg in ipairs({
        "RAX","RBX","RCX","RDX","RSI","RDI","RBP","RSP",
        "R8","R9","R10","R11","R12","R13","R14","R15","RIP"
    }) do
        InstructionAccessInspector .qca(resultsList.Columns, reg, 50)
    end
else
    InstructionAccessInspector .qca(resultsList.Columns, "Count", 100)
    for _, reg in ipairs({"EAX","EBX","ECX","EDX","ESI","EDI","EBP","ESP","EIP"}) do
        InstructionAccessInspector .qca(resultsList.Columns, reg, 85)
    end
end

-- Clear button
local clearButton = createButton(mainForm)
clearButton.setPosition(300, 150)
clearButton.setSize(75, 50)
clearButton.Caption = "Clear"
InstructionAccessInspector .Clean = clearButton

clearButton.OnClick = function()
    resultsList.Items.clear()
    if InstructionAccessInspector .Form2 then
        InstructionAccessInspector .Form2.log.clear()
    end
    InstructionAccessInspector .TempData = {}
end

-- Stop button
local stopButton = createButton(mainForm)
stopButton.Caption = "Stop"
stopButton.Enabled = false
stopButton.setPosition(225, 150)
stopButton.setSize(75, 50)
InstructionAccessInspector .Stop = stopButton

stopButton.OnClick = function()
    for i = 1, #debug_getBreakpointList() do
        if string.format("%X", debug_getBreakpointList()[i]) == addressEdit.Text then
            debug_removeBreakpoint(debug_getBreakpointList()[i])
        end
    end
    inspectButton.Enabled = true
    clearButton.Enabled = true
    mainForm.Enabled = true
end
