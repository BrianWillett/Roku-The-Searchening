sub init()
    m.button = m.top.findNode("flip")
    m.button.observeFieldScoped("buttonSelected","flipCard")
    m.frontToback = m.top.findNode("fr")
    m.frontToback2 = m.top.findNode("bk")
    m.backToFront = m.top.findNode("fr2")
    m.backToFront2 = m.top.findNode("bk2")
    m.dfrontToback = m.top.findNode("d1")
    m.dfrontToback2 = m.top.findNode("d2")
    m.dbackToFront = m.top.findNode("d3")
    m.dbackToFront2 = m.top.findNode("d4")
    m.languageArea = m.top.findNode("languages")
    m.setArea = m.top.findNode("setInfo")
    m.priceArea = m.top.findNode("pricingArea")
    m.lastArea = invalid
    m.side = 0
    m.savedSet = invalid
    m.alts = []
    m.altLangs = []
    m.initialOrder = []
    m.language = m.global.language
    m.focusColor = m.global.focusColor
    m.unfocusColor = m.global.unfocusColor
    m.highlightColor = m.global.highlightColor
    m.collectorNum = invalid
    m.displayedSet = invalid
end sub

sub onOpen(params)
    m.top.frontVis = false
    m.top.backVis = false
    if invalid <> params and invalid <> params.data
        if invalid <> params.data.cards and invalid <> params.data.linkedSet and invalid <> params.data.linkedColNum
            cardCount = params.data.cards.count()
            cardArray = {
                data: params.data.cards,
                total_cards: cardCount
            }
            if invalid <> params.data.fullSet then m.savedSet = params.data.fullSet
            m.language = m.global.language
            if invalid <> params.data.linkedIdNum
                displayCard(cardArray, params.data.linkedSet, params.data.linkedColNum, params.data.linkedIdNum)
            else
                displayCard(cardArray, params.data.linkedSet, params.data.linkedColNum)
            end if
        else if invalid <> params.data.lang
            m.language = UCase(params.data.lang)
            if invalid <> params.data.colNum and invalid <> params.data.displayedSet
                m.collectorNum = params.data.colNum
                m.displayedSet = params.data.displayedSet
            end if
            cardArray = {
                data: params.data.cards[0],
                total_cards: params.data.cards[0].count()
            }
            m.global.language = m.language
            displayCard(cardArray)
        else
            displayCard(params.data)
        end if
    end if
end sub

