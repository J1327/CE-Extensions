-- Build MD5 tables for symbols matching given module patterns
local function buildSymbolMd5Table(...)
    local results = {}
    local symbolList = getMainSymbolList().getSymbolList()
    local modulePatterns = {...}

    for patternIndex, modulePattern in ipairs(modulePatterns) do
        local symbolHashes = {}
        results[patternIndex] = symbolHashes

        for symbolName, symbolAddress in pairs(symbolList) do
            if symbolName:match(modulePattern) then
                local startAddr, approxEndAddr = x1327.Function[8](symbolAddress)
                local approxSize = approxEndAddr - startAddr
                symbolHashes[symbolName] = md5memory(symbolName, approxSize)
            end
        end
    end

    return results
end

-- Compare symbol MD5 tables between CE process and target process
local function compareModuleMd5Tables(...)
    local modulePatterns = {...}
    if #modulePatterns == 0 then
        return
    end

    local targetPID
    if process ~= nil then
        targetPID = getProcessIDFromProcessName(process)
    end

    local comparisonOk = true

    -- Collect hashes from Cheat Engine process
    openProcess(getCheatEngineProcessID())
    waitForPDB()
    local ceHashes = buildSymbolMd5Table(table.unpack(modulePatterns))

    -- Collect hashes from target process
    if targetPID then
        openProcess(targetPID)
        waitForPDB()
    end
    local targetHashes = buildSymbolMd5Table(table.unpack(modulePatterns))

    -- Compare
    for moduleIndex = 1, #ceHashes do
        local ceModule = ceHashes[moduleIndex]
        local targetModule = targetHashes[moduleIndex]

        for symbolName, ceHash in pairs(ceModule) do
            local targetHash = targetModule[symbolName]

            if not targetHash then
                print(
                    "(" .. debug.getinfo(1).currentline .. ")",
                    "DEBUG_INFO : Couldn't find symbol loaded",
                    symbolName
                )
                comparisonOk = false

            elseif ceHash ~= targetHash then
                print(
                    "(" .. debug.getinfo(1).currentline .. ")",
                    "DEBUG_INFO : Different symbol code detected",
                    symbolName
                )
                comparisonOk = false
            end
        end
    end

    if comparisonOk then
        print(
            "(" .. debug.getinfo(1).currentline .. ")",
            "DEBUG_INFO : Looks good (or CE compared against itself)"
        )
    end
end

-- Example usage
compareModuleMd5Tables("ntdll", "KERNEL32", "KERNELBASE")
