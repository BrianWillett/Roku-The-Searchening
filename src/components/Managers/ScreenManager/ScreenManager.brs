sub init()
    ' get the scene (top of SG tree)
    m.scene = m.top.getScene()
    if invalid <> m.scene
        'find the screens group so we can track
        m.screens = m.scene.findNode("screens")
        'if it doesn't exist, create it
        if invalid = m.screens
            m.screens = m.scene.createChild("Group")
            m.screens.id = "screens"
        end if
    end if
    ' tracking variables
    m.currentScreen = invalid
    m.prevScreens = []
end sub

' function to navigate to different screens
'
'@params {object} params: holds the type and any transferable data
sub goToScreen(params)
    screenName = params.type
    closeCurrent = false
    if invalid <> params and invalid <> params.closeCurrent then closeCurrent = params.closeCurrent
    if invalid <> screenName and "" <> screenName
        if invalid <> m.currentScreen
            m.currentScreen.visible = false 'to hide the previous card viewed
            if not closeCurrent then m.prevScreens.push(m.currentScreen)
        end if
        if closeCurrent
            m.screens.removeChildIndex((m.screens.getChildCount() - 1))
            if 0 < m.prevScreens.count() and m.prevScreens[m.prevScreens.count() - 1].id = screenName then m.prevScreens.delete((m.prevScreens.count() - 1))
        end if
        if isOpenAlready(screenName)
            m.currentScreen = m.screens.findNode(screenName)
            m.screens.removeChild(m.currentScreen)
        end if
        screen = createObject("roSGNode", screenName)
        screen.id = screenName
        m.currentScreen = screen
        m.screens.appendChild(m.currentScreen)
        m.currentScreen.visible = true
        m.currentScreen.setFocus(true)
        if invalid <> params and invalid <> params.data
            m.currentScreen.callFunc("onOpen", {data: params.data})
        else
            m.currentScreen.callFunc("onOpen", {})
        end if
    end if
end sub

' function to check if screen is currently open so no duplicates get added
function isOpenAlready(screenName)
    screens = m.screens.getChildren(-1,0)
    for each screen in screens
        if screen.id = screenName
            return true
            exit for
        end if
    end for
    return false
end function

' function to navigate back one screen in the chain
sub goBack(params)
    if m.prevScreens.count() > 0
        data = invalid
        closeCurr = false
        screenToNavTo = m.prevScreens[m.prevScreens.count() - 1]
        if "CardDisplayScreen" = screenToNavTo.id and invalid <> screenToNavTo and invalid <> screenToNavTo.setAbbrev and invalid <> screenToNavTo.collectorNum and invalid <> screenToNavTo.alternates
            data = {
                cards: screenToNavTo.alternates[0],
                linkedSet: formatSet(screenToNavTo.setAbbrev),
                linkedColNum: screenToNavTo.collectorNum
            }
            m.global.language = screenToNavTo.langDisplay
        else if "ViewAllPrints" = screenToNavTo.id and invalid <> params and invalid <> params.data
            data = params.data
        else if "ViewSet" = screenToNavTo.id and invalid <> params and invalid <> params.data
            data = {
                data: params.data
            }
        end if
        if invalid <> params and invalid <> params.closeCurrent then closeCurr = params.closeCurrent
        ' pop removes the last element in the array, .id gets the id of the element being removed
        goToScreen({type: m.prevScreens.pop().id, data: data, closeCurrent: closeCurr})
    else
        ' if the array is empty just go to the home screen
        goToScreen({type: "HomeScreen"})
    end if
end sub

function formatSet(abbrev)
    abrv = abbrev.replace("(","")
    abrv = abrv.replace(")","")
    return LCase(abrv)
end function

function fetchLastScreen()
    return m.prevScreens[m.prevScreens.count() - 1]
end function

function fetchCurrentScreen()
    return m.currentScreen
end function