sub displayCard(card, linkedSet = invalid, linkedColNum = invalid, linkedIdNum = invalid)
    cardsReturned = 0
    if invalid <> card.total_cards then cardsReturned = card.total_cards
    if 0 <= cardsReturned
        m.dispCard = 0
        cards = []
        cards.clear()
        if m.global.newCard
            m.global.newCard = false
            cards = sortOrder(card, cardsReturned)
            m.global.initialOrder = copyArrayByValue(cards)
        else
            cards = m.global.initialOrder
        end if
        for i = 0 to (cardsReturned - 1) step 1
            if UCase(m.language) = UCase(cards[i].lang)
                if invalid = linkedSet and invalid = linkedColNum
                    if  not cards[i].promo and not cards[i].digital and "box" <> cards[i].set_type and "from_the_vault" <> cards[i].set_type and "mb1" <> cards[i].set
                        m.dispCard = i
                        m.global.ViewAllLanguageCollectNum = cards[i].collector_number.toStr()
                        m.global.ViewAllLanguageSetCode = cards[i].set
                        exit for
                    end if
                else
                    if invalid <> linkedIdNum
                        if cards[i].set = linkedSet and cards[i].collector_number = linkedColNum and cards[i].id = linkedIdNum
                            m.top.backUri = ""
                            m.top.cBox2Vis = false
                            m.dispCard = i
                            m.global.ViewAllLanguageCollectNum = cards[i].collector_number.toStr()
                            m.global.ViewAllLanguageSetCode = cards[i].set
                            exit for
                        end if
                    else
                        if cards[i].set = linkedSet and cards[i].collector_number = linkedColNum
                            m.top.backUri = ""
                            m.top.cBox2Vis = false
                            m.dispCard = i
                            m.global.ViewAllLanguageCollectNum = cards[i].collector_number.toStr()
                            m.global.ViewAllLanguageSetCode = cards[i].set
                            exit for
                        end if
                    end if
                end if
            end if
        end for
        handleLanguages(cards, cards[m.dispCard].collector_number, cards[m.dispCard].set)
        if invalid <> cards[m.dispCard].card_faces
            m.top.frontUri = cards[m.dispCard].card_faces[0].image_uris.png
            m.top.backUri = cards[m.dispCard].card_faces[1].image_uris.png
            ' Front Side of Card
            m.top.cName = cards[m.dispCard].card_faces[0].name
            if invalid <> cards[m.dispCard].card_faces[0].mana_cost
                m.top.isFor = "nameplate"
                m.top.cMana = cards[m.dispCard].card_faces[0].mana_cost
            end if
            m.top.cType = cards[m.dispCard].card_faces[0].type_line
            if invalid <> cards[m.dispCard].card_faces[0].power and invalid <> cards[m.dispCard].card_faces[0].toughness
                m.top.cPT = cards[m.dispCard].card_faces[0].power + "/" + cards[m.dispCard].card_faces[0].toughness
            else
                m.top.pTVis = false
            end if
            if invalid <> cards[m.dispCard].card_faces[0].reserved and cards[m.dispCard].card_faces[0].reserved
                m.top.isRL = true
            else
                m.top.isRL = false
            end if
            m.top.cArt = "Illustrated by " + cards[m.dispCard].card_faces[0].artist
            if invalid <> cards[m.dispCard].card_faces[0].flavor_text then m.top.cFText = cards[m.dispCard].flavor_text
            m.top.cText = formatOracleText(cards[m.dispCard].card_faces[0].oracle_text)
            m.top.formats = cards[m.dispCard].legalities
            ' Back Side of Card
            m.top.cName2 = cards[m.dispCard].card_faces[1].name
            if invalid <> cards[m.dispCard].card_faces[1].mana_cost
                m.top.isFor2 = "nameplate"
                m.top.cMana2 = cards[m.dispCard].card_faces[1].mana_cost
            end if
            m.top.cType2 = cards[m.dispCard].card_faces[1].type_line
            if invalid <> cards[m.dispCard].card_faces[1].power and invalid <> cards[m.dispCard].card_faces[1].toughness
                m.top.cPT2 = cards[m.dispCard].card_faces[1].power + "/" + cards[m.dispCard].card_faces[1].toughness
            else
                m.top.pTVis2 = false
            end if
            if invalid <> cards[m.dispCard].card_faces[1].reserved and cards[m.dispCard].card_faces[1].reserved
                m.top.isRL2 = true
            else
                m.top.isRL2 = false
            end if
            m.top.cArt2 = "Illustrated by " + cards[m.dispCard].card_faces[1].artist
            if invalid <> cards[m.dispCard].card_faces[1].flavor_text then m.top.cFText2 = cards[m.dispCard].flavor_text
            m.top.cText2 = formatOracleText(cards[m.dispCard].card_faces[1].oracle_text)
            m.top.formats2 = cards[m.dispCard].legalities
            ' Flip Button
            m.button.visible = true
            m.button.setFocus(true)
        else
            m.top.cBox2Vis = false
            m.button.visible =  false
            m.top.frontUri = cards[m.dispCard].image_uris.png
            if invalid <> cards[m.dispCard].mana_cost
                m.top.isFor = "nameplate"
                m.top.cMana = cards[m.dispCard].mana_cost
            end if
            m.top.cName = cards[m.dispCard].name
            m.top.cType = cards[m.dispCard].type_line
            if invalid <> cards[m.dispCard].power and invalid <> cards[m.dispCard].toughness
                m.top.cPT = cards[m.dispCard].power + "/" + cards[m.dispCard].toughness
                m.top.pTVis = true
            else
                m.top.pTVis = false
            end if
            if invalid <> cards[m.dispCard].reserved and cards[m.dispCard].reserved
                m.top.isRL = true
            else
                m.top.isRL = false
            end if
            m.top.cArt = "Illustrated by " + cards[m.dispCard].artist
            if invalid <> cards[m.dispCard].flavor_text then m.top.cFText = cards[m.dispCard].flavor_text
            m.top.cText = formatOracleText(cards[m.dispCard].oracle_text)
            m.top.formats = cards[m.dispCard].legalities
        end if
        m.alts.clear()
        test = copyArrayByValue(cards)
        m.alts.push(test)
        m.top.langDisplay = m.language
        m.top.setImg = getSetSymbolUri(cards[m.dispCard].set)
        m.top.setAbbrev = "(" + UCase(cards[m.dispCard].set) + ")"
        m.top.setColNumLine = "#" + cards[m.dispCard].collector_number + " · " + titleCase(cards[m.dispCard].rarity)  +  " · " + getLanguage(cards[m.dispCard].lang)
        m.top.mtgSet = cards[m.dispCard].set_name
        if invalid = m.collectorNum
            m.top.collectorNum = cards[m.dispCard].collector_number
        else
            m.top.collectorNum = m.collectorNum
        end if
        if invalid = m.displayedSet
            m.top.displayedSet = cards[m.dispCard].set_name
        else
            m.top.displayedSet = m.displayedSet
        end if
        m.top.alternates = m.alts
        m.top.frontVis = true
        if invalid <> m.collectorNum and invalid <> m.displayedSet 'why isn't the m.dispCard working? Maybe because of the saved sort instead of resorting?
            extraTitle = m.displayedSet + " #" + m.collectorNum
        else
            extraTitle = cards[m.dispCard].set_name + " #" + cards[m.dispCard].collector_number
        end if
        focusOn = m.top.findNode(extraTitle)
        ' end if
        if invalid = focusOn then focusOn = m.top.findNode(cards[m.dispCard].set_name)
        if invalid <> focusOn then focusOn.setFocus(true)
    end if
