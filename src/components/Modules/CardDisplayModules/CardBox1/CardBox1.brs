sub init()
    m.powerTough = m.top.findNode("powerTough")
    m.artist = m.top.findNode("artist")
    m.artLabel = m.top.findNode("art")
    m.bottomBG = m.top.findNode("bottomBG")
    m.legalities = m.top.findNode("legalities")
    m.reservedList = m.top.findNode("reservedList")
    m.rLLabel = m.top.findNode("resList")
    m.oTextLabel = m.top.findNode("oText")
    m.manaSymbols = m.top.findNode("manaSymbols")
    m.id = 0
    m.additional = 0
    m.addedLines = 0
    m.linesDown = 0
    m.characterWidths = m.top.findNode("characterWidths")
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
    for i = 0 to lines.count() - 1 step 1
        words = lines[i].split(" ")
        addToLabel = ""
        addtoNext = false
        if 1 < lines.count() then m.linesDown += 1
        for j = 0 to words.count() - 1 step 1
            if addToLabel.len() + words[j].len() > 62 and not addtoNext
                m.linesDown += 1
                checkForMana(addToLabel)
                m.oTextLabel.text += addToLabel
                m.oTextLabel.text += chr(10)
                m.linesDown += 1
                addToLabel = ""
                addToLabel += words[j] + " "
            else
                addToLabel += words[j] + " "
            end if
            if j = words.count() - 1
                m.linesDown += 1
                checkForMana(addToLabel)
                m.oTextLabel.text += addToLabel
                m.oTextLabel.text += chr(10)
            end if
        end for
    end for
end sub


sub checkForMana(text)
    ?text
    ?m.linesDown
    m.manaSymbols.removeChildrenIndex(m.manaSymbols.getChildCount() - 1,0)
    splitIt = text.split(chr(10))
    '?text
    '?"As long as your devotion to blue is less than five, Thassa isn't a ".len()
    '67
    '640 wide
    '9.552234 per px.
    '?"creature. (Each {U}".len()
    '19
    '17 x 9.552234 = 162.39
    'space to next line 40
    rgx = createObject("roRegex","[{][^{}][}]","")
    for i = 0 to splitIt.count() - 1 step 1
        txt = rgx.MatchAll(splitIt[i])
        if txt.count() > 0
            if txt.count() > 1
                 '?splitIt[i].inStr("{G")
                 'addMana("{G}",90,-2)
            else
                test = txt[0]
                x = getXCoord(splitIt[i].inStr("{"),text)
                y = getYCoord((i + 1),splitIt[i].len(),splitIt[i].inStr("{"))
                mana = ""
                for j = 0 to txt.count() - 1 step 1
                    symb = txt[j]
                    mana += symb[0]
                end for
                if "" <> mana then addMana(mana,x,y)
            end if
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
    if length <> 0 then x = calculateXCoord((length),text)
    'x = x * 9.1 'thassa
    'x = x * 10.1 'thassa's oracle
    'x = 10 * 9 'llanowar's green symbol
    'x = 4 * 8.12 'thassa's blue symbol below
    'x = x * 9.55 'blue symbol over the 'c' in 'costs' in thassa
    return x
end function

function getYCoord(linesDown,lineLen,positionInLine)
    y = (m.linesDown - 1.7) * 23.18'14.16
    ' if y > 1
    '     'if positionInLine <> 0 then y += fix(m.additional)
    ' end if
    ' '?"AddedLinesSpace:  ";(m.addedLines * 10)
    ' chSpaces = (linesDown + m.addedLines) * 15
    ' y = (y * 30) + chSpaces

    return y
end function

function xPositionInLine(length)
    x = length
    if length >= 67
        x = length - 67
        if x >= 67
            x = xPositionInLine(x)
        end if
    end if
    return x
end function