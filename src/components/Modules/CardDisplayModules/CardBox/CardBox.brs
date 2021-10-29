sub init()
    m.powerTough = m.top.findNode("powerTough")
    m.powerToughLabel = m.top.findNode("pT")
    m.artist = m.top.findNode("artist")
    m.artLabel = m.top.findNode("art")
    m.bottomBG = m.top.findNode("bottomBG")
    m.legalities = m.top.findNode("legalities")
    m.reservedList = m.top.findNode("reservedList")
    m.rLLabel = m.top.findNode("resList")
    m.oTextLabel = m.top.findNode("oText")
    m.manaSymbols = m.top.findNode("manaSymbols")
    m.oTextGroup = m.top.findNode("oText")
    m.cardText = m.top.findNode("cardText")
    m.id = 0
    m.additional = 0
    m.addedLines = 0
    m.linesDown = 0
    m.parasDown = 0
    m.characterWidths = m.top.findNode("characterWidths")
    m.transX = 0
    m.transY = 0
    m.latoLight = "pkg:/assets/fonts/Lato-Light.ttf"
    m.latoItalic = "pkg:/assets/fonts/Lato-Italic.ttf"
end sub

sub hidePT(event)
    if "1" = m.top.pTVis and "0" = m.top.isRL
        m.reservedList.visible = false
        m.rLLabel.visible = false
        m.powerTough.visible = true
        m.artist.translation = "[580,597]"
        m.artLabel.translation =" [615,617]"
        m.bottomBG.translation = "[581,677]"
        m.legalities.translation = "[580,672]"
    else if "1" = m.top.pTVis and "1" = m.top.isRL
        m.reservedList.visible = true
        m.rLLabel.visible = true
        m.powerTough.visible = true
        m.artist.translation = "[580,597]"
        m.artLabel.translation =" [615,617]"
        m.reservedList.translation = "[580,672]"
        m.rLLabel.translation = "[615,691]"
        m.bottomBG.translation = "[581,752]"
        m.legalities.translation = "[580,747]"
    else if "1" = m.top.isRL
        m.reservedList.visible = true
        m.rLLabel.visible = true
        m.powerTough.visible = false
        m.artist.translation = "[580,522]"
        m.artLabel.translation =" [615,542]"
        m.reservedList.translation = "[580,597]"
        m.rLLabel.translation = "[615,617]"
        m.bottomBG.translation = "[581,677]"
        m.legalities.translation = "[580,672]"
    else if "0" = m.top.pTVis
        m.reservedList.visible = false
        m.rLLabel.visible = false
        m.powerTough.visible = false
        m.artist.translation = "[580,522]"
        m.artLabel.translation =" [615,542]"
        m.bottomBG.translation = "[581,602]"
        m.legalities.translation = "[580,597]"
    else
        m.reservedList.visible = false
        m.rLLabel.visible = false
        m.powerTough.visible = true
        m.artist.translation = "[580,597]"
        m.artLabel.translation =" [615,617]"
        m.bottomBG.translation = "[581,677]"
        m.legalities.translation = "[580,672]"
    end if
end sub

sub handleOracleText()
    oText = m.top.cText
    lines = oText.split(chr(10))
    m.linesDown = 0
    m.parasDown = 0
    m.transX = 0
    m.transY = 10
    m.oTextGroup.removeChildrenIndex(m.oTextGroup.getChildCount() - 1, 0)
    m.manaSymbols.removeChildrenIndex(m.manaSymbols.getChildCount() - 1,0)
    for i = 0 to lines.count() - 1 step 1
        words = lines[i].split(" ")
        addToLabel = ""
        m.parasDown += 1
        if 0 <> i then m.transY += 25
        if 1 < lines.count() then m.linesDown += 1
        for j = 0 to words.count() - 1 step 1
            if addToLabel.len() + words[j].len() >= 62
                m.linesDown += 1
                checkForMana(addToLabel)
                addToGroup(addToLabel,m.transX,m.transY,m.latoLight)
                m.linesDown += 1
                addToLabel = ""
                addToLabel += words[j] + " "
            else
                addToLabel += words[j] + " "
            end if
            if j = words.count() - 1
                m.linesDown += 1
                checkForMana(addToLabel)
                addToGroup(addToLabel,m.transX,m.transY,m.latoLight)
            end if
        end for
    end for
    if invalid = m.top.cFText or "" = m.top.cFText
        adjustTextBox(m.transY)
    else
        handleFlavorText()
    end if
end sub

