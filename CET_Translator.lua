local function urlEncode(str)
    if str then
        str = str:gsub("\n", "\r\n")
        str = str:gsub("([^%w _%%%-%.~])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = str:gsub(" ", "+")
    end
    return str
end


local mainForm = createForm()
mainForm.setSize(500, 500)
mainForm.setCaption("Translate Cheat Table")

mainForm.Function = {

    function(text)
        if text then
            text = text:gsub("\n", "\r\n")
            text = text:gsub("([^%w _%%%-%.~])", function(c)
                return string.format("%%%02X", string.byte(c))
            end)
            text = text:gsub(" ", "+")
        end
        return text
    end,


    function(response)
        local startPos, endPos = response:find('%[%["')
        if ((not startPos) and response:find('%["') == nil) then
            return nil
        else
            startPos, endPos = response:find('%["')
        end

        local closePos = response:find('"', endPos + 1)
        if not closePos then
            return nil
        end

        return response:sub(endPos + 1, closePos - 1)
    end,

    function(longText)
        local lines = {}
        for line in longText:gmatch("[^\n]+") do
            table.insert(lines, line)
        end
        return lines
    end
}


local serviceSelect = createComboBox(mainForm)
serviceSelect.setPosition(25, 100)
serviceSelect.setWidth(400)
serviceSelect.Text = "Google Translate 5"
serviceSelect.Items.add("Google Translate 5")
serviceSelect.ReadOnly = true
mainForm.SrvSelecta = serviceSelect


local fromLangSelect = createComboBox(mainForm)
fromLangSelect.setPosition(25, 185)
fromLangSelect.setWidth(400)
fromLangSelect.Text = "auto"
for _, lang in ipairs({
    "auto","lt","en","de","fr","ja","zh-TW","zh-CN","ko","ru","th","uk"
}) do
    fromLangSelect.Items.add(lang)
end
fromLangSelect.ReadOnly = true
mainForm.FromSelecta = fromLangSelect


local toLangSelect = createComboBox(mainForm)
toLangSelect.setPosition(25, 275)
toLangSelect.setWidth(400)
toLangSelect.Text = "lt"
for _, lang in ipairs({
    "lt","en","de","fr","ja","zh-TW","zh-CN","ko","ru","th","uk"
}) do
    toLangSelect.Items.add(lang)
end
toLangSelect.ReadOnly = true
mainForm.ToSelecta = toLangSelect


local translateButton = createButton(mainForm)
translateButton.setHeight(50)
translateButton.setWidth(200)
translateButton.setCaption("Try Translate")
translateButton.setPosition(25, 400)
mainForm.RunSrv = translateButton

translateButton.onClick = function()
    local descriptionList = createStringlist()
    for i = 0, AddressList.Count - 1 do
        descriptionList.add(AddressList.getMemoryRecord(i).Description)
    end

    local encodedText = mainForm.Function[1](descriptionList.Text)

    local internet = getInternet()
    local serviceURL = "https://clients5.google.com/translate_a/t?client=dict-chrome-ex"
    local sourceLang = mainForm.FromSelecta.Text
    local targetLang = mainForm.ToSelecta.Text

    local requestURL =
        serviceURL ..
        "&sl=" .. sourceLang ..
        "&tl=" .. targetLang ..
        "&q=" .. encodedText

    local response = internet.getURL(requestURL)
    local translatedText = mainForm.Function[2](response)

    local outputList = createStringlist()
    outputList.add(translatedText:gsub("\\r\\r\\n", "\n"))

    createTimer(5000, function()
        mainForm.show()
        mainForm.TASKRUNNING = false
    end)

    local translatedLines = mainForm.Function[3](outputList.Text)

    for i = 0, AddressList.Count - 1 do
        AddressList.getMemoryRecord(i).Description = translatedLines[i + 1]
    end

    beep()
    mainForm.hide()
    mainForm.TASKRUNNING = true
end


local manualButton = createButton(mainForm)
manualButton.setHeight(50)
manualButton.setWidth(200)
manualButton.setCaption("Manually")
manualButton.setPosition(225, 400)
mainForm.ManAtSrv = manualButton

manualButton.onClick = function()
    if not TTForm then
        TTForm = createForm()
        TTForm.setCaption("Description Editor")
        TTForm.setSize(500, 500)
        TTForm.onClose = function()
            TTForm.hide()
        end

        local editorMemo = createMemo(TTForm)
        editorMemo.setSize(500, 400)
        editorMemo.ScrollBars = 3
        editorMemo.WordWrap = false
        editorMemo.ReadOnly = false
        TTMemo = editorMemo

        local getTextButton = createButton(TTForm)
        getTextButton.setWidth(200)
        getTextButton.setHeight(50)
        getTextButton.setPosition(25, 400)
        getTextButton.setCaption("Get Text")
        getTextButton.onclick = function()
            local list = createStringlist()
            for i = 0, AddressList.Count - 1 do
                list.add(AddressList.getMemoryRecord(i).Description)
            end
            editorMemo.Lines.Text = list.Text
            list.destroy()
        end

        local setTextButton = createButton(TTForm)
        setTextButton.setWidth(200)
        setTextButton.setHeight(50)
        setTextButton.setPosition(225, 400)
        setTextButton.setCaption("Set Text")
        setTextButton.onclick = function()
            for i = 0, AddressList.Count - 1 do
                AddressList.getMemoryRecord(i).Description = editorMemo.Lines[i]
            end
        end

        local pasteButton = createButton(TTForm)
        pasteButton.setWidth(200)
        pasteButton.setHeight(50)
        pasteButton.setPosition(25, 450)
        pasteButton.setCaption("Paste")
        pasteButton.OnClick = function()
            editorMemo.Lines.Text = readFromClipboard()
        end

        local tweakButton = createButton(TTForm)
        tweakButton.setWidth(200)
        tweakButton.setHeight(50)
        tweakButton.setPosition(225, 450)
        tweakButton.setCaption("Tweak Text")
        tweakButton.OnClick = function()
            editorMemo.WordWrap = true
            editorMemo.WordWrap = false
        end
    else
        TTForm.show()
    end
end
