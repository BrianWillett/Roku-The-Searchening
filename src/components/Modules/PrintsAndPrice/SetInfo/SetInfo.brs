sub init()
    m.set = m.top.findNode("set")
    m.abbrev = m.top.findNode("abbrev")
    m.bg = m.top.findNode("setInfoBG")
end sub

sub setText()
    if invalid <> m.top.mtgSet
        length = m.top.mtgSet.Len()
        adjustBy = 0
        if 34 < length
            split = m.top.mtgSet.split(" ")
            endSpl = split.Count() - 1
            splLen = split[endSpl].len()
            secondLineLen = length - 34
            if secondLineLen < splLen
                adjustBy = splLen
            else
                adjustBy = secondLineLen
            end if
            trans = m.top.setAbbrevTrans
            adjusted = [(trans[0] + (adjustBy * 16)), trans[1]]
            m.top.setAbbrevTrans = adjusted
        end if
        m.set.text = m.top.mtgSet
    end if
end sub

sub handleFocusColor()
    m.bg.blendColor = "#00000000"
    m.bg.blendColor = m.top.bgColor
end sub

sub fetchSet()
   setCode = removeParenthesis(m.abbrev.text)
    setsTask = createObject("roSGNode","SetsTask")
    setsTask.params = {
        searchingFor: setCode,
        requestType: "specificSet"
    }
    setsTask.unObserveField("response")
    setsTask.observeField("response","onDataReceived")
    setsTask.control = "run"
end sub

sub onDataReceived(event)
    response = event.getData()
    if invalid <> response
        m.global.screenManager.callFunc("goToScreen",{type: "ViewSet", data: response})
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press
        if "down" = key
            handled = false
        else if "left" = key
            handled = false
        else if "OK" = key
            fetchSet()
            handled = true
        end if
    end if
    return handled
end function