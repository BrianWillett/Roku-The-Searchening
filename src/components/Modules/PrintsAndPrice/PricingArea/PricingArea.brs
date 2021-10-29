sub init()
    m.rowGroup = m.top.findNode("alternatePrints")
    m.ViewAllRow = m.top.findNode("ViewAllPrints")
    m.ViewAllLabel = m.top.findNode("ViewAll")
    m.bottomBar = m.top.findNode("bottomBar")
    m.focusColor = m.global.rarityCircleFocusColor
    m.unfocusColor = m.global.rarityCircleUnfocusColor
    m.rarityCircle = invalid
    m.index = 0
    m.viewAll = false
    m.inFocus = invalid
    m.top.observeField("focusedChild", "onFocusChanged")
    m.startPos = 0
    m.endPos = 0
    m.boxWidth = 650
    m.toDisplay = []
end sub

sub addPrintRows()
    m.rowGroup.removeChildrenIndex(m.rowGroup.getChildCount(),0)
    lineLen = 0
    visiblePrints = invalid
    handleLanguage()
    if 10 < m.toDisplay.count()
        visiblePrints = getVisibleCardRange()
    else
        visiblePrints = m.toDisplay
    end if
    transY = 60
    transX = 0
    setLabelX = 10
    transYInc = 0
    applyToEnd = false
    prevSetName = invalid
    if 10 <= visiblePrints.Count()
        countTo = 9
    else
        countTo = (visiblePrints.Count() - 1)
    end if
    shouldFocus = 0
    for i = 0 to countTo step 1
        newPrint = createObject("roSGNode","PricingRow")
        if m.top.displayedSet = visiblePrints[i].set_name
            wCol = m.top.displayedSet + " #" + m.top.collectorNum
            checkCol = visiblePrints[i].set_name + " #" + visiblePrints[i].collector_number
            if wCol = checkCol then newPrint.dBlend = "#ededed"
            shouldFocus = i
        end if

        if 0 <= visiblePrints[i].set_name.inStr("Duel Decks Anthology")
            split = visiblePrints[i].set_name.split(":")
            reducedName = "DDA:" + split[1]
            newPrint.id = visiblePrints[i].set_name
            newPrint.lText = reducedName
        else
            if shouldShowColNum(visiblePrints, i, prevSetName, countTo)
                textWithColNum = visiblePrints[i].set_name + " #" + visiblePrints[i].collector_number
                newPrint.id = textWithColNum
                newPrint.lText = textWithColNum
                lineLen = textWithColNum.len()
            else
                newPrint.id = visiblePrints[i].set_name
                newPrint.lText = visiblePrints[i].set_name
                lineLen = visiblePrints[i].set_name.len()
            end if
        end if
        newPrint.idNum = visiblePrints[i].id
        if 27 <= lineLen
            'the set name can be 27 char long before the row needs to be adjusted
            newPrint.dHeight = 75
            newPrint.dWidth = m.boxWidth
            transYInc = 15
            newPrint.lSpace = -5
        else
            newPrint.dHeight = 60
            newPrint.dWidth = m.boxWidth
            transYInc = 0
            newPrint.lSpace = -5
        end if
        if invalid <> visiblePrints[i].prices.usd then newPrint.usdPrice ="$" + visiblePrints[i].prices.usd
        if invalid <> visiblePrints[i].prices.eur then newPrint.eurPrice = "€" + visiblePrints[i].prices.eur
        if invalid <> visiblePrints[i].prices.tix then newPrint.tix = visiblePrints[i].prices.tix
        if (visiblePrints[i].promo or "masterpiece" = visiblePrints[i].set_type) and invalid <> visiblePrints[i].prices.usd_foil and invalid = visiblePrints[i].prices.usd
            newPrint.usdPrice = "$" + visiblePrints[i].prices.usd_foil
            newPrint.asteriskVis = true
        else if invalid <> visiblePrints[i].prices.usd_foil and invalid = visiblePrints[i].prices.usd
            newPrint.usdPrice = "$" + visiblePrints[i].prices.usd_foil
            newPrint.asteriskVis = true
        else
            newPrint.asteriskVis = false
        end if
        newPrint.setCo = visiblePrints[i].set
        newPrint.collectNum = visiblePrints[i].collector_number
        newPrint.dTrans = [transX,transY]
        newPrint.rarity = visiblePrints[i].rarity
        newPrint.lTrans = [setLabelX,(transY + 15)]
        transY += 60 + transYInc
        m.rowGroup.appendChild(newPrint)
        prevSetName = visiblePrints[i].set
    end for
    'm.rowGroup.getChild(shouldFocus).setFocus(true)
    m.ViewAllRow.translation = [transX, transY]
    m.ViewAllLabel.translation = [setLabelX,(transY + 15)]
    m.bottomBar.translation = [(transX - 1),(transY + 60)]
end sub