end sub

function getSetSymbolUri(set)
    if "mb1" = set or "plist" = set
        set = "planeswalker"
    else if "prm" = set
        set = "mtgo"
    else if "pdom" = set
        set = "dom"
    else if "pana" = set
        set = "mtga"
    else if 0 = set.inStr("ha")
        set = "ha1"
    else if 0 = set.inStr("pj")
        set = "archie"
    else if "pg07" = set
        set = "dci"
    else if 4 = set.Len() and 0 = set.inStr("p")
        set = set.Right(3)
    else if "fbb" = set
        set = "3ed"
    else if "4bb" = set
        set = "4ed"
    else if "fnm" = set
        set = "default"
    else if "sum" = set
        set = "psum"
    else if "evg" = set
        set = "dd1"
    else if "tsb" = set
        set = "tsr"
    else if "ovnt" = set
        set = "pmei"
    else if 4 = set.Len() and "wc" = set.Left(2)
        set = "default"
    else if "gk1" = set or "gk2" = set
        set = "grn"
    end if
    return "pkg:/assets/images/symbols/Sets/" + set + "_1.png"
end function

function titleCase(word)
    length = word.Len()
    first = Left(word, 1)
    rest = Right(word,(length -1))

    return UCase(first) + rest
end function

function getLanguage(abrv)
    if "EN" = UCase(abrv)
        return "English"
    else if "ES" = UCase(abrv)
        return "Spanish"
    else if "FR" = UCase(abrv)
        return "French"
    else if "DE" = UCase(abrv)
        return "German"
    else if "IT" = UCase(abrv)
        return "Italian"
    else if "PT" = UCase(abrv)
        return "Portuguese"
    else if "JA" = UCase(abrv)
        return "Japanese"
    else if "KO" = UCase(abrv)
        return "Korean"
    else if "RU" = UCase(abrv)
        return "Russian"
    else if "ZHS" = UCase(abrv)
        return "Simplified Chinese"
    else if "ZHT" = UCase(abrv)
        return "Traditional Chinese"
    else if "HE" = UCase(abrv)
        return "Hebrew"
    else if "LA" = UCase(abrv)
        return "Latin"
    else if "GRC" = UCase(abrv)
        return "Ancient Greek"
    else if "SA" = UCase(abrv)
        return "Sanskrit"
    else if "PH" = UCase(abrv)
        return "Phyrexian"
    else
        return "Not Found: '" + set + "'"
    end if
