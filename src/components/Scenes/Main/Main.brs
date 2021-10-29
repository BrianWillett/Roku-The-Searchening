sub init()
    m.top.backgroundUri = "pkg:/assets/images/background.png"

    'initialize managers
    m.global.append({
        screenManager: createObject("roSGNode", "ScreenManager")
    })
    node = createObject("roSGNode","LanguageButton")
    node.id = invalid
    m.global.addFields({language: "EN", focusColor: "#6e0cab", unfocusColor: "#000019", highlightColor: "#47475e", rarityCircleFocusColor: "#0082FF", rarityCircleUnfocusColor: "#FFFFFFFF",
         index: 0, langLastHighlighted: node, ViewAllLanguageCollectNum: "-1", ViewAllLanguageSetCode: "", newCard: true, initialOrder: []})

    onOpen()
end sub

sub onOpen()
    m.global.screenManager.callFunc("goToScreen",{type: "HomeScreen"})
end sub