sub handleLanguage()
    alternates = m.top.alternates[0]
    m.toDisplay.clear()
    for each alternate in alternates
        if UCase(m.top.langDisplay) = UCase(alternate.lang)
            m.toDisplay.push(alternate)
        end if
    end for
end sub

function shouldShowColNum(visiblePrints, currIndex, prevSetName, countTo)
    include = false
    currSet = visiblePrints[currIndex].set
    if (invalid <> prevSetName and prevSetName = visiblePrints[currIndex].set)
        include = true
    else
        for i = currIndex to countTo step 1
             if (invalid <> visiblePrints[i + 1] and currSet = visiblePrints[i + 1].set) then include = true
             if include then exit for
        end for
    end if
    return include
end function

sub onFocusChanged(event)
    focused = event.getData()
    if "alternatePrints" = focused.id
        updateInFocus(focused.focusedChild)
        m.index = getInitialIndex()
        updateFocus()
    end if
    m.top.unobserveField("focusedChild")
end sub

function getInitialIndex()
    index = invalid
    for i = 0 to (m.rowGroup.count() - 1) step 1
        if m.inFocus.id = m.rowGroup.getChild(i).id
            index = i
            exit for
        end if
    end for
    return index
end function

sub updateFocus()
    if not m.viewAll
        m.ViewAllRow.blendColor = m.unfocusColor
        children = m.inFocus.getChildren(-1,0)
        for i = 0 to (children.count() - 1) step 1
            if "rarityCircle" = children[i].id
                m.rarityCircle = children[i]
                exit for
            else
                m.rarityCircle = invalid
            end if
        end for
        if invalid <> m.rarityCircle then m.rarityCircle.blendColor = m.focusColor
    else
        updateInFocus(m.ViewAllRow)
        m.ViewAllRow.blendColor = m.focusColor
    end if
end sub

sub changeFocus(delta)
    range = m.rowGroup.getChildCount()
    m.index += delta
    if 0 > m.index
        m.index = 0
    else if range <= m.index
        m.viewAll = true
    else
        m.viewAll = false
    end if
    if invalid <> m.rarityCircle then m.rarityCircle.blendColor = m.unfocusColor 'clear previous focus indicator
    if not m.viewAll
        updateInFocus(m.rowGroup.getChild(m.index))
        m.inFocus.setFocus(true)
    else
        updateInFocus(m.ViewAllRow)
        m.ViewAllRow.setFocus(true)
    end if
    updateFocus()
end sub

sub updateInFocus(node)
    m.inFocus = node
    m.top.isInFocus = node
end sub

function getVisibleCardRange()
    ' assign full card array
    cards = m.toDisplay
    cardsCount = cards.count() - 1
    ' get the specific card information
    specSet = m.top.displayedSet
    specColNum = m.top.collectorNum
    ' array to be returned
    rangedArray = []
    if invalid <> specSet and "" <> specSet and invalid <> specColNum and "" <> specColNum
        'find the spec card's index position
        index = 0
        for i = 0 to cardsCount step 1
            if specSet = cards[i].set_name and specColNum = cards[i].collector_number
                index = i
                exit for
            end if
        end for
        ' find the start and end position for display, the specified card should be in the middle if able
        if invalid <> cards[index - 4]
            m.startPos = index - 4 ' so the specified card will be 5th from the top of the list
        else
            m.startPos = 0
        end if
        ' find end position
        if cardsCount >= (m.startPos + 9)
            m.endPos = m.startPos + 9 ' set the end to 10 from the start
        else
            ' otherwise get a count of the total cards left
            m.endPos = m.startPos - 1 'as to include the start position in the count
            for i = m.startPos to cardsCount step 1
                m.endPos += 1
            end for
        end if
        if m.endPos > m.startPos and invalid <> cards[m.endPos - 9] then m.startPos = m.endPos - 9
        ' return the specified range
        for i = m.startPos to m.endPos step 1
            rangedArray.push(cards[i])
        end for
    end if
    return rangedArray
end function

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press
        if "up" = key
            if m.index = 0
                m.rarityCircle.blendColor = "#FFFFFFFF"
                handled = false
            else
                changeFocus(-1)
                handled = true
            end if
        else if "down" = key
            changeFocus(1)
            handled = true
        else if "OK" = key
            if m.viewAll
                m.global.screenManager.callFunc("goToScreen", {type: "ViewAllPrints", data: m.top.alternates })
            else
                data = {
                    cards: m.top.alternates[0],
                    linkedSet: m.inFocus.setCo,
                    linkedColNum: m.inFocus.collectNum
                    linkedIdNum: m.inFocus.idNum
                }
                m.global.screenManager.callFunc("goToScreen", {type: "CardDisplayScreen", data: data, closeCurrent: true })
            end if
            handled = true
        else if "left" = key
            m.rarityCircle.blendColor = "#FFFFFFFF"
            handled = false
        end if
    end if
    return handled
end function