end function

sub languageSort()
    langs = []
    for i = 0 to m.altLangs.count() - 1 step 1
        langs.push(m.altLangs[i])
    end for
    m.altLangs.clear()
    fetchLang(langs,"EN")
    fetchLang(langs,"ES")
    fetchLang(langs,"FR")
    fetchLang(langs,"DE")
    fetchLang(langs,"IT")
    fetchLang(langs,"PT")
    fetchLang(langs,"JA")
    fetchLang(langs,"KO")
    fetchLang(langs,"RU")
    fetchLang(langs,"ZHS")
    fetchLang(langs,"ZHT")
    fetchLang(langs,"HE")
    fetchLang(langs,"LA")
    fetchLang(langs,"GRC")
    fetchLang(langs,"SA")
    fetchLang(langs,"PH")
    m.top.langs = m.altLangs
end sub

sub fetchLang(langs, lang)
    for i = 0 to langs.Count() - 1 step 1
        if lang = UCase(langs[i].id)
            m.altLangs.push({id: UCase(langs[i].id), url: langs[i].url})
            exit for
        end if
    end for
end sub

sub handleLanguages(cards, dispColNum, dispSet)
    prevLang = invalid
    langCount = cards.count() - 1
    m.altLangs.clear()
    for i = 0 to langCount step 1
        if cards[i].collector_number = dispColNum and cards[i].set = dispSet
            if invalid <> prevLang
                if prevLang <> cards[i].lang
                    m.altLangs.push({id: cards[i].lang, url: cards[i].uri})
                    prevLang = cards[i].lang
                end if
            else
                m.altLangs.push({id: cards[i].lang, url: cards[i].uri})
                prevLang = cards[i].lang
            end if
        end if
    end for
    languageSort()
end sub

sub flipCard()
    if 0 = m.side 'front
        m.frontToback.control = "start"
        m.frontToback2.control = "start"
        m.dfrontToback.control = "start"
        m.dfrontToback2.control = "start"
        m.side = 1
    else if 1 = m.side 'back
        m.backToFront.control = "start"
        m.backToFront2.control = "start"
        m.dbackToFront.control = "start"
        m.dbackToFront2.control = "start"
        m.side = 0
    end if
end sub

function formatOracleText(oracle)
 split = oracle.split(chr(10))
 size = split.count()
 cntr = 0
 formatted = ""
 while cntr < size
    formatted += split[cntr]
    check = cntr + 1
    if check < size then formatted += chr(10)
    cntr ++
 end while

 return formatted
end function

function sortOrder(scryfallSorted, cardsReturned)
    sortedToMatchScryfall = []
    if 0 < cardsReturned and invalid <> scryfallSorted
        cards = scryfallSorted.data
        newSort = []
        sameSetSort = []
        countTo = cardsReturned - 1
        prevSet = invalid
        for i = 0 to countTo step 1
            if 0 < i
                if prevSet = cards[i].set
                    if (Val(cards[i-1].collector_number) < Val(cards[i].collector_number)) or (cards[i-1].collector_number.len() < cards[i].collector_number.len())
                        sameSetSort.push(cards[i])
                    else
                        ssCount = sameSetSort.count() - 1
                        cardCopy = sameSetSort[ssCount]
                        if invalid <> cardCopy
                            'to swap positions with a higher collector num already in the set array
                            sameSetSort.delete(ssCount)
                            sameSetSort.push(cards[i])
                            sameSetSort.push(cardCopy)
                        end if
                    end if
                else
                    if 0 < sameSetSort.Count()
                        ' last minute sort to order collect numbers containing letters in the correct alphabetical order
                        sameSetSort.SortBy("collector_number")
                        for j = 0 to (sameSetSort.Count() - 1) step 1
                            newSort.push(sameSetSort[j])
                        end for
                        prevSet = cards[i].set
                        sameSetSort = []
                        sameSetSort.push(cards[i])
                    end if
                end if
            else
                prevSet = cards[i].set
                sameSetSort.push(cards[i])
            end if
            prevCard = cards[i]
        end for
        for j = 0 to (sameSetSort.Count() - 1) step 1
            newSort.push(sameSetSort[j])
        end for
        sameSetSort = []
        for i = 0 to countTo step 1
            sortedToMatchScryfall.push(newSort[i])
        end for
    else
        sortedToMatchScryfall.push(scryfallSorted)
    end if
    return sortedToMatchScryfall