sub handleFlavorText()
    m.transY += 10
    fText = m.top.cFText
    lines = fText.split(chr(10))
    for i = 0 to lines.count() - 1 step 1
        words = lines[i].split(" ")
        addToLabel = ""
        if 0 <> i then m.transY += 10 'slim the spacing between paragraphs
        for j = 0 to words.count() - 1 step 1
            if addToLabel.len() + words[j].len() >= 62
                addToGroup(addToLabel,m.transX,m.transY,m.latoItalic)
                addToLabel = ""
                addToLabel += words[j] + " "
            else
                addToLabel += words[j] + " "
            end if
            if j = words.count() - 1
                addToGroup(addToLabel,m.transX,m.transY,m.latoItalic)
            end if
        end for
    end for
    adjustTextBox(m.transY)
end sub

sub addToGroup(text,x,y,font)
    line = CreateObject("roSGNode","OTextLabel")
    line.theFont = font
    line.theText = replaceManaWithSpaces(text)
    line.theTranslation = [x,y]
    line.id = m.linesDown.toStr()
    m.oTextGroup.appendChild(line)
    m.transY += 35
end sub

sub checkForMana(text)
    splitIt = text.split(chr(10))
    rgx = createObject("roRegex","[{](?<=\{)(.*?)(?=\})[}]","")
    for i = 0 to splitIt.count() - 1 step 1
        txt = rgx.MatchAll(splitIt[i])
        prevPos = 0
        mana = ""
        printIt = true
        if txt.count() > 0
            for j = 0 to txt.count() - 1 step 1
                if 1 < txt.count()
                    symb = txt[j]
                    position = text.inStr(symb[0])
                    if position - prevPos <= 3
                        mana += symb[0]
                        printIt = false
                    else
                        length = splitIt[i].inStr(mana)
                        shortened = Left(text, length)
                        x = getXCoord(length,shortened)
                        y = m.transY
                        if j = txt.count() - 1 and 3 < (position - prevPos)
                            addMana(mana,x,y)
                            mana = symb[0]
                        end if
                        printIt = true
                    end if
                    prevPos = position
                    if j = txt.count() - 1
                        length = splitIt[i].inStr(mana)
                        shortened = Left(text, length)
                        x = getXCoord(length,shortened)
                        if 3 <= txt.count() then x += 10
                        y = m.transY
                        addMana(mana,x,y)
                        printIt = false
                    end if
                else
                    symb = txt[j]
                    mana = symb[0]
                end if
                length = splitIt[i].inStr(mana)
                shortened = Left(text, length)
                x = getXCoord(length,shortened)
                'if j >= 1 then x += (32 * j)
                y = m.transY

                if "" <> mana and printIt
                    addMana(mana,x,y)
                    mana = ""
                    mana += symb[0]
                end if
            end for

            'end if
            lineLen = splitIt[i].len() / 67
            actualLines = fix(lineLen)
            if lineLen - fix(lineLen) > 0 then actualLines += 1
            m.addedLines += (actualLines - 1)
            m.additional += m.addedLines
        end if
    end for
end sub

sub addMana(text,x,y)
    symbol = createObject("roSGNode", "ManaCost")
    symbol.isFor = "text"
    symbol.mana = text
    symbol.translation = "[" + x.toStr() + "," + y.toStr() + "]"
    m.manaSymbols.appendChild(symbol)
end sub

function getXCoord(length, text)
    x = 0
    if length <> 0 then x = calculateXCoord(length,text) + 3 ' to center in the added spaces
    return x
end function

sub adjustTextBox(height)
    if height < (m.linesDown * 23.5) and m.parasDown > 1 then height = m.linesDown * 23.5
   height = (height - m.cardText.dHeight)
    m.cardText.dHeight += height
    if m.powerTough.visible
        m.powerTough.translation = [580,522 + height]
        m.powerToughLabel.translation = [615,540 + height]
        m.artist.translation = [580,597 + height]
        m.artLabel.translation = [615,617 + height]
        if m.reservedList.visible
            m.bottomBG.translation = [581,752 + height]
            m.legalities.translation = [580,747 + height]
            m.rLLabel.translation = [615,691 + height]
            m.reservedList.translation = [580,672 + height]
        else
            m.bottomBG.translation = [581,677 + height]
            m.legalities.translation = [580,672 + height]
        end if
    else
        m.powerTough.translation = [580,522 + height]
        m.powerToughLabel.translation = [615,540 + height]
        m.artist.translation = [580,522 + height]
        m.artLabel.translation = [615,542 + height]
        if m.reservedList.visible
            m.bottomBG.translation = [581,677 + height]
            m.legalities.translation = [580,672 + height]
            m.rLLabel.translation = [615,617 + height]
            m.reservedList.translation = [580,597 + height]
        else
            m.bottomBG.translation = [581,602 + height]
            m.legalities.translation = [580,597 + height]
        end if
    end if
end sub
