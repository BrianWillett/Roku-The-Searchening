sub init()
    m.poster = m.top.findNode("English")
end sub

sub changeBGColor()
    m.poster.blendColor = "#00000000"
    m.poster.blendColor = m.top.postColor
end sub