-- notes: adjust delay "500"

function x64_suspend()
    if (readInteger(process)) then
        executeCodeEx(0, 0,"ntdll.NtSuspendProcess",-1))
    end
end

function x64_unsuspend()
    if (readInteger(process)) then
        executeCodeEx(0, 0,"ntdll.NtResumeProcess",-1)
    end
end

--x64_suspend()
--x64_unsuspend()
