
local function url_encode(str)
    if str then
        str = str:gsub("\n", "\r\n")
        str = str:gsub("([^%w _%%%-%.~])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = str:gsub(" ", "+")
    end
    return str
end

TForm = createForm()
TForm.setSize(500, 500)
TForm.setCaption("Translate Cheat Table")

TForm.Function = {function(str)
    if str then
        str = str:gsub("\n", "\r\n")
        str = str:gsub("([^%w _%%%-%.~])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = str:gsub(" ", "+")
    end
    return str
end, function(q)
    local SP, EP = q:find('%[%["')
    if ((not start_pos) and q:find('%["') == nil) then
        return nil
    else
        SP, EP = q:find('%["')
    end

    local CP = q:find('"', EP + 1)
    if not CP then
        return nil
    end

    return q:sub(EP + 1, CP - 1)
end, function(extralongstring)
    local lines = {}
    for line in extralongstring:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    return lines
end}

TForm.SrvSelecta = createComboBox(TForm)
TForm.SrvSelecta.setPosition(25, 100)
TForm.SrvSelecta.setWidth(400)
TForm.SrvSelecta.Text = [[Google Translate 5]]
TForm.SrvSelecta.Items.add("Google Translate 5")
TForm.SrvSelecta.ReadOnly = true

TForm.FromSelecta = createComboBox(TForm)
TForm.FromSelecta.setPosition(25, 185)
TForm.FromSelecta.setWidth(400)
TForm.FromSelecta.Text = [[auto]]
TForm.FromSelecta.Items.add("auto")
TForm.FromSelecta.Items.add("lt")
TForm.FromSelecta.Items.add("en")
TForm.FromSelecta.Items.add("de")
TForm.FromSelecta.Items.add("fr")
TForm.FromSelecta.Items.add("ja")
TForm.FromSelecta.Items.add("zh-TW")
TForm.FromSelecta.Items.add("zh-CN")
TForm.FromSelecta.Items.add("ko")
TForm.FromSelecta.Items.add("ru")
TForm.FromSelecta.Items.add("th")
TForm.FromSelecta.Items.add("uk")
TForm.FromSelecta.ReadOnly = true

TForm.ToSelecta = createComboBox(TForm)
TForm.ToSelecta.setPosition(25, 275)
TForm.ToSelecta.setWidth(400)
TForm.ToSelecta.Text = [[lt]]
TForm.ToSelecta.Items.add("lt")
TForm.ToSelecta.Items.add("en")
TForm.ToSelecta.Items.add("de")
TForm.ToSelecta.Items.add("fr")
TForm.ToSelecta.Items.add("ja")
TForm.ToSelecta.Items.add("zh-TW")
TForm.ToSelecta.Items.add("zh-CN")
TForm.ToSelecta.Items.add("ko")
TForm.ToSelecta.Items.add("ru")
TForm.ToSelecta.Items.add("th")
TForm.ToSelecta.Items.add("uk")
TForm.ToSelecta.ReadOnly = true

TForm.RunSrv = createButton(TForm)
TForm.RunSrv.setHeight(50)
TForm.RunSrv.setWidth(200)
TForm.RunSrv.setCaption("Try Translate")
TForm.RunSrv.setPosition(25, 400)

TForm.RunSrv.onClick = function()

    local csl = createStringlist()
    for p = 0, AddressList.Count - 1 do
        csl.add(AddressList.getMemoryRecord(p).Description)
    end

    local FI = TForm.Function[1](csl.Text)

    local TEST = getInternet()
    local SERVICE_URL = [[https://clients5.google.com/translate_a/t?client=dict-chrome-ex]]
    local TRANSLATE_FROM_PREFIX = [[&sl=]]
    local TRANSLATE_FROM = TForm.FromSelecta.Text
    local TRANSLATE_TO_PREFIX = [[&tl=]]
    local TRANSLATE_TO = TForm.ToSelecta.Text
    local USER_QUERY_PREFIX = [[&q=]]
    local URL = SERVICE_URL .. TRANSLATE_FROM_PREFIX .. TRANSLATE_FROM .. TRANSLATE_TO_PREFIX .. TRANSLATE_TO ..
                    USER_QUERY_PREFIX .. FI
    local SO = TEST.getURL(URL)
    local G5 = TForm.Function[2](SO)
    local cslout = createStringlist()
    cslout.add(G5:gsub("\\r\\r\\n", "\n"))
    createTimer(5000, function()
        TForm.show();
        TForm.TASKRUNNING = false
    end)

    local flex = TForm.Function[3](cslout.Text)

    for p = 0, AddressList.Count - 1 do
        AddressList.getMemoryRecord(p).Description = flex[p + 1]
    end
    beep()

    TForm.hide()
    TForm.TASKRUNNING = true
end

TForm.ManAtSrv = createButton(TForm)
TForm.ManAtSrv.setHeight(50)
TForm.ManAtSrv.setWidth(200)
TForm.ManAtSrv.setCaption("Manually")
TForm.ManAtSrv.setPosition(225, 400)
TForm.ManAtSrv.onClick = function()


    if not TTForm then
        TTForm = createForm()
        TTForm.onClose = function()
            TTForm.hide()
        end
        TTForm.setCaption("Description Editor")
        TTForm.setSize(500, 500)

        TTMemo = createMemo(TTForm)
        TTMemo.setSize(500, 400)
        TTMemo.ScrollBars = 3
        TTMemo.WordWrap = false
        TTMemo.ReadOnly = false
        TTGetText = createButton(TTForm)
        TTGetText.setWidth(200)
        TTGetText.setHeight(50)
        TTGetText.setPosition(25, 400)
        TTGetText.setCaption("Get Text")
        TTGetText.onclick = function()
            local csl = createStringlist()
            for p = 0, AddressList.Count - 1 do
                csl.add(AddressList.getMemoryRecord(p).Description)
            end
            TTMemo.Lines.Text = csl.Text
            csl.destroy()
        end

        TTSetText = createButton(TTForm)
        TTSetText.setWidth(200)
        TTSetText.setHeight(50)
        TTSetText.setPosition(225, 400)
        TTSetText.setCaption("Set Text")
        TTSetText.onclick = function()
            for p = 0, AddressList.Count - 1 do
                AddressList.getMemoryRecord(p).Description = TTMemo.Lines[p]
            end
        end
        TTPasText = createButton(TTForm)
        TTPasText.setWidth(200)
        TTPasText.setHeight(50)
        TTPasText.setPosition(25, 450)
        TTPasText.setCaption("Paste")
        TTPasText.OnClick = function()
            TTMemo.Lines.Text = readFromClipboard()
        end

        TTPasTText = createButton(TTForm)
        TTPasTText.setWidth(200)
        TTPasTText.setHeight(50)
        TTPasTText.setPosition(225, 450)
        TTPasTText.setCaption("Tweak Text")
        TTPasTText.OnClick = function()
            TTMemo.WordWrap = true
            TTMemo.WordWrap = false
        end

    else
        TTForm.Show()
    end
end
