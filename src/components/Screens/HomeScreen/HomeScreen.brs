sub init()
    m.keyboard = m.top.findNode("searchKeyboard")
    m.resultsList = m.top.findNode("cards")
    m.cardSetList = m.top.findNode("cardSetList")
    m.searchGroup = m.top.findNode("searchResults")
    m.cardSetTop = m.top.findNode("cardSetTop")
    m.panelSet = m.top.findNode("panelSet")
    m.layoutGroup = m.top.findNode("layout")
    m.homePanel = invalid
    m.searchPanel = invalid
    m.inFocus = invalid
    m.reqType = invalid
    m.panelInFocus = invalid
    m.searchFor = invalid
end sub

sub onOpen(params)
    m.keyboard.text = ""
    m.searchGroup.visible = false
    if invalid = m.homePanel then m.homePanel = createNewPanel("homePanel")
    m.cardSetList.setFocus(true)
    m.inFocus = m.cardSetTop.id
    m.cardSetList.observeField("itemFocused","setFocusedChild")

    'use this for testing purposes to auto load a card *also comment out the condition on line 80
    'executeTask("cardNamed","Paradox Engine")
    'executeTask("cardNamed","Llanowar Elves")
    'executeTask("cardNamed","Llanowar Tribe")
    'executeTask("cardNamed","Deathrite Shaman")
    'executeTask("cardNamed","Thassa's Oracle") '215
    'executeTask("cardNamed","Thassa, God of the Sea") '87
    'executeTask("cardNamed","Grim Monolith")
    'executeTask("cardNamed","Karametra's Acolyte") '42
    'executeTask("cardNamed","K'rrik, Son of Yawgmoth") '86.5
    'executeTask("cardNamed","Nicol Bolas, the Ravager")
    'executeTask("cardNamed","Wrenn and Seven")
end sub

sub initiateSearch()
    length = m.keyboard.text.Len()
    if 3 <= length
        taskType = "CardsTask"
        if "setPanel" = m.panelInFocus then taskType = "SetsTask"
        m.searchFor = m.keyboard.text
        executeTask("autoComplete",m.searchFor,taskType)
    else if 0 = length
        m.resultsList.removeChildrenIndex(m.resultsList.getChildCount(),0)
        m.searchGroup.visible = false
    end if
end sub

sub executeTask(reqType, text, taskType = "CardsTask")
    m.reqType = reqType
    search = createObject("roSGNode",taskType)
    search.params = {
        requestType: reqType,
        searchingFor: text
    }
    search.unobserveField("response")
    search.observeField("response","onResultReceived")
    search.control = "run"
end sub

sub onResultReceived(event)
    response = event.getData()
    if invalid <> response
        if "setPanel" = m.panelInFocus or "setResultsPanel" = m.panelInFocus
            ' for sets
            if "autoComplete" = m.reqType
                dispArray = []
                for i = 0 to (response.data.Count() - 1) step 1
                    if 0 <= LCase(response.data[i].name).inStr(m.searchFor) or  0 <= LCase(response.data[i].code).inStr(m.searchFor)
                        dispArray.push(response.data[i])
                    end if
                end for
                populateResults(dispArray.Count(), dispArray)
            else if "specificSet" = m.reqType and invalid <> response.data and invalid <> response.total_cards
                m.global.screenManager.callFunc("goToScreen", {type: "ViewSet", data: response})
            end if
        else if "cardPanel" = m.panelInFocus or "cardResultsPanel" = m.panelInFocus
            ' for cards
            if invalid <> m.reqType
                if "autoComplete" = m.reqType
                    if invalid <> response.data and invalid <> response.total_values
                        populateResults(response.total_values, response.data)
                    end if
                else if "cardNamed" = m.reqType
                    if invalid <> response.oracle_id then executeTask("cardSearch",response.oracle_id)
                else if "cardSearch" = m.reqType
                    m.global.screenManager.callFunc("goToScreen", {type: "CardDisplayScreen", data: response})
                end if
            end if
        end if
    end if
end sub

sub setFocusedChild(event)
    if m.inFocus = m.cardSetTop.id
        m.cardSetTop.getChild(event.getData()).setFocus(true)
    else if m.inFocus = "NewList"
        node = m.panelSet.findNode("NewContentNode")
        node.getChild(event.data()).setFocus(true)
    end if
end sub

sub populateResults(totalNum, result)
    m.searchGroup.visible = true
    m.resultsList.removeChildrenIndex(m.resultsList.getChildCount(),0)
    if 0 < totalNum
        countTo = totalNum - 1
    else
        countTo = 0
    end if
    for i = 0 to countTo step 1
        newRes = createObject("roSGNode","ContentNode")
        if "cardPanel" = m.panelInFocus
            if invalid <> result[i]
                newRes.title = result[i]
                newRes.description = result[i]
            else
                newRes.title = "No cards found"
                newRes.description="-1"
            end if
        else if "setPanel" = m.panelInFocus
            if invalid <> result[i] and invalid <> result[i].name and invalid <> result[i].code
                newRes.title = result[i].name + " (" + UCase(result[i].code) + ")"
                newRes.description = result[i].code
            else
                newRes.title = "No sets found"
                newRes.description="-1"
            end if
        end if
        m.resultsList.appendChild(newRes)
    end for
    m.searchGroup.observeField("itemSelected","displayCard")
