import VPlay 2.0
import VPlayApps 1.0
import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtCharts 2.2
import "."

App {
    id: app

    property string errorMsg: ""
    readonly property string weatherServiceAppId: "d8ed259735b17a417d92789cd24abae6";

    NavigationStack {

        // we display the json data in a list
        Page {
            id: page
            title: qsTr("REST with Qt QML and V-Play")
            ColumnLayout {
                anchors.fill: parent    // Important: otherwise search bar not visible when there is no text in UI
                anchors.margins: app.dp(16)

                SearchBar {
                    id: weatherSearchBar
                    focus: true
                    Layout.fillWidth: true
                    placeHolderText: qsTr("Enter city name")
                    onAccepted: loadJsonData()
                }

                AppText {
                    text: app.errorMsg
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    visible: app.errorMsg !== undefined
                }

                AppText {
                    text: qsTr("Weather for %1").arg(DataModel.weatherData.weatherForCity)
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    color: Theme.tintColor
                    font.family: Theme.boldFont.name
                    font.bold: true
                    font.weight: Font.Bold
                    visible: DataModel.weatherAvailable
                }

                AppText {
                    text: qsTr("From: %1 %2").arg(DataModel.weatherData.weatherDate).arg(DataModel.weatherFromCache ? " (Cached)" : "")
                    Layout.fillWidth: true
                    visible: DataModel.weatherAvailable
                }

                AppText {
                    text: qsTr("Temperature: %1°").arg(DataModel.weatherData.weatherTemp)
                    Layout.fillWidth: true
                    visible: DataModel.weatherAvailable
                }

                AppText {
                    text: qsTr("Condition: %1").arg(DataModel.weatherData.weatherCondition)
                    Layout.fillWidth: true
                    visible: DataModel.weatherAvailable
                }

                Image {
                    source: DataModel.weatherData.weatherIconUrl
                    visible: DataModel.weatherAvailable
                }
                Item {
                    Layout.fillHeight: true
                }
            }

        }
    }

    // loadJsonData - uses XMLHttpRequest object to dynamically load data from a file or web service
    function loadJsonData() {
        var xhr = new XMLHttpRequest

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("DONE: " + xhr.status + " / " + xhr.responseText)
                var parsedWeather = xhr.responseText ? JSON.parse(xhr.responseText) : null

                if (parsedWeather && parsedWeather.cod === 200) {
                    // Success: received city weather data
                    app.errorMsg = ""
                    DataModel.updateFromJson(parsedWeather)
                } else {
                    // Issue with the REST request
                    if (xhr.status === 0) {
                        // The request didn't go through, e.g., no Internet connection or the server is down
                        app.errorMsg = "Unable to send weather request"
                    } else if (parsedWeather && parsedWeather.message) {
                        // Received a response, but the server reported the request was not successful
                        app.errorMsg = parsedWeather.message
                    } else {
                        // All other cases - print the HTTP response status code / message
                        app.errorMsg = "Request error: " + xhr.status + " / " + xhr.statusText
                    }
                    DataModel.clearData()
                }

            }
        }

        // Build query URL
        var params = "q=" + weatherSearchBar.text + "&units=metric&appid=" + app.weatherServiceAppId
        console.log("Query URL: " + "http://api.openweathermap.org/data/2.5/weather?" + params)
        xhr.open("GET", "http://api.openweathermap.org/data/2.5/weather?" + params)
        xhr.send()
    }
}
