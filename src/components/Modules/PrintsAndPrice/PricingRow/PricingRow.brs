sub init()
    m.labelLayout = m.top.findNode("labelLayout")
    m.asterisk = m.top.findNode("asterisk")
    m.star = m.top.findNode("rarityStar")
    m.circle = m.top.findNode("rarityCircle")
    'labels
    m.setName = m.top.findNode("setName")
    m.usdPrice = m.top.findNode("usdPrice")
    m.eurPrice = m.top.findNode("eurPrice")
    m.tix = m.top.findNode("tix")
end sub

sub updateTranslation()
    translation = m.top.lTrans
    ' handle translations
    m.labelLayout.translation = [translation[0] + 10, translation[1] - 15 ]
    asteriskTranslation = translation
    asteriskTranslation[0] =  asteriskTranslation[0] + 305
    asteriskTranslation[1] =  asteriskTranslation[1] - 5
    m.asterisk.translation = asteriskTranslation
    m.star.translation = [-10,translation[1] + 6]
    m.circle.translation = [-31,translation[1] - 15]
    rarityStar = m.top.rarity
    if "bonus" = rarityStar then rarityStar = "special"
    m.star.uri = "pkg:/assets/images/symbols/png/" + rarityStar + ".png"
    ' handle centering
    m.asterisk.height = m.top.dHeight
    m.setName.height = m.top.dHeight
    m.usdPrice.height = m.top.dHeight
    m.eurPrice.height = m.top.dHeight
    m.tix.height = m.top.dHeight
    m.asterisk.vertAlign = "center"
    m.setName.vertAlign = "center"
    m.usdPrice.vertAlign = "center"
    m.eurPrice.vertAlign = "center"
    m.tix.vertAlign = "center"
end sub