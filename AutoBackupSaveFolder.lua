if not x1327 then
    x1327 = {}
    local mi = createMenuItem(MainForm.MainMenu1)
    mi.Caption = "Auto Backup Save Folder"
    mi.onClick = function()
        if (not x1327.AutoSaveFileMaker) then
            x1327.AutoSaveFileMaker = createForm()
            x1327.AutoSaveFileMaker.setCaption("Auto backup save folder")
            x1327.AutoSaveFileMaker.setSize(600, 400)
            -- x1327.AutoSaveFileMaker.setBorderStyle(2)
            x1327.AutoSaveFileMaker.onClose = function()
                x1327.AutoSaveFileMaker.hide()
            end

            x1327.AutoSaveFileMaker.OCB = createComboBox(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.OCB.setWidth(400)
            x1327.AutoSaveFileMaker.OCB.setTop(50)

            x1327.AutoSaveFileMaker.Info = createLabel(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.Info.Caption =
                [[Will look for Save path automatically. If exist in local database.]]

            x1327.AutoSaveFileMaker.SavePath = createEdit(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.SavePath.setPosition(0, 100)
            x1327.AutoSaveFileMaker.SavePath.setWidth(400)
            x1327.AutoSaveFileMaker.SavePath.ReadOnly = true

            x1327.AutoSaveFileMaker.LocalPathBTN = createButton(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.LocalPathBTN.setCaption("[[...]]")
            x1327.AutoSaveFileMaker.LocalPathBTN.setPosition(400, 100)
            x1327.AutoSaveFileMaker.LocalPathBTN.setWidth(200)
            x1327.AutoSaveFileMaker.LocalPathBTN.setHeight(32)
            x1327.AutoSaveFileMaker.LocalPathBTN.onClick = function()
                local LDII = createSelectDirectoryDialog()
                if LDII.Execute() then
                    x1327.AutoSaveFileMaker.SavePath.Text = LDII.FileName
                end
            end

            x1327.AutoSaveFileMaker.OutputPath = createEdit(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.OutputPath.setPosition(0, 150)
            x1327.AutoSaveFileMaker.OutputPath.setWidth(400)
            x1327.AutoSaveFileMaker.OutputPath.ReadOnly = true

            x1327.AutoSaveFileMaker.LocalOutPathBTN = createButton(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.LocalOutPathBTN.setCaption("[[...]]")
            x1327.AutoSaveFileMaker.LocalOutPathBTN.setPosition(400, 150)
            x1327.AutoSaveFileMaker.LocalOutPathBTN.setWidth(200)
            x1327.AutoSaveFileMaker.LocalOutPathBTN.setHeight(32)
            x1327.AutoSaveFileMaker.LocalOutPathBTN.onClick = function()
                local LDII = createSelectDirectoryDialog()
                if LDII.Execute() then
                    x1327.AutoSaveFileMaker.OutputPath.Text = LDII.FileName
                end
            end

            x1327.AutoSaveFileMaker.Info2 = createLabel(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.Info2.setPosition(25, 365)
            x1327.AutoSaveFileMaker.Info2.setCaption("Note that this uses timers --...")

            x1327.AutoSaveFileMaker.RunSaveLoop = createButton(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.RunSaveLoop.setPosition(0, 325)
            x1327.AutoSaveFileMaker.RunSaveLoop.setWidth(600)
            x1327.AutoSaveFileMaker.RunSaveLoop.setHeight(32)
            x1327.AutoSaveFileMaker.RunSaveLoop.setCaption("Run Auto Backup routine -- Currently [DISABLED]")
            x1327.AutoSaveFileMaker.RunSaveLoop.OnClick = function()
                if
                    (not x1327.AutoSaveFileMaker.Routine.Enabled and x1327.AutoSaveFileMaker.OutputPath.Text ~= "" and
                        x1327.AutoSaveFileMaker.SavePath.Text ~= "" and
                        x1327.AutoSaveFileMaker.Templess.Text ~= "")
                 then
                    x1327.AutoSaveFileMaker.Routine.Enabled = true
                    x1327.AutoSaveFileMaker.RunSaveLoop.setCaption("Run Auto Backup routine -- Currently [ENABLED]")
                    x1327.AutoSaveFileMaker.LocalOutPathBTN.Enabled = false
                    x1327.AutoSaveFileMaker.LocalPathBTN.Enabled = false
                    x1327.AutoSaveFileMaker.OCB.Enabled = false
                    x1327.AutoSaveFileMaker.Templess.Enabled = false
                else
                    x1327.AutoSaveFileMaker.Routine.Enabled = false
                    x1327.AutoSaveFileMaker.RunSaveLoop.setCaption("Run Auto Backup routine -- Currently [DISABLED]")
                    x1327.AutoSaveFileMaker.LocalOutPathBTN.Enabled = true
                    x1327.AutoSaveFileMaker.LocalPathBTN.Enabled = true
                    x1327.AutoSaveFileMaker.OCB.Enabled = true
                    x1327.AutoSaveFileMaker.Templess.Enabled = true
                    x1327.AutoSaveFileMaker.NextSeq.setCaption(" ")
                    x1327.AutoSaveFileMaker.Routine.Interval = 1000 -- reset
                end
            end

            x1327.AutoSaveFileMaker.Templess = createEdit(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.Templess.setPosition(0, 200)
            x1327.AutoSaveFileMaker.Templess.setWidth(400)

            x1327.AutoSaveFileMaker.info3 = createLabel(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.info3.setPosition(400, 200)
            x1327.AutoSaveFileMaker.info3.setCaption("<-- Temp folder name")

            x1327.AutoSaveFileMaker.Oftenless = createEdit(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.Oftenless.setPosition(0, 250)
            x1327.AutoSaveFileMaker.Oftenless.setWidth(400)
            x1327.AutoSaveFileMaker.Oftenless.NumbersOnly = true
            x1327.AutoSaveFileMaker.Oftenless.Text = 300000 -- 5 Min (1000 = 1 sec or 60000 = 1min)

            x1327.AutoSaveFileMaker.label5 = createLabel(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.label5.setPosition(400, 250)
            x1327.AutoSaveFileMaker.label5.setCaption("<-- How often")

            x1327.AutoSaveFileMaker.Database = { -- {"Application title","SAVE PATH LOCATION","TempFolderName"}
        -- note you can use os.getenv("LOCALAPPDATA") instead of %LOCALAPPDATA% -- anyway it is still sent to cmd line
        {"The Dark Pictures Anthology: Little Hope", [[%LOCALAPPDATA%\LittleHope\Saved\SaveGames\]], "LittleHope"},
        {"The Dark Pictures Anthology: Man of Medan", [[%LOCALAPPDATA%\ManOfMedan\Saved\SaveGames\]], "ManOfMedan"},
        {"The Dark Pictures Anthology: House of Ashes", [[%LOCALAPPDATA%\HouseOfAshes\Saved\SaveGames\]], "HouseOfAshes"},
        {"The Dark Pictures Anthology: The Devil in Me", [[%LOCALAPPDATA%\TheDevilInMe\Saved\SaveGames\]],"TheDevilInMe"},
        {"Crusader Kings III", [[%USERPROFILE%\Documents\Paradox Interactive\Crusader Kings III\]], "CKIII"},
        {"Kingdom Come: Deliverance", [[%USERPROFILE%\Saved Games\kingdomcome\saves\]], "KingdomCome"},
        {"The Casting of Frank Stone", [[%LOCALAPPDATA%\TheCastingofFrankStone\Saved\SaveGames\]], "TheCastingofFrankStone"},
        }

            -- process info from LOCAL database
            for i = 1, #x1327.AutoSaveFileMaker.Database do
                x1327.AutoSaveFileMaker.OCB.Items.addText(x1327.AutoSaveFileMaker.Database[i][1])
            end

            x1327.AutoSaveFileMaker.OCB.OnChange = function()
                -- read database table -- on request
                for i = 1, #x1327.AutoSaveFileMaker.Database do
                    if x1327.AutoSaveFileMaker.OCB.Text == x1327.AutoSaveFileMaker.Database[i][1] then
                        x1327.AutoSaveFileMaker.SavePath.Text = x1327.AutoSaveFileMaker.Database[i][2]
                        x1327.AutoSaveFileMaker.Templess.Text = x1327.AutoSaveFileMaker.Database[i][3]
                        break
                    end
                end
            end

            x1327.AutoSaveFileMaker.NextSeq = createLabel(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.NextSeq.setPosition(25, 295)

            -- create backup routine
            x1327.AutoSaveFileMaker.Routine = createTimer(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.Routine.Interval = 1000
            x1327.AutoSaveFileMaker.Routine.Enabled = false
            x1327.AutoSaveFileMaker.Routine.OnTimer = function()
                x1327.AutoSaveFileMaker.Moveless =
                    [[ /c robocopy "]] ..
                    x1327.AutoSaveFileMaker.SavePath.Text ..
                        ' " "' ..
                            x1327.AutoSaveFileMaker.OutputPath.Text ..
                                "\\" .. x1327.AutoSaveFileMaker.Templess.Text .. ' " /E'
                x1327.AutoSaveFileMaker.Loveless =
                    [[ tar -czvf ]] ..
                    '"' ..
                        x1327.AutoSaveFileMaker.OutputPath.Text ..
                            "\\" ..
                                os.time() ..
                                    "_B_" ..
                                        tostring(process) ..
                                            "_" ..
                                                tostring(x1327.AutoSaveFileMaker.Templess.Text) ..
                                                    "_" ..
                                                        [[.tar.gz" -C "]] ..
                                                            x1327.AutoSaveFileMaker.OutputPath.Text ..
                                                                '" "' ..
                                                                    x1327.AutoSaveFileMaker.Templess.Text .. '"' .. "" -- This will be sent to compress
                x1327.AutoSaveFileMaker.Removeless =
                    [[rmdir /s /q ]] ..
                    [["]] ..
                        x1327.AutoSaveFileMaker.OutputPath.Text .. "\\" .. x1327.AutoSaveFileMaker.Templess.Text .. '"' -- remove temp folder
                x1327.AutoSaveFileMaker.Lineless =
                    x1327.AutoSaveFileMaker.Moveless ..
                    " & " .. x1327.AutoSaveFileMaker.Loveless .. " & " .. x1327.AutoSaveFileMaker.Removeless
                shellExecute("cmd.exe", x1327.AutoSaveFileMaker.Lineless, nil, false)
                x1327.AutoSaveFileMaker.Routine.Interval = x1327.AutoSaveFileMaker.Oftenless.Text
                x1327.AutoSaveFileMaker.NextSeq.setCaption(
                    "Next save will be generated approximately at " .. os.date("%Y-%m-%d %H:%M:%S", os.time() + 300)
                )
            end

            x1327.AutoSaveFileMaker.LoadCFG = createButton(x1327.AutoSaveFileMaker)
            x1327.AutoSaveFileMaker.LoadCFG.setPosition(400, 50)
            x1327.AutoSaveFileMaker.LoadCFG.setHeight(34)
            x1327.AutoSaveFileMaker.LoadCFG.setWidth(200)
            x1327.AutoSaveFileMaker.LoadCFG.setCaption("[[...]]")
            x1327.AutoSaveFileMaker.LoadCFG.OnClick = function()
                x1327.AutoSaveFileMaker.OCB.clear()
                local LDII = createOpenDialog()
                LDII.defaultExt = ".LUA"
                LDII.Filter = [[Lua programing file (*.LUA)|*.lua]]
                local LDI
                if LDII.Execute() then
                    LDI = createStringList()
                    LDI.add(io.open(LDII.FileName, "r"):read("*all"))
                end
                load(LDI.Text)()

                for i = 1, #x1327.AutoSaveFileMaker.Database do
                    x1327.AutoSaveFileMaker.OCB.Items.addText(x1327.AutoSaveFileMaker.Database[i][1])
                end

                return beep()
            end
        else
            x1327.AutoSaveFileMaker.show()
        end
    end
    MainForm.MainMenu1.Items.add(mi)
end