end function

sub goToPriceArea()
    if invalid <> m.priceArea and invalid <> m.priceArea.isInFocus
        m.priceArea.isInFocus.setFocus(true)
        children = m.priceArea.isInFocus.getChildren(-1,0)
        for i = 0 to (children.count() - 1) step 1
            if "rarityCircle" = children[i].id
                rarityCircle = children[i]
                rarityCircle.blendColor = m.global.rarityCircleFocusColor
                exit for
            end if
        end for
    end if
end sub

sub goToLangArea(entering = false)
    m.languageArea.isInFocus.setFocus(true)
    m.languageArea.savedList = m.alts
    m.languageArea.isInFocus.postColor = m.focusColor
    layGroup = m.languageArea.getChildren(-1,0)
    children = layGroup[0].getChildren(-1,0)
    for i = 0 to children.count() - 1 step 1
        if invalid <> m.languageArea.isInFocus and invalid <> m.languageArea.isInFocus.id
            if m.languageArea.isInFocus.id <> children[i].id then children[i].postColor = m.unfocusColor
        end if
        if entering and invalid <> m.global.langLastHighlighted and invalid <> m.global.langLastHighlighted.id and "" <> m.global.langLastHighlighted.id
            if invalid <> m.languageArea.isInFocus and invalid <> m.languageArea.isInFocus.id
                if m.global.langLastHighlighted.id = children[i].id and children[i].id <> m.languageArea.isInFocus.id then children[i].postColor = m.highlightColor
            end if
        end if
    end for
end sub

sub goToSetArea()
    m.setArea.setFocus(true)
    m.setArea.bgColor = m.highlightColor
end sub

sub goToLastArea()
    if invalid <> m.lastArea
        if m.setArea.id = m.lastArea
            goToSetArea()
        else if m.languageArea.id = m.lastArea
            goToLangArea(true)
        else if m.priceArea.id = m.lastArea
            goToPriceArea()
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press
        if "left" = key
            if m.button.visible
                if m.setArea.isInfocusChain()
                    m.setArea.bgColor = m.unfocusColor
                    m.lastArea = m.setArea.id
                else if m.languageArea.isInfocusChain()
                    goToLangArea() ' to clear highlights
                    m.lastArea = m.languageArea.id
                else if m.priceArea.isInfocusChain()
                    m.lastArea = m.priceArea.id
                end if
                'now focus the button
                m.button.setFocus(true)
                m.top.cBox2Vis = true
                m.top.backVis = true
            end if
            handled = true
        else if "right" = key
            if m.button.hasFocus()
                goToLastArea()
                handled = false
            else
                handled = true
            end if
        else if "up" = key
            if m.priceArea.isInfocusChain()
                goToLangArea(true)
                handled = false
            else if m.languageArea.isInfocusChain()
                goToLangArea() 'to clear highlight color
                goToSetArea()
                handled = false
            else
                handled = true
            end if
        else if "down" = key
            if m.setArea.isInfocusChain()
                m.setArea.bgColor = m.unfocusColor
                goToLangArea(true)
                handled = false
            else if m.languageArea.isInfocusChain()
                goToLangArea() 'to clear highlight color
                goToPriceArea()
                handled = false
            else
                handled = true
            end if

        else if "back" = key
            closeCurr = false
            lastScreen = m.global.screenManager.callFunc("fetchLastScreen")
            if "CardDisplayScreen" = lastScreen.id then closeCurr = true
            ' potential data to be used on a back procedure
            if invalid <> m.savedSet
                m.global.screenManager.callFunc("goBack", {data: m.savedSet, closeCurrent: closeCurr})
            else
                m.global.screenManager.callFunc("goBack", {data: m.top.alternates, closeCurrent: closeCurr})
            end if
            handled = true
        end if
    end if
    return handled
end function