var QmlObject = Qt.createQmlObject('import QtQuick 2.0; QtObject { signal credentialsValid(bool valid) }', Qt.application, 'QmlObject');

function emit_validation_complete(valid) {
    console.log("[webdav.js - emit_validation_complete]")
    QmlObject.credentialsValid(valid);
}

function validateCredentials(username, password, serverURL){

    var req = new XMLHttpRequest();
    var protocol = serverURL.toLowerCase().indexOf("http://") === -1 ? "https://" : "http://"
    var url = serverURL.replace(/^https?\:\/\//i, "")

    var location = protocol + username + ":" + password + "@" +
            url + "/remote.php/webdav/"

    req.open("GET", location, true);
    req.send(null);

    //wait until the readyState is 4, which means the json is ready
    req.onreadystatechange = function()
    {
        if (req.readyState == 4){
            if (req.status == 200){
                console.log(req.responseText)
                emit_validation_complete(true)
            }else{
                emit_validation_complete(false)
            }
        }
    }
}

