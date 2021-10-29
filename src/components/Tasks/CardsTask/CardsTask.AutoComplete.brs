function doAutoComplete(params)
    url = m.baseUrl + "cards/autocomplete?q={Name}"
    url = url.replace("{Name}", params.searchingFor)
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