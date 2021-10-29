sub init()
    m.buttonLabel = m.top.findNode("buttonLabel")
    m.buttonLabel.horizAlign = "center"
    m.buttonLabel.vertAlign = "center"

    ' set default background
    if m.top.uri = invalid or m.top.uri = ""
        m.top.uri = "pkg:/assets/images/button.9.png"
    end if

    m.top.observeFieldScoped("width", "centerContents")
    m.top.observeFieldScoped("height", "centerContents")
    m.currentlyHasFocus = false
    onLoseFocus()
    m.top.observeFieldScoped("focusedChild", "onFocusChange")
end sub

sub onFocusChange(event)
    if m.top.hasFocus()
        m.currentlyHasFocus = true
        onGainFocus()
    else if m.currentlyHasFocus
        m.currentlyHasFocus = false
        onLoseFocus()
    end if
end sub

sub onGainFocus()
    m.top.blendColor = m.top.focusedColor
end sub

sub onLoseFocus()
    m.top.blendColor = m.top.unfocusedColor
end sub

' onKeyEvent is called on the focused component when there is input from the remote
function onKeyEvent(key as string, press as boolean) as boolean
    if press
        if key = "OK"
        ' signal this event
        m.top.buttonSelected = invalid
        end if
    end if
end function

sub centerContents()
    m.buttonLabel.width = m.top.width
    m.buttonLabel.height = m.top.height
end sub