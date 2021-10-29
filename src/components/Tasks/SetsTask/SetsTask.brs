' Function to direct the incomming set request to the correct file
'
' @param {object} params, the params passed in from the port event
sub doWork(params)
    if invalid <> params and invalid <> params.requestType
        m.baseUrl = getAPI("baseUrl")
        if "allSets" = params.requestType or "autoComplete" = params.requestType
            m.top.response = getAllSets()
        else if "specificSet" = params.requestType
            response = getSpecificSet(params)
            if invalid <> response
                if invalid = response.has_more or not response.has_more
                    m.top.response = response
                else
                    m.top.multiPager = response
                    contParams = {
                        requestType: "haveUrl",
                        url: response.next_page
                    }
                    doWork(contParams)
                end if
            end if
        else if "haveUrl" = params.requestType
            response = getMoreResults(params)
            prev = m.top.multiPager
            if invalid <> response and invalid <> response.data
                for i = 0 to response.data.Count() - 1 step 1
                    prev.data.push(response.data[i])
                end for
            end if
            if invalid = response.has_more or not response.has_more
                m.top.response = prev
            else
                m.top.multiPager = prev
                contParams = {
                    requestType: "haveUrl",
                    url: response.next_page
                }
                doWork(contParams)
            end if
        end if
    end if
end sub
function sendRequest(httpObject, port)
    httpObject.asyncGetToString()
    response = invalid
    msg = wait(1000, port)

    if "roUrlEvent" = type(msg)
        if 200 = msg.getResponseCode()
            resp = msg.getString()
            response = ParseJson(resp)
        end if
    end if
    return response
end function