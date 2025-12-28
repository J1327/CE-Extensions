if heapForm then
    heapForm.show()
    return
end

heapForm = createForm()
heapForm.setCaption("Heaplist v20241115224109")
heapForm.setBorderStyle(2)
heapForm.setSize(800, 600)
heapForm.setPosition(getScreenHeight() / 2, getScreenHeight() / 2)
heapForm.onClose = function(self) self.hide() end

-- Heap list view
heapListView = createListView(heapForm)
heapListView.RowSelect = true
heapListView.HideSelection = true
heapListView.ReadOnly = true
heapListView.Anchors = [[akTop,akBottom,akRight,akLeft]]
heapListView.setSize(heapForm.getWidth(), heapForm.getHeight())

heapListView.OnClick = function()
    if heapListView.Selected then
        getMemoryViewForm().HexadecimalView.Address =
            getAddressSafe(heapListView.Selected.Caption)
    end
end

-- Columns
do
    local col = heapListView.Columns.add()
    col.Caption = "Address"
    col.Width = 150

    col = heapListView.Columns.add()
    col.Caption = "Size"
    col.Width = 85

    col = heapListView.Columns.add()
    col.Caption = "Overhead Bytes"
    col.Width = 150

    col = heapListView.Columns.add()
    col.Caption = "isRegionIndex"
    col.Width = 125

    col = heapListView.Columns.add()
    col.Caption = "Flags"
    col.Width = 250

    col = heapListView.Columns.add()
    col.Caption = "Allocation Base"
    col.Width = 150

    col = heapListView.Columns.add()
    col.Caption = "Base"
    col.Width = 185

    col = heapListView.Columns.add()
    col.Caption = "Size"
    col.Width = 185
end

-- Menu
heapForm.Menu = createMainMenu(heapForm)

local rootMenuItem = createMenuItem(heapForm.Menu)
rootMenuItem.Caption = "| Heap list kit |"
heapForm.Menu.Items.add(rootMenuItem)

-- Load all heaps
local loadAllItem = createMenuItem(heapForm.Menu)
loadAllItem.Caption = "| Load / Reload ALL |"
rootMenuItem.add(loadAllItem)

loadAllItem.onClick = function()
    createThread(function()
        heapListView.Items.clear()

        local heapEntryPtr = allocateMemory(0x1)
        registerSymbol("PROCESS_HEAP_ENTRY", heapEntryPtr)

        local mbiPtr = allocateMemory(0x1)
        registerSymbol("PMEMORY_BASIC_INFORMATION", mbiPtr)

        local processHeap = executeCodeEx(nil, nil, "GetProcessHeap")
        local previousAddress
        local currentAddress = 0

        while true do
            if not readInteger(processHeap) then
                error("")
            end

            if not executeCodeEx(nil, nil, "HeapValidate", processHeap, 0x0, currentAddress) then
                error("")
            end

            executeCodeEx(nil, nil, "HeapWalk", processHeap, heapEntryPtr)
            currentAddress = readQword(heapEntryPtr)

            if currentAddress == previousAddress then
                break
            end

            executeCodeEx(nil, nil, getAddress("VirtualQuery"), currentAddress, mbiPtr, 0x64)

            local item = heapListView.Items.add()

            if targetIs64Bit() then
                item.Caption = string.format("%X", readQword(getAddressSafe(heapEntryPtr)))
                item.SubItems.add(string.format("%X", readInteger(getAddressSafe(heapEntryPtr + 0x08))))
                item.SubItems.add(string.format("%X", readByte(getAddressSafe(heapEntryPtr + 0x0C))))
                item.SubItems.add(string.format("%X", readByte(getAddressSafe(heapEntryPtr + 0x0D))))

                local flag = string.format("%X", readByte(getAddressSafe(heapEntryPtr + 0x0E)))
                if flag == "0" then
                    item.SubItems.add("NOT_SET")
                elseif flag == "1" then
                    item.SubItems.add("PROCESS_HEAP_REGION")
                elseif flag == "2" then
                    item.SubItems.add("PROCESS_HEAP_UNCOMMITTED_RANGE")
                elseif flag == "4" then
                    item.SubItems.add("PROCESS_HEAP_ENTRY_BUSY")
                elseif flag == "10" then
                    item.SubItems.add("PROCESS_HEAP_ENTRY_MOVEABLE")
                elseif flag == "20" then
                    item.SubItems.add("PROCESS_HEAP_ENTRY_DDESHARE")
                else
                    item.SubItems.add(flag)
                end

                item.SubItems.add(string.format("%X", readQword(getAddress("PMEMORY_BASIC_INFORMATION+0x0008"))))
                item.SubItems.add(string.format("%X", readQword(getAddress("PMEMORY_BASIC_INFORMATION"))))
                item.SubItems.add(string.format("%X", readQword(getAddress("PMEMORY_BASIC_INFORMATION+0x0018"))))
            else
                item.Caption = string.format("%X", readInteger(getAddressSafe(heapEntryPtr)))
                item.SubItems.add(string.format("%X", readInteger(getAddressSafe(heapEntryPtr + 0x04))))
                item.SubItems.add(string.format("%X", readByte(getAddressSafe(heapEntryPtr + 0x08))))
                item.SubItems.add(string.format("%X", readByte(getAddressSafe(heapEntryPtr + 0x09))))

                local flag = string.format("%X", readByte(getAddressSafe(heapEntryPtr + 0x0A)))
                if flag == "0" then
                    item.SubItems.add("NOT_SET")
                elseif flag == "1" then
                    item.SubItems.add("PROCESS_HEAP_REGION")
                elseif flag == "2" then
                    item.SubItems.add("PROCESS_HEAP_UNCOMMITTED_RANGE")
                elseif flag == "4" then
                    item.SubItems.add("PROCESS_HEAP_ENTRY_BUSY")
                elseif flag == "10" then
                    item.SubItems.add("PROCESS_HEAP_ENTRY_MOVEABLE")
                elseif flag == "20" then
                    item.SubItems.add("PROCESS_HEAP_ENTRY_DDESHARE")
                else
                    item.SubItems.add(flag)
                end

                item.SubItems.add(string.format("%X", readInteger(getAddress("PMEMORY_BASIC_INFORMATION+0x04"))))
                item.SubItems.add(string.format("%X", readInteger(getAddress("PMEMORY_BASIC_INFORMATION"))))
                item.SubItems.add(string.format("%X", readInteger(getAddress("PMEMORY_BASIC_INFORMATION+0x0C"))))
            end

            previousAddress = currentAddress
        end

        deAlloc(heapEntryPtr)
        unregisterSymbol("PROCESS_HEAP_ENTRY")

        deAlloc(mbiPtr)
        unregisterSymbol("PMEMORY_BASIC_INFORMATION")
    end)
end
