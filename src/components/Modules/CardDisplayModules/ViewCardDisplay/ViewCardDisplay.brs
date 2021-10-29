sub init()
    m.image = m.top.findNode("viewAllCardImage")
    m.set = m.top.findNode("set")
end sub

sub displayCard()
    if invalid <> m.top.itemContent and invalid <> m.top.itemContent.HDPosterUrl
        m.image.uri = m.top.itemContent.HDPosterUrl
        m.set.text = m.top.itemContent.title
    end if
end sub