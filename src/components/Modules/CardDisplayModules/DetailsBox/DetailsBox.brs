sub init()
    m.bgSquare = m.top.findNode("bgSquare")
    m.separator = m.top.findNode("separator")
end sub

sub changeWidth(event)
    width = event.getData()
    m.bgSquare.width = width
    m.separator.lWidth = width
end sub

sub changeHeight(event)
    height = event.getData()
    m.bgSquare.height = height
    m.separator.lTranslation = "[-1.25," + (height - 2).toStr() + "]"
end sub