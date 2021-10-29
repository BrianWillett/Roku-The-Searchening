sub init()
    m.leftImages = m.top.findNode("leftImages")
    m.rightImages = m.top.findNode("rightImages")
    m.standard = m.top.findNode("standard")
    m.pioneer = m.top.findNode("pioneer")
    m.modern = m.top.findNode("modern")
    m.legacy = m.top.findNode("legacy")
    m.vintage = m.top.findNode("vintage")
    m.brawl = m.top.findNode("Brawl")
    m.historic = m.top.findNode("Historic")
    m.pauper = m.top.findNode("Pauper")
    m.penny = m.top.findNode("Penny")
    m.commander = m.top.findNode("Commander")
end sub

sub handleFormats(event)
    formats = event.getData()
    generateImage(formats.standard, m.standard)
    generateImage(formats.pioneer, m.pioneer)
    generateImage(formats.modern, m.modern)
    generateImage(formats.legacy, m.legacy)
    generateImage(formats.vintage, m.vintage)
    generateImage(formats.brawl, m.brawl)
    generateImage(formats.historic, m.historic)
    generateImage(formats.pauper, m.pauper)
    generateImage(formats.penny, m.penny)
    generateImage(formats.commander, m.commander)
end sub

sub generateImage(legality, btn)
    if "not_legal" = legality
        btn.text = "NOT LEGAL"
        btn.btnBlend = "#a8a8a8"
    else if "legal" = legality
        btn.text = "LEGAL"
        btn.btnBlend = "#4d9157"
    else if "banned" = legality
        btn.text = "BANNED"
        btn.btnBlend = "#b32c07"
    else if "restricted" = legality
        btn.text = "RESTRICT."
        btn.btnBlend = "#87a3b0"
    end if
end sub