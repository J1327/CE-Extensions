function DoMemoryViewFormMenuClick(PrimaryItem, SubItem)
    if (PrimaryItem and SubItem) then
        for i = 0, getMemoryViewForm().MainMenu1.Items.Count - 1 do
            if getMemoryViewForm().MainMenu1.Items.Item[i].Name == PrimaryItem then
                for u = 0, getMemoryViewForm().MainMenu1.Items.Item[i].Count - 1 do
                    if getMemoryViewForm().MainMenu1.Items.Item[i].Item[u].Name == SubItem then
                        return getMemoryViewForm().MainMenu1.Items.Item[i].Item[u].doClick()
                    end
                end
                break
            end
        end
    end
end
-- OPTional
registerLuaFunctionHighlight("DoMemoryViewFormMenuClick")
-- Example
DoMemoryViewFormMenuClick("View1", "Debugstrings1")
DoMemoryViewFormMenuClick("View1", "miDebugEvents")

-- Possible variants (CE75) :
--[[
File1 | Corresponds to "File" 
         Newwindow1 | Corresponds to "New window" 
         Loadsymbolfile1 | Corresponds to "Load symbol file" 
         Savedisassemledoutput1 | Corresponds to "Save disassembled output" 
         N14 | Corresponds to "-" 
         Setsymbolsearchpath1 | Corresponds to "Set symbol searchpath" 
         MenuItem14 | Corresponds to "Use windows debug symbols" 
         MenuItem13 | Corresponds to "-" 
         MenuItem12 | Corresponds to "Apply changes to file" 
         N4 | Corresponds to "-" 
         Savememoryregion1 | Corresponds to "Save memory region" 
         Loadmemolryregion1 | Corresponds to "Load memory region" 
         MenuItem19 | Corresponds to "-" 
         miLoadTrace | Corresponds to "Load trace" 
Search2 | Corresponds to "Search" 
         Findmemory1 | Corresponds to "Find memory" 
         Assemblycode1 | Corresponds to "Find assembly code" 
View1 | Corresponds to "View" 
         miIPTLog | Corresponds to "IPT Log" 
         Stacktrace1 | Corresponds to "Stacktrace" 
         miWatchList | Corresponds to "Watchlist" 
         Breakpointlist1 | Corresponds to "Breakpointlist" 
         Threadlist1 | Corresponds to "Threadlist" 
         Debugstrings1 | Corresponds to "Debug strings" 
         miDebugEvents | Corresponds to "Debug events" 
         miUserWriteInteger | Corresponds to "User write history" 
         N5 | Corresponds to "-" 
         miReferencedFunctions | Corresponds to "Referenced functions" 
         Referencedstrings1 | Corresponds to "Referenced strings" 
         MenuItem10 | Corresponds to "All strings" 
         MemoryRegions1 | Corresponds to "Memory Regions" 
         Heaps1 | Corresponds to "Heaplist" 
         N6 | Corresponds to "-" 
         EnumeratedllsandSymbols1 | Corresponds to "Enumerate DLL's and Symbols" 
         MenuItem18 | Corresponds to "Graphical memory view" 
         N10 | Corresponds to "-" 
         miShowSymbols | Corresponds to "Show symbols" 
         miKernelmodeSymbols | Corresponds to "Kernelmode symbols" 
         miShowSectionAddresses | Corresponds to "Show section addresses" 
         miShowModuleAddresses | Corresponds to "Show module addresses" 
         miUserdefinedSymbols | Corresponds to "Userdefined symbols" 
         Showvaluesofstaticaddresses1 | Corresponds to "Show 'Comment' row" 
         Showdebugtoolbar1 | Corresponds to "Show debug toolbar" 
         Jumplines1 | Corresponds to "Jumplines" 
         miDisassemblerType | Corresponds to "Disassembly output" 
         miArchitecture | Corresponds to "Architecture" 
         miBinUtils | Corresponds to "BinUtils" 
         miCR3Switcher | Corresponds to "CR3 Switcher" 
         miTextPreferences | Corresponds to "Preferences" 
Debug1 | Corresponds to "Debug" 
         miDebugRun | Corresponds to "Run" 
         miRunUnhandled | Corresponds to "Run Unhandled" 
         miDebugStep | Corresponds to "Step Into" 
         miDebugStepOver | Corresponds to "Step Over" 
         miDebugExecuteTillReturn | Corresponds to "Step Out - Execute till return" 
         miDebugRunTill | Corresponds to "Run till..." 
         miDebugSetAddress | Corresponds to "Set Address" 
         miDebugToggleBreakpoint | Corresponds to "Toggle breakpoint" 
         N3 | Corresponds to "-" 
         Continueanddetachdebugger1 | Corresponds to "Continue and  detach debugger" 
         N16 | Corresponds to "-" 
         miDebugBreak | Corresponds to "Break" 
         N19 | Corresponds to "-" 
         miBreakOnExceptions | Corresponds to "Break on unexpected exceptions" 
Extra1 | Corresponds to "Tools" 
         Reservememory1 | Corresponds to "Allocate Memory" 
         Scanforcodecaves1 | Corresponds to "Scan for code caves" 
         FillMemory1 | Corresponds to "Fill Memory" 
         CreateThread1 | Corresponds to "Create Thread" 
         N8 | Corresponds to "-" 
         Dissectcode1 | Corresponds to "Dissect code" 
         miDissectData | Corresponds to "Dissect data/structures old" 
         miDissectData2 | Corresponds to "Dissect data/structures" 
         miCompareStructures | Corresponds to "Compare data/structures" 
         Disectwindow1 | Corresponds to "Dissect window(s)" 
         DissectPEheaders1 | Corresponds to "Dissect PE headers" 
          | Corresponds to "Scan for patches" 
         N12 | Corresponds to "-" 
         Dissectdata1 | Corresponds to "Pointer scan" 
         miPointerSpider | Corresponds to "Structure spider" 
         miUltimap | Corresponds to "Ultimap" 
         miUltimap2 | Corresponds to "Ultimap 2" 
         miCodeFilter | Corresponds to "Code Filter" 
         miWatchMemoryPageAccess | Corresponds to "Watch memory page access" 
         Watchmemoryallocations1 | Corresponds to "Watch memory allocations" 
         Findstaticpointers1 | Corresponds to "Find static addresses" 
         miLuaEngine | Corresponds to "Lua Engine" 
         N11 | Corresponds to "-" 
         InjectDLL1 | Corresponds to "Inject DLL" 
         miGNUAssembler | Corresponds to "GNU Assembler" 
         AutoInject1 | Corresponds to "Auto Assemble" 
Kerneltools1 | Corresponds to "Kernel tools" 
         Allocatenonpagedmemory1 | Corresponds to "Allocate nonpaged memory" 
         Getaddress1 | Corresponds to "Get address" 
         Driverlist1 | Corresponds to "Driver list" 
         Sericedescriptortable1 | Corresponds to "Service Descriptor Table" 
         GDTlist1 | Corresponds to "GDT list" 
         IDTlist1 | Corresponds to "IDT list" 
         miPaging | Corresponds to "Paging" 
--]]


-- To get menu item names used :
--[[
        for i = 0, getMemoryViewForm().MainMenu1.Items.Count - 2 do
            print(getMemoryViewForm().MainMenu1.Items.Item[i].Name..[[ | Corresponds to "]]--..getMemoryViewForm().MainMenu1.Items.Item[i].Caption..[["]])
--[[                for u = 0, getMemoryViewForm().MainMenu1.Items.Item[i].Count - 1 do
                      print("         "..getMemoryViewForm().MainMenu1.Items.Item[i].Item[u].Name..[[ | Corresponds to "]]--..getMemoryViewForm().MainMenu1.Items.Item[i].Item[u].Caption..[["]])
--[[                end
            end
--]]
