sub init()
    m.manaCostGroup = m.top.findNode("manaCostGroup")
    m.height = 0
    m.width = 0
end sub

sub createMana()
    manaCost = m.top.mana.split("}")
    costSize = manaCost.count() - 1 'change to 0 based
    rgx = createObject("roRegex", "[{/}]", "i")
    for i = 0 to costSize step 1
        theCost = rgx.ReplaceAll(manaCost[i], "")
        if "" <> theCost
            manaSymbol = CreateObject("roSGNode","Poster")
            manaSymbol.height = m.height
            manaSymbol.width = m.width
            manaSymbol.Uri = "pkg:/assets/images/symbols/png/" + UCase(theCost) + ".png"
            m.manaCostGroup.appendChild(manaSymbol)
        end if
    end for
end sub

sub updateSize(event)
    isFor = event.getData()
    if "nameplate" = isFor
        m.height = 45
        m.width = 45
    else
        m.height = 32
        m.width = 32
    end if
end sub