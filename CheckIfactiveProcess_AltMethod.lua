function CheckProcess()
    if readInteger(process) then
        local u = createStringlist()
        getThreadlist(u)
        if u.Count > 1 then
            return true, u.Count
        else
            return false
        end
    else
        return false
    end
end

return CheckProcess()
