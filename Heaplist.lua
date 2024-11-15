if heapform then heapform.show() return end
heapform = createForm()
heapform.setCaption("Heaplist v20241115224109") -- prev. was v20241022124237
heapform.setBorderStyle(2)
heapform.setSize(800, 600)
heapform.setPosition(getScreenHeight() / 2, getScreenHeight() / 2)

heapform.onClose = function(self) self.Hide() end 

heaplist = createListView(heapform)
heaplist.RowSelect = true
heaplist.HideSelection = true
heaplist.ReadOnly = true
heaplist.Anchors = [[akTop,akBottom,akRight,akLeft]]
heaplist.setSize(heapform.getWidth(), heapform.getHeight())

heaplist.OnClick = function()
    if heaplist.Selected then
        getMemoryViewForm().HexadecimalView.Address = getAddressSafe(heaplist.Selected.Caption)
    end
end

local tmp = heaplist.Columns.add()
tmp.Caption = "Address"
tmp.width = 150
local tmp = heaplist.Columns.add()
tmp.Caption = "Size"
tmp.width = 85
local tmp = heaplist.Columns.add()
tmp.Caption = "Overhead Bytes"
tmp.width = 150
local tmp = heaplist.Columns.add()
tmp.Caption = "isRegionIndex"
tmp.width = 125
local tmp = heaplist.Columns.add()
tmp.Caption = "Flags"
tmp.width = 250
local tmp = heaplist.Columns.add()
tmp.Caption = "Allocation Base"
tmp.width = 150
local tmp = heaplist.Columns.add()
tmp.Caption = "Base"
tmp.width = 185
local tmp = heaplist.Columns.add()
tmp.Caption = "Size"
tmp.width = 185

heapform.Menu = createMainMenu(heapform)
mi = createMenuItem(heapform.Menu)
mi.Caption = "| Heap list kit |"
heapform.Menu.Items.add(mi)

miII = createMenuItem(heapform.Menu)
miII.Caption = "| Load / Reload ALL |"
mi.add(miII)
miII.onClick = function()
    createThread(function() -- TAKES TOO MUCH TIME CLEANING AND WRITING
        heaplist.items.clear()
        AM = allocateMemory(0x1);
        registerSymbol('PROCESS_HEAP_ENTRY', AM)
        SUB_AM = allocateMemory(0x1)
        registerSymbol('PMEMORY_BASIC_INFORMATION', SUB_AM)

        local PROCESS_HEAP = executeCodeEx(nil, nil, 'GetProcessHeap')
        local isStuck , isValid
        local notStuck = 0
        while true do
            if not readInteger(PROCESS_HEAP) then
                return error("")
            end
            if not executeCodeEx(nil, nil, 'HeapValidate', PROCESS_HEAP, 0x0,notStuck) then -- before accessing next address validate previous
                return error("")
            end
            executeCodeEx(nil, nil, 'HeapWalk', PROCESS_HEAP, AM)
            notStuck = readQword(AM)
            if notStuck == isStuck then
                break
            end
            executeCodeEx(nil, nil, getAddress("VirtualQuery"), notStuck, SUB_AM, 0x64)

            if targetIs64Bit() then
                local blank = heaplist.Items.add()
                blank.setCaption(string.format("%X", readQword(getAddressSafe(AM))))
                blank.SubItems.add(string.format("%X", readInteger(getAddressSafe(AM + 0x08))))
                blank.SubItems.add(string.format("%X", readByte(getAddressSafe(AM + 0x0C))))
                blank.SubItems.add(string.format("%X", readByte(getAddressSafe(AM + 0x0D))))
                local tmp = string.format("%X", readByte(getAddressSafe(AM + 0x0E)))
                if tmp == '0' then
                    blank.SubItems.add('NOT_SET')
                elseif tmp == '1' then
                    blank.SubItems.add('PROCESS_HEAP_REGION')
                elseif tmp == '2' then
                    blank.SubItems.add('PROCESS_HEAP_UNCOMMITTED_RANGE')
                elseif tmp == '4' then
                    blank.SubItems.add('PROCESS_HEAP_ENTRY_BUSY')
                elseif tmp == '10' then
                    blank.SubItems.add('PROCESS_HEAP_ENTRY_MOVEABLE')
                elseif tmp == '20' then
                    blank.SubItems.add('PROCESS_HEAP_ENTRY_DDESHARE')
                else
                    blank.SubItems.add(tmp)
                end
                blank.SubItems.add(string.format("%X", readQword(getAddress('PMEMORY_BASIC_INFORMATION+0x0008'))))
                blank.SubItems.add(string.format("%X", readQword(getAddress('PMEMORY_BASIC_INFORMATION'))))
                blank.SubItems.add(string.format("%X", readQword(getAddress('PMEMORY_BASIC_INFORMATION+0x0018'))))

            else
                local blank = heaplist.Items.add()
                blank.setCaption(string.format("%X", readInteger(getAddressSafe(AM))))
                blank.SubItems.add(string.format("%X", readInteger(getAddressSafe(AM + 0x0004))))
                blank.SubItems.add(string.format("%X", readByte(getAddressSafe(AM + 0x0008))))
                blank.SubItems.add(string.format("%X", readByte(getAddressSafe(AM + 0x0009))))
                local tmp = string.format("%X", readByte(getAddressSafe(AM + 0x000A)))
                if tmp == '0' then
                    blank.SubItems.add('NOT_SET')
                elseif tmp == '1' then
                    blank.SubItems.add('PROCESS_HEAP_REGION')
                elseif tmp == '2' then
                    blank.SubItems.add('PROCESS_HEAP_UNCOMMITTED_RANGE')
                elseif tmp == '4' then
                    blank.SubItems.add('PROCESS_HEAP_ENTRY_BUSY')
                elseif tmp == '10' then
                    blank.SubItems.add('PROCESS_HEAP_ENTRY_MOVEABLE')
                elseif tmp == '20' then
                    blank.SubItems.add('PROCESS_HEAP_ENTRY_DDESHARE')
                else
                    blank.SubItems.add(tmp)
                end

                blank.SubItems.add(string.format("%X", readInteger(getAddress('PMEMORY_BASIC_INFORMATION+0x04'))))
                blank.SubItems.add(string.format("%X", readInteger(getAddress('PMEMORY_BASIC_INFORMATION'))))
                blank.SubItems.add(string.format("%X", readInteger(getAddress('PMEMORY_BASIC_INFORMATION+0x0C'))))
            end

            isStuck = notStuck
        end
        deAlloc(AM);
        unregisterSymbol('PROCESS_HEAP_ENTRY');
        AM = nil;
        deAlloc(SUB_AM)
        unregisterSymbol('PMEMORY_BASIC_INFORMATION')
        SUB_AM = nil;
    end)
