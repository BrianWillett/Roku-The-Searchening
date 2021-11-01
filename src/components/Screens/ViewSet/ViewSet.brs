sub init()
    m.list = m.top.findNode("allCardsRowList")
    m.list.observeField("itemSelected","onCardSelected")
    m.itemsPerRow = 4
    m.numRows = invalid
    m.cards = invalid
    m.set = invalid
    m.colNum = invalid
end sub

sub onOpen(params)
    if invalid <> params and invalid <> params.data
        if invalid = params.data.data
            m.cards = params.data[0]
        else
            m.cards = params.data.data
        end if
        displayCards(m.cards)
    end if
end sub

sub displayCards(cards)
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
        spacingVal = 70
    end if
    if invalid <> countTo and invalid <> spacingVal
        for i = 0 to countTo step 1
            theArray.push(spacingVal)
        end for
    end if
    return theArray
end function

sub onCardSelected(event)
    card = m.cards[event.getData()]
    m.set = card.set
    m.colNum = card.collector_number
    search = createObject("roSGNode","CardsTask")
    search.params = {
        requestType: "cardSearch",
        searchingFor: card.oracle_id
    }
    search.unobserveField("response")
    search.observeField("response","onResultReceived")
    search.control = "run"
    ' format the cards list back to what was passed in
end sub

sub onResultReceived(event)
    response = event.getData()
    if invalid <> response and invalid <> response.data
        'Bug #3 - Selecting from Set List:
        'set this value to true so that the cardlist updates instead of assuming its another set version of the currently displayed card
        m.global.newCard = true
        ' format the cards list back to what was passed in
        data = {
            cards: response.data,
            linkedSet: m.set,
            linkedColNum: m.colNum,
            fullSet: m.cards
        }
        m.global.screenManager.callFunc("goToScreen", {type: "CardDisplayScreen", data: data })
    end if
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