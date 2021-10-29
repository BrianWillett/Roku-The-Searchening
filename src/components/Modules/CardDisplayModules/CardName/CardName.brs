sub init()
    m.namePlate = m.top.findNode("topNameplate")
    m.separator = m.top.findNode("separator")
end sub

sub changeWidth(event)
    width = event.getData()
    m.namePlate.width = width
    m.separator.lWidth = (width - 18)
end sub

sub changeHeight(event)
    height = event.getData()
    m.namePlate.height = height
    m.separator.lTranslation = "[8.5," + (height -10).toStr() + "]"
end sub