end

miII = createMenuItem(heapform.Menu)
miII.Caption = "| Load / Reload Specific Heap Handle |"
mi.add(miII)
miII.onClick = function()
    -- Get process heaps module --> function

    GetProcessHeaps = {}
    GetProcessHeaps._ = {}

    function GetProcessHeaps._:Count()
        return executeCodeEx(nil, nil, 'GetProcessHeaps', 0, 0)
    end

    function GetProcessHeaps._:GetProcessHeap()
        return executeCodeEx(nil, nil, 'GetProcessHeap')
    end

    function GetProcessHeaps.Update()
        local s = 0
        local c = GetProcessHeaps._:Count()

        AM = allocateMemory(0x1)
        local a = AM -- might lead to corruption?
        executeCodeEx(nil, nil, 'GetProcessHeaps', c, a)
        local low, high = s, s
        local d
        for i = 1, c do
            if targetIs64Bit() then
                d = readQword(a + s)
            else
                d = readInteger(a + s)
            end

            if low == 0 or d < low then
                low = d
            elseif d > high then
                high = d;
            end

            local o = string.format("%X", d)
            if o ~= GetProcessHeaps[i] then
                if targetIs64Bit() then
                    GetProcessHeaps[i] = string.format("%X", readQword(a + s))
                    s = s + 8
                else
                    GetProcessHeaps[i] = string.format("%X", readInteger(a + s))
                    s = s + 4
                end
            end
        end

        if GetProcessHeaps.First ~= GetProcessHeaps[1] or GetProcessHeaps.First == nil then
            GetProcessHeaps.First = GetProcessHeaps[1]
        end
        if GetProcessHeaps.Last ~= GetProcessHeaps[c] or GetProcessHeaps.Last == nil then
            GetProcessHeaps.Last = GetProcessHeaps[c]
        end
        if GetProcessHeaps.High == nil or high ~= tonumber(GetProcessHeaps.High, 16) then
            GetProcessHeaps.High = string.format("%X", high)
        end
        if GetProcessHeaps.Low == nil or high ~= tonumber(GetProcessHeaps.Low, 16) then
            GetProcessHeaps.Low = string.format("%X", low)
        end

        deAlloc(AM)

        -- In case in need , don't repeat yourself
        local _ = {

            getFirst = function(self)
                return GetProcessHeaps.First
            end,
            getLast = function(self)
                return GetProcessHeaps.Last
            end,
            getHigh = function(self)
                return GetProcessHeaps.High
            end,
            getLow = function(self)
                return GetProcessHeaps.Low
            end
        }

        return _

    end

    -- actually menu item function

    local heap_csl, adr
    local c = GetProcessHeaps._:Count()
    if not c then
        return
    else
        GetProcessHeaps.Update();
        heap_csl = createStringlist()
    end
    for i = 1, c do
        heap_csl.add(GetProcessHeaps[i])
    end
    if heap_csl then
        local id = showSelectionList("Found " .. c .. " heap handles", "Select specific heap handle to enum", heap_csl,
            false, nil) + 1
        if not id then
            return
        end
        local adr = GetProcessHeaps[id]
        if not readInteger(adr) then
            error("")
        end
        createThread(function() -- TAKES TOO MUCH TIME CLEANING AND WRITING
            heaplist.items.clear()
            AM = allocateMemory(0x1);
            registerSymbol('PROCESS_HEAP_ENTRY', AM)
            SUB_AM = allocateMemory(0x1)
            registerSymbol('PMEMORY_BASIC_INFORMATION', SUB_AM)

            local PROCESS_HEAP = executeCodeEx(nil, nil, 'GetProcessHeap')
            local isStuck , isValid
            local notStuck = 0
            while true do
                if not readInteger(PROCESS_HEAP) then
                    return error("")
                end
                if not executeCodeEx(nil, nil, 'HeapValidate', PROCESS_HEAP, 0x0,notStuck) then -- before accessing next address validate previous
                    return error("")
                end
                executeCodeEx(nil, nil, 'HeapWalk', PROCESS_HEAP, AM)
                notStuck = readQword(AM)
                if notStuck == isStuck then
                    break
                end



                executeCodeEx(nil, nil, getAddress("VirtualQuery"), notStuck, SUB_AM, 0x64)

                if targetIs64Bit() then
                    local blank = heaplist.Items.add()
                    blank.setCaption(string.format("%X", readQword(getAddressSafe(AM))))
                    blank.SubItems.add(string.format("%X", readInteger(getAddressSafe(AM + 0x08))))
                    blank.SubItems.add(string.format("%X", readByte(getAddressSafe(AM + 0x0C))))
                    blank.SubItems.add(string.format("%X", readByte(getAddressSafe(AM + 0x0D))))
                    local tmp = string.format("%X", readByte(getAddressSafe(AM + 0x0E)))
                    if tmp == '0' then
                        blank.SubItems.add('NOT_SET')
                    elseif tmp == '1' then
                        blank.SubItems.add('PROCESS_HEAP_REGION')
                    elseif tmp == '2' then
                        blank.SubItems.add('PROCESS_HEAP_UNCOMMITTED_RANGE')
                    elseif tmp == '4' then
                        blank.SubItems.add('PROCESS_HEAP_ENTRY_BUSY')
                    elseif tmp == '10' then
                        blank.SubItems.add('PROCESS_HEAP_ENTRY_MOVEABLE')
                    elseif tmp == '20' then
                        blank.SubItems.add('PROCESS_HEAP_ENTRY_DDESHARE')
                    else
                        blank.SubItems.add(tmp)
                    end
                    blank.SubItems.add(string.format("%X", readQword(getAddress('PMEMORY_BASIC_INFORMATION+0x0008'))))
                    blank.SubItems.add(string.format("%X", readQword(getAddress('PMEMORY_BASIC_INFORMATION'))))
                    blank.SubItems.add(string.format("%X", readQword(getAddress('PMEMORY_BASIC_INFORMATION+0x0018'))))

                else
                    local blank = heaplist.Items.add()
                    blank.setCaption(string.format("%X", readInteger(getAddressSafe(AM))))
                    blank.SubItems.add(string.format("%X", readInteger(getAddressSafe(AM + 0x0004))))
                    blank.SubItems.add(string.format("%X", readByte(getAddressSafe(AM + 0x0008))))
                    blank.SubItems.add(string.format("%X", readByte(getAddressSafe(AM + 0x0009))))
                    local tmp = string.format("%X", readByte(getAddressSafe(AM + 0x000A)))
                    if tmp == '0' then
                        blank.SubItems.add('NOT_SET')
                    elseif tmp == '1' then
                        blank.SubItems.add('PROCESS_HEAP_REGION')
                    elseif tmp == '2' then
                        blank.SubItems.add('PROCESS_HEAP_UNCOMMITTED_RANGE')
                    elseif tmp == '4' then
                        blank.SubItems.add('PROCESS_HEAP_ENTRY_BUSY')
                    elseif tmp == '10' then
                        blank.SubItems.add('PROCESS_HEAP_ENTRY_MOVEABLE')
                    elseif tmp == '20' then
                        blank.SubItems.add('PROCESS_HEAP_ENTRY_DDESHARE')
                    else
                        blank.SubItems.add(tmp)
                    end
                    blank.SubItems.add(string.format("%X", readInteger(getAddress('PMEMORY_BASIC_INFORMATION+0x04'))))
                    blank.SubItems.add(string.format("%X", readInteger(getAddress('PMEMORY_BASIC_INFORMATION'))))
                    blank.SubItems.add(string.format("%X", readInteger(getAddress('PMEMORY_BASIC_INFORMATION+0x0C'))))
                end

                isStuck = notStuck
            end
            deAlloc(AM);
            unregisterSymbol('PROCESS_HEAP_ENTRY');
            AM = nil;
            deAlloc(SUB_AM)
            unregisterSymbol('PMEMORY_BASIC_INFORMATION')
            SUB_AM = nil;
        end)
    end
end

