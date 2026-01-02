function getComponentByMatchCaption(obj, str_match)
    return synchronize(function()
        for i = 0, obj.ComponentCount - 1 do
            if obj.Component[i].Caption and obj.Component[i].Caption:match(str_match) then
                return obj.Component[i]
            end
        end
    end)
end

function getFormbyName(string)
    for i = 0, getFormCount() - 1 do
        local root = getForm(i)
        local root_name = root.ClassName
        if root_name == string then
            return root;
        end
    end
    if root_name ~= string then
        return nil
    end
end

atlas = getFormbyName("TfrmTracer")
atlas.lvTracer.OnDblClick = function(s)
    local a, b, c
    if s.Selected and s.Selected.getText():match("^(.-)%s%-") then
        a = getAddress(s.Selected.getText():match("^(.-)%s%-")) -- resolve text : address - opcode --> address

        if targetIs64Bit() then
            b = getAddress(getComponentByMatchCaption(s.Owner, "RIP").Caption:match("^%S+%s+(%S+)"))
        else
            b = getAddress(getComponentByMatchCaption(s.Owner, "EIP").Caption:match("^%S+%s+(%S+)"))
        end

        if a ~= b then
            c = b -- follow EIP instead.
        else
            c = a
        end

        getMemoryViewForm().DisassemblerView.SelectedAddress = c
    end
end

