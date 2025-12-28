if not x1327 then
    x1327 = {}

    local menuItem = createMenuItem(MainForm.MainMenu1)
    menuItem.Caption = "Auto Backup Save Folder"

    menuItem.onClick = function()
        if not x1327.AutoSaveFileMaker then
            local backupForm = createForm()
            x1327.AutoSaveFileMaker = backupForm

            backupForm.setCaption("Auto backup save folder")
            backupForm.setSize(600, 400)
            backupForm.onClose = function()
                backupForm.hide()
            end

            -- Game selector
            local gameSelect = createComboBox(backupForm)
            gameSelect.setWidth(400)
            gameSelect.setTop(50)
            backupForm.GameSelect = gameSelect

            local infoLabel = createLabel(backupForm)
            infoLabel.Caption = [[Will look for Save path automatically. If exist in local database.]]
            backupForm.InfoLabel = infoLabel

            -- Save path
            local savePathEdit = createEdit(backupForm)
            savePathEdit.setPosition(0, 100)
            savePathEdit.setWidth(400)
            savePathEdit.ReadOnly = true
            backupForm.SavePathEdit = savePathEdit

            local browseSavePathBtn = createButton(backupForm)
            browseSavePathBtn.setCaption("[[...]]")
            browseSavePathBtn.setPosition(400, 100)
            browseSavePathBtn.setWidth(200)
            browseSavePathBtn.setHeight(32)
            browseSavePathBtn.onClick = function()
                local dirDialog = createSelectDirectoryDialog()
                if dirDialog.Execute() then
                    savePathEdit.Text = dirDialog.FileName
                end
            end
            backupForm.BrowseSavePathBtn = browseSavePathBtn

            -- Output path
            local outputPathEdit = createEdit(backupForm)
            outputPathEdit.setPosition(0, 150)
            outputPathEdit.setWidth(400)
            outputPathEdit.ReadOnly = true
            backupForm.OutputPathEdit = outputPathEdit

            local browseOutputPathBtn = createButton(backupForm)
            browseOutputPathBtn.setCaption("[[...]]")
            browseOutputPathBtn.setPosition(400, 150)
            browseOutputPathBtn.setWidth(200)
            browseOutputPathBtn.setHeight(32)
            browseOutputPathBtn.onClick = function()
                local dirDialog = createSelectDirectoryDialog()
                if dirDialog.Execute() then
                    outputPathEdit.Text = dirDialog.FileName
                end
            end
            backupForm.BrowseOutputPathBtn = browseOutputPathBtn

            local infoLabel2 = createLabel(backupForm)
            infoLabel2.setPosition(25, 365)
            infoLabel2.setCaption("Note that this uses timers --...")
            backupForm.InfoLabel2 = infoLabel2

            -- Enable / Disable routine button
            local toggleRoutineBtn = createButton(backupForm)
            toggleRoutineBtn.setPosition(0, 325)
            toggleRoutineBtn.setWidth(600)
            toggleRoutineBtn.setHeight(32)
            toggleRoutineBtn.setCaption("Run Auto Backup routine -- Currently [DISABLED]")
            backupForm.ToggleRoutineBtn = toggleRoutineBtn

            -- Temp folder name
            local tempFolderEdit = createEdit(backupForm)
            tempFolderEdit.setPosition(0, 200)
            tempFolderEdit.setWidth(400)
            backupForm.TempFolderEdit = tempFolderEdit

            local tempFolderLabel = createLabel(backupForm)
            tempFolderLabel.setPosition(400, 200)
            tempFolderLabel.setCaption("<-- Temp folder name")
            backupForm.TempFolderLabel = tempFolderLabel

            -- Interval
            local intervalEdit = createEdit(backupForm)
            intervalEdit.setPosition(0, 250)
            intervalEdit.setWidth(400)
            intervalEdit.NumbersOnly = true
            intervalEdit.Text = 300000
            backupForm.IntervalEdit = intervalEdit

            local intervalLabel = createLabel(backupForm)
            intervalLabel.setPosition(400, 250)
            intervalLabel.setCaption("<-- How often")
            backupForm.IntervalLabel = intervalLabel

            -- Database
            backupForm.Database = {
                {"The Dark Pictures Anthology: Little Hope", [[%LOCALAPPDATA%\LittleHope\Saved\SaveGames\]], "LittleHope"},
                {"The Dark Pictures Anthology: Man of Medan", [[%LOCALAPPDATA%\ManOfMedan\Saved\SaveGames\]], "ManOfMedan"},
                {"The Dark Pictures Anthology: House of Ashes", [[%LOCALAPPDATA%\HouseOfAshes\Saved\SaveGames\]], "HouseOfAshes"},
                {"The Dark Pictures Anthology: The Devil in Me", [[%LOCALAPPDATA%\TheDevilInMe\Saved\SaveGames\]], "TheDevilInMe"},
                {"Crusader Kings III", [[%USERPROFILE%\Documents\Paradox Interactive\Crusader Kings III\]], "CKIII"},
                {"Kingdom Come: Deliverance", [[%USERPROFILE%\Saved Games\kingdomcome\saves\]], "KingdomCome"},
                {"The Casting of Frank Stone", [[%LOCALAPPDATA%\TheCastingofFrankStone\Saved\SaveGames\]], "TheCastingofFrankStone"},
            }

            for i = 1, #backupForm.Database do
                gameSelect.Items.addText(backupForm.Database[i][1])
            end

            gameSelect.OnChange = function()
                for i = 1, #backupForm.Database do
                    if gameSelect.Text == backupForm.Database[i][1] then
                        savePathEdit.Text = backupForm.Database[i][2]
                        tempFolderEdit.Text = backupForm.Database[i][3]
                        break
                    end
                end
            end

            local nextRunLabel = createLabel(backupForm)
            nextRunLabel.setPosition(25, 295)
            backupForm.NextRunLabel = nextRunLabel

            -- Timer routine
            local backupTimer = createTimer(backupForm)
            backupTimer.Interval = 1000
            backupTimer.Enabled = false
            backupForm.BackupTimer = backupTimer

            backupTimer.OnTimer = function()
                local copyCmd =
                    [[ /c robocopy "]] ..
                    savePathEdit.Text ..
                    [[" "]] ..
                    outputPathEdit.Text .. "\\" .. tempFolderEdit.Text .. [[" /E]]

                local archiveCmd =
                    [[ tar -czvf "]] ..
                    outputPathEdit.Text ..
                    "\\" ..
                    os.time() ..
                    "_B_" ..
                    tostring(process) ..
                    "_" ..
                    tempFolderEdit.Text ..
                    [[.tar.gz" -C "]] ..
                    outputPathEdit.Text ..
                    [[" "]] ..
                    tempFolderEdit.Text .. [["]]

                local cleanupCmd =
                    [[rmdir /s /q "]] ..
                    outputPathEdit.Text ..
                    "\\" ..
                    tempFolderEdit.Text ..
                    [["]]

                local fullCmd = copyCmd .. " & " .. archiveCmd .. " & " .. cleanupCmd
                shellExecute("cmd.exe", fullCmd, nil, false)

                backupTimer.Interval = intervalEdit.Text
                nextRunLabel.setCaption(
                    "Next save will be generated approximately at " ..
                    os.date("%Y-%m-%d %H:%M:%S", os.time() + 300)
                )
            end

            toggleRoutineBtn.OnClick = function()
                if
                    (not backupTimer.Enabled and
                        outputPathEdit.Text ~= "" and
                        savePathEdit.Text ~= "" and
                        tempFolderEdit.Text ~= "")
                then
                    backupTimer.Enabled = true
                    toggleRoutineBtn.setCaption("Run Auto Backup routine -- Currently [ENABLED]")
                    browseOutputPathBtn.Enabled = false
                    browseSavePathBtn.Enabled = false
                    gameSelect.Enabled = false
                    tempFolderEdit.Enabled = false
                else
                    backupTimer.Enabled = false
                    toggleRoutineBtn.setCaption("Run Auto Backup routine -- Currently [DISABLED]")
                    browseOutputPathBtn.Enabled = true
                    browseSavePathBtn.Enabled = true
                    gameSelect.Enabled = true
                    tempFolderEdit.Enabled = true
                    nextRunLabel.setCaption(" ")
                    backupTimer.Interval = 1000
                end
            end

            -- Load config
            local loadConfigBtn = createButton(backupForm)
            loadConfigBtn.setPosition(400, 50)
            loadConfigBtn.setHeight(34)
            loadConfigBtn.setWidth(200)
            loadConfigBtn.setCaption("[[...]]")
            backupForm.LoadConfigBtn = loadConfigBtn

            loadConfigBtn.OnClick = function()
                gameSelect.clear()

                local openDialog = createOpenDialog()
                openDialog.defaultExt = ".LUA"
                openDialog.Filter = [[Lua programing file (*.LUA)|*.lua]]

                local fileContent
                if openDialog.Execute() then
                    local sl = createStringList()
                    sl.add(io.open(openDialog.FileName, "r"):read("*all"))
                    fileContent = sl.Text
                end

                load(fileContent)()

                for i = 1, #backupForm.Database do
                    gameSelect.Items.addText(backupForm.Database[i][1])
                end

                beep()
            end
        else
            x1327.AutoSaveFileMaker.show()
        end
    end

    MainForm.MainMenu1.Items.add(menuItem)
end
