sub init()
    m.langGroup = m.top.findNode("languages")
    m.index = m.global.index
    m.focusColor = m.global.focusColor
    m.unfocusColor = m.global.unfocusColor
    m.highlightColor = m.global.highlightColor
    m.savedList = []
    m.formatted = []
end sub

sub populateLangs()
    allLangs = m.top.langs
    countTo = allLangs.count() - 1
    appendContinuation = true
    if countTo <= 0 then appendContinuation = false
    if countTo > 9
        countTo = 9
    end if
    m.langGroup.removeChildrenIndex(m.langGroup.getChildCount(),0)
    for i = 0 to countTo step 1
        langButton = createObject("roSGNode","LanguageButton")
        langButton.langText = UCase(allLangs[i].id)
        langButton.url = allLangs[i].url
        langButton.id = UCase(allLangs[i].id)
        if langButton.langText = "ZHS"
            langButton.schVis = true
            langButton.langText = ""
        end if
        if UCase(m.global.language) = UCase(langButton.id)
                langButton.postColor = m.focusColor
                m.top.isInFocus = langButton
                m.top.lastHighlighted = langButton
        end if
        m.langGroup.appendChild(langButton)
    end for
    if appendContinuation
        langButton = createObject("roSGNode","LanguageButton")
        langButton.langText = "..."
        langButton.id = "viewAllLangPrints"
        m.langGroup.appendChild(langButton)
    end if
    if invalid = m.top.isInFocus then m.top.isInFocus = m.langGroup.getChild(0)
    m.top.isInFocus.postColor = m.focusColor
end sub

sub saveList()
    m.savedList.push(m.top.savedList[0])
end sub

sub sortByLanguage(list)
    sorted = []
    listCopy = []
    listCopy = copyArrayByValue(list)
    listCopy.sortBy("lang","i")
    m.originalOrder = list
    for i = 0 to list.count() - 1 step 1
        sorted.push(list[i])
        if UCase(list[i].lang) = "EN"
            sorted.unshift(sorted[i])
            sorted.delete(i + 1) 'because unshift copies instead of replacing...
        end if
    end for
    m.formatted.push(sorted)
end sub

sub changeFocus(delta)
    goingOff = false
    if 0 = m.index and -1 = delta then goingOff = true
    m.index += delta
    if m.index < 0
        m.index = 0
    else if m.index > 10
        m.index = 10
    end if
    children = m.langGroup.getChildren(-1,0)
    for i = 0 to children.count() - 1 step 1
        if m.index = i and children[i].id <> m.top.isInFocus.id
            'change color
            children[i].postColor = m.highlightColor
            'set global for highlighting purposes
            m.global.langLastHighlighted = children[i]
            m.top.lastHighlighted = children[m.index]
        else
            'set focus
            children[i].setFocus(true)
            'change other colors
            if children[i].id <> m.top.isInFocus.id
                children[i].postColor = m.unfocusColor
            else
                children[i].postColor = m.focusColor
                m.top.lastHighlighted = children[m.index]
            end if
        end if
    end for
    m.global.index = m.index
    if goingOff
        m.top.lastHighlighted = children[m.index]
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press
        if "right" = key
            changeFocus(1)
            handled = true
        else if "left" = key
            if m.index = 0
                changeFocus(-1)
                handled = false
            else
                changeFocus(-1)
                handled = true
            end if
        else if "OK" = key
            children = m.langGroup.getChildren(-1,0)
            prevFocus = m.top.isInFocus.id
            for i = 0 to children.count() - 1 step 1
                if m.index = i
                    'set this to focused
                    m.top.isInFocus = children[i]
                    'change the focused color
                    children[i].postColor = m.focusColor
                else
                    children[i].postColor = m.unfocusColor
                end if
            end for
            if prevFocus <> m.top.isInFocus.id and "viewAllLangPrints" <> m.top.isInFocus.id
                prevScreen = m.global.screenManager.callFunc("fetchCurrentScreen")
                colNum = invalid
                displayedSet =  invalid
                setCo = invalid
                if invalid <> prevScreen.collectorNum and invalid <> prevScreen.displayedSet
                    colNum = prevScreen.collectorNum
                    displayedSet =  prevScreen.displayedSet
                    setCo = removeParenthesis(prevScreen.setAbbrev)
                end if
                m.global.screenManager.callFunc("goToScreen",{type: "CardDisplayScreen", data: {lang: m.top.isInFocus.id, colNum: colNum, displayedSet: displayedSet, url: m.top.isInFocus.url, cards: m.savedList}})
            else if "viewAllLangPrints" = m.top.isInFocus.id
                m.global.language = "ALL"
                sortByLanguage(m.top.savedList[0])
                m.global.screenManager.callFunc("goToScreen", {type: "ViewAllPrints", data: { data: m.formatted[0], originalOrder: m.originalOrder}})
            end if
            handled = true
        else if "down" = key
            'pass up to card display screen to go to price area
            handled = false
        else if "up" = key
            'pass up to card display screen to go to set area
            hanlded = false
        end if
    end if
    return handled
end function