function doCardSearch(params)
    ' url = m.baseUrl + "cards/search?q={Name}&unique=prints&order=released"
    ' url = url.replace("{Name}", params.searchingFor)
    url = m.baseUrl + "cards/search?order=released&q=oracleid={OracleId}&unique=prints&include_multilingual=true"
    url = url.replace("{OracleId}", params.searchingFor)
    url = handleWhiteSpaces(url, true)
    requestObj = createObject("roUrlTransfer")
    port = createObject("roMessagePort")
    requestObj.setPort(port)
    requestObj.setUrl(url)
    requestObj.setHeaders({
        Accept: "application/json"
    })
    requestObj.setCertificatesFile("common:/certs/ca-bundle.crt")

    return sendRequest(requestObj, port)
end function