function getSpecificSet(params)
    url = m.baseUrl + "cards/search?order=set&q=e={id}&unique=prints"
    url = url.replace("{id}", params.searchingFor)
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