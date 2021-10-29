sub init()
    m.top.functionName = "directFlow"
    m.messagePort = createObject("roMessagePort")
    m.top.observeField("params",m.messagePort)
end sub

' Function to direct the incoming tasks to the correct files
sub directFlow()
    msg = wait(0, m.messagePort)
    if "roSGNodeEvent" = type(msg)
        doWork(msg.getData())
    end if
end sub

' Function stub to be inherited and overloaded in each Task file
'
' @param {object} params, the params passed in from the port event
sub doWork(params)

end sub

function sendRequest(httpObject, port)

end function