end sub

sub displayCard(event)
    resetGlobals()
    selection = getName(event.getData())
    if invalid <> selection and invalid <> selection.title and invalid <> selection.description and "-1" <> selection.description
        if "cardPanel" = m.panelInFocus or "cardResultsPanel" = m.panelInFocus
            executeTask("cardNamed",selection.title)
        else if "setPanel" = m.panelInFocus or "setResultsPanel" = m.panelInFocus
            executeTask("specificSet",selection.description,"SetsTask")
        end if
    else if "-1" = selection.description
        m.searchGroup.setFocus(true)
    end if
end sub

function getName(index)
    return m.resultsList.getChild(index)
end function

function createNewPanel(name, panel = invalid)
    newPanel = panel
    if invalid = newPanel
        if "cardPanel" = name or "setPanel" = name
            newPanel = CreateObject("roSGNode","Panel")
            newPanel.id = name
            newPanel.isFullScreen = true
            newPanel.appendChild(m.layoutGroup)
            m.layoutGroup.visible = true
        else if "homePanel" = name
            newPanel = CreateObject("roSGNode","Panel")
            newPanel.id = name
            newPanel.isFullScreen = true
            newPanel.appendChild(m.cardSetList)
            m.layoutGroup.visible = false
        else if "setResultsPanel" = name or "cardResultsPanel" = name
            newPanel = CreateObject("roSGNode","Panel")
            newPanel.id = name
            newPanel.isFullScreen = true
            copyList = createObject("roSGNode","ContentNode")
            newList = CreateObject("roSGNode","LabelList")
            newList.id = "NewList"
            copyList = m.resultsList
            copyList.id = "NewContentNode"
            newList.content = copyList
            newList.translation = [200,0]
            newPanel.appendChild(newList)
            m.layoutGroup.visible = false
        end if
    end if
    if invalid <> newPanel
        m.panelInFocus = newPanel.id
        m.panelSet.appendChild(newPanel)
        newPanel.setFocus(true)
    end if
    return newPanel
end function

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press
        if "right" = key
            if m.searchGroup.visible
                m.searchGroup.setFocus(true)
                m.inFocus =  m.searchGroup.id
            end if
            handled = true
        else if "left" = key
            m.keyboard.setFocus(true)
            m.inFocus =  m.keyboard.id
        end if
    else
        ' the keypress that leaves the keyboard does not register the press, only the release
        if m.inFocus = m.cardSetTop.id and ("right" = key or "OK" = key)
            if "Card Search" = m.cardSetTop.focusedChild.title
                cardPanel = m.panelSet.findNode("cardPanel")
                if invalid = cardPanel then createNewPanel("cardPanel")
                m.resultsList.removeChildrenIndex(m.resultsList.getChildCount(),0)
                m.keyboard.setFocus(true)
                m.inFocus = m.keyboard.id
                m.keyboard.observeField("text","initiateSearch")
            else if "Set Search" = m.cardSetTop.focusedChild.title
                setPanel = m.panelSet.findNode("setPanel")
                if invalid = setPanel then createNewPanel("setPanel")
                m.resultsList.removeChildrenIndex(m.resultsList.getChildCount(),0)
                m.keyboard.setFocus(true)
                m.inFocus = m.keyboard.id
                m.keyboard.observeField("text","initiateSearch")
            end if
            handled = true
        else if m.inFocus = m.keyboard.id and "left" = key
            m.layoutGroup.visible = false
            m.keyboard.text = ""
            m.panelSet.removeChildIndex(m.panelSet.getChildCount() - 1)
            m.cardSetList.setFocus(true)
            m.panelInFocus = "homePanel"
            m.inFocus = m.cardSetTop.id
            handled = true
        else if m.inFocus = m.keyboard.id and "right" = key
            if "setPanel" = m.panelInFocus
                createNewPanel("setResultsPanel")
                resultsPanel = m.panelSet.findNode("setResultsPanel")
            else if "cardPanel" = m.panelInFocus
                createNewPanel("cardResultsPanel")
                resultsPanel = m.panelSet.findNode("cardResultsPanel")
            end if
            if invalid = resultsPanel then createNewPanel("resultsPanel")
            m.searchGroup = m.panelSet.findNode("NewList")
            m.searchGroup.setFocus(true)
            m.inFocus = m.searchGroup.id
            m.panelInFocus = resultsPanel.id
            m.searchGroup.observeField("itemSelected","displayCard")
            handled = true
        else if m.inFocus = m.searchGroup.id and "right" = key
            handled = true
        else if m.inFocus = m.searchGroup.id and "left" = key
            m.layoutGroup.visible = true
            m.keyboard.setFocus(true)
            m.inFocus = m.keyboard.id
            if "setResultsPanel" = m.panelInFocus then m.panelInFocus = "setPanel"
            if "cardResultsPanel" = m.panelInFocus then m.panelInFocus = "cardPanel"
            handled = true
        else if m.inFocus = m.searchGroup.id and "left" = key
            m.keyboard.setFocus(true)
            m.inFocus = m.keyboard.id
            handled = true
        end if
    end if
    return handled
end function