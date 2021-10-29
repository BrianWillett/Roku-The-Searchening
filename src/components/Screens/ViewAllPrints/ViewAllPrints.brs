sub init()
    m.list = m.top.findNode("allCardsRowList")
    m.list.observeField("itemSelected","onCardSelected")
    m.itemsPerRow = 3
    m.numRows = invalid
    m.cards = invalid
    m.colNum = m.global.ViewAllLanguageCollectNum
    m.setCode = m.global.ViewAllLanguageSetCode
    m.displayedList = []
    m.originalOrder = invalid
end sub

sub onOpen(params)

    if invalid <> params
        if invalid <> params.data
            errored = false
            try
                ' only populated when coming from languages
                if invalid <> params.data.originalOrder then m.originalOrder = params.data.originalOrder
            catch e
                errored = true
            end try
            if errored and invalid <> params.data[0]
                m.cards = params.data[0]
            else if not errored
                m.cards = params.data.data
            end if
            displayCards(m.cards)
        end if
    end if
end sub


sub displayCards(cards)
    m.displayedList.clear()
    ' get row count
    m.numRows = cards.count() / m.itemsPerRow
    ' if there is a decimal then add another row
    if fix(m.numRows) < m.numRows then m.numRows = fix(m.numRows) + 1
    cardCount = cards.count() - 1
    if cards.count() < m.itemsPerRow
        itemsPerRowCount = cardCount
    else
        itemsPerRowCount = m.itemsPerRow - 1
    end if
    ' create content node that will hold each row
    cardsNode = createObject("roSGNode","ContentNode")
    ' loop to add cards
    for i = 0 to cardCount step 1
        index =  i
        if invalid <> cards[index]
            ' all languages - this should just show the specific set in different languages
            if "ALL" = UCase(m.global.language) and "-1" <> m.colNum
                if m.colNum = cards[index].collector_number.toStr() and UCase(m.setCode) = UCase(cards[index].set)
                    cardNode = cardsNode.createChild("ContentNode")
                    card = cards[index]
                    ' title is the set's name that the card belongs to
                    cardNode.title = card.set_name
                    'description will hold the card name
                    cardNode.description = card.name
                    ' id will hold the card's unique id
                    cardNode.id = card.id
                    ' hdposterurl holds the card image uri
                    if invalid <> card.card_faces and invalid <> card.card_faces[0].image_uris
                        cardNode.HDPosterUrl = card.card_faces[0].image_uris.png
                    else
                        cardNode.HDPosterUrl = card.image_uris.png
                    end if
                    m.displayedList.push(card)
                end if
            else if UCase(m.global.language) =  UCase(cards[index].lang)
                cardNode = cardsNode.createChild("ContentNode")
                card = cards[index]
                ' title is the set's name that the card belongs to
                cardNode.title = card.set_name
                'description will hold the card name
                cardNode.description = card.name
                ' id will hold the card's unique id
                cardNode.id = card.id
                ' hdposterurl holds the card image uri
                if invalid <> card.card_faces and invalid <> card.card_faces[0].image_uris
                    cardNode.HDPosterUrl = card.card_faces[0].image_uris.png
                else
                    cardNode.HDPosterUrl = card.image_uris.png
                end if
                m.displayedList.push(card)
            end if
        else
            exit for
        end if
    end for

    m.list.columnSpacings = getSpacings("col")
    m.list.rowSpacings = getSpacings("row")
    m.list.numRows = m.numRows
    m.list.numColumns = m.itemsPerRow
    m.list.content = cardsNode
    m.list.setFocus(true)
end sub


function getSpacings(which)
    countTo = invalid
    spacingVal = invalid
    theArray = []
    if "col" =  which
        countTo = m.itemsPerRow - 1 ' 0 based
        spacingVal = 100
    else if "row" = which
        countTo = m.numRows - 1 ' 0 based
        spacingVal = 200
    end if
    if invalid <> countTo and invalid <> spacingVal
        for i = 0 to countTo step 1
            theArray.push(spacingVal)
        end for
    end if
    return theArray
end function

sub onCardSelected(event)
    card = m.displayedList[event.getData()]
    m.global.language = card.lang
    ' format the cards list back to what was passed in
    cardsArray = []
    if invalid <> m.originalOrder
        cardsArray.push(m.originalOrder)
    else
        cardsArray.push(m.cards)
    end if
    data = {
        cards: cardsArray[0],
        linkedSet: card.set,
        linkedColNum: card.collector_number
        linkedIdNum: card.id
    }
    m.global.screenManager.callFunc("goToScreen", {type: "CardDisplayScreen", data: data })
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press
        if "back" = key
            m.global.screenManager.callFunc("goBack",{closeCurrent: true})
            handled = true
        end if
    end if
    return handled
end function