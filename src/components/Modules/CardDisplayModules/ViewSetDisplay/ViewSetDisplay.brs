sub init()
    m.image = m.top.findNode("viewAllCardImage")
    m.title = m.top.findNode("title")
end sub

sub displayCard()
    if invalid <> m.top.itemContent and invalid <> m.top.itemContent.HDPosterUrl
        m.image.uri = m.top.itemContent.HDPosterUrl
        m.title.text = m.top.itemContent.description
    end if